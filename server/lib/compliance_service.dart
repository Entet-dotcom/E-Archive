import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'sqlite_store.dart';

/// Records management, privacy, retention, and ISO compliance helpers.
class ComplianceService {
  ComplianceService(this._store);

  final SqliteStore _store;

  static String hashBytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, Object?>> fetchOverview() async {
    final retention = await fetchRetentionMonitoring();
    final duplicates = await fetchDuplicates();
    final disposal = await fetchDisposalRecommendations();
    final privacy = await fetchPrivacyCompliance();
    final iso = await fetchIsoCompliance();
    final backups = await fetchBackups();

    final active = retention.where((r) {
      final status = (r['status'] ?? '').toString();
      return status == 'active' || status == 'expiring_soon';
    }).length;
    final expired = retention.where((r) => r['status'] == 'expired').length;

    return {
      'retention_total': retention.length,
      'retention_active': active,
      'retention_expired': expired,
      'duplicate_groups': duplicates.length,
      'disposal_pending': disposal
          .where((d) => (d['status'] ?? '') == 'pending')
          .length,
      'privacy_score': privacy['compliance_score'],
      'iso_score': iso['overall_score'],
      'backup_count': backups.length,
      'last_backup': backups.isEmpty ? null : backups.first['created_at'],
    };
  }

  Future<List<Map<String, Object?>>> fetchRetentionPolicies() async {
    return _store.fetchRetentionPolicies();
  }

  Future<List<Map<String, Object?>>> fetchRetentionMonitoring() async {
    final policies = await _store.fetchRetentionPolicies();
    final policyByType = <String, Map<String, Object?>>{};
    for (final policy in policies) {
      policyByType[(policy['document_type'] ?? '').toString()] = policy;
    }

    final defaultYears =
        policies.isEmpty ? 7 : (policies.first['retention_years'] as int? ?? 7);

    final docs = await _store.fetchDocuments();
    final now = DateTime.now().toUtc();
    final results = <Map<String, Object?>>[];

    for (final doc in docs) {
      final docType = (doc['document_type'] ?? 'Other').toString();
      final policy = policyByType[docType] ?? policyByType['Other'];
      final years = policy?['retention_years'] as int? ?? defaultYears;
      final createdRaw = (doc['created_at'] ?? '').toString();
      final created = DateTime.tryParse(createdRaw.replaceFirst(' ', 'T')) ??
          now;
      final expiry = created.add(Duration(days: years * 365));
      final daysLeft = expiry.difference(now).inDays;

      String status;
      if (daysLeft < 0) {
        status = 'expired';
      } else if (daysLeft <= 90) {
        status = 'expiring_soon';
      } else {
        status = 'active';
      }

      results.add({
        ...doc,
        'retention_years': years,
        'expiry_date': expiry.toIso8601String(),
        'days_remaining': daysLeft,
        'status': status,
        'legal_basis': policy?['legal_basis'] ?? 'RA 9470 (National Archives Act)',
        'iso_reference': policy?['iso_reference'] ?? 'ISO 15489-1:2016',
      });
    }

    results.sort((a, b) {
      final da = a['days_remaining'] as int? ?? 0;
      final db = b['days_remaining'] as int? ?? 0;
      return da.compareTo(db);
    });
    return results;
  }

  Future<List<Map<String, Object?>>> fetchAccessRules() async {
    return _store.fetchAccessRules();
  }

  bool isAccessAllowed({
    required String role,
    required String resource,
    required String action,
    List<Map<String, Object?>>? rules,
  }) {
    final normalizedRole = role.toLowerCase();
    final ruleList = rules ?? [];
    for (final rule in ruleList) {
      final ruleRole = (rule['role'] ?? '').toString().toLowerCase();
      final ruleResource = (rule['resource'] ?? '').toString();
      final ruleAction = (rule['action'] ?? '').toString();
      if (ruleRole == normalizedRole &&
          ruleResource == resource &&
          ruleAction == action) {
        return (rule['allowed'] ?? 0) == 1;
      }
    }
    return normalizedRole == 'admin';
  }

  Future<List<Map<String, Object?>>> fetchDuplicates() async {
    final docs = await _store.fetchDocuments();
    final byHash = <String, List<Map<String, Object?>>>{};

    for (final doc in docs) {
      final hash = (doc['content_hash'] ?? '').toString();
      if (hash.isEmpty) continue;
      byHash.putIfAbsent(hash, () => []).add(doc);
    }

    final groups = <Map<String, Object?>>[];
    for (final entry in byHash.entries) {
      if (entry.value.length < 2) continue;
      groups.add({
        'content_hash': entry.key,
        'count': entry.value.length,
        'documents': entry.value,
        'total_size_bytes': entry.value.fold<int>(
          0,
          (sum, d) => sum + ((d['size_bytes'] as int?) ?? 0),
        ),
      });
    }
    groups.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return groups;
  }

  Future<Map<String, Object?>> fetchDecisionAnalytics() async {
    final docs = await _store.fetchDocuments();
    final students = await _store.fetchStudents();
    final retention = await fetchRetentionMonitoring();
    final duplicates = await fetchDuplicates();

    final byType = <String, int>{};
    final byCollege = <String, int>{};
    final byYear = <String, int>{};
    var totalBytes = 0;

    for (final doc in docs) {
      final type = (doc['document_type'] ?? 'Other').toString();
      byType[type] = (byType[type] ?? 0) + 1;
      final college = (doc['college'] ?? 'General').toString();
      byCollege[college] = (byCollege[college] ?? 0) + 1;
      final year = (doc['school_year'] ?? 'Unknown').toString();
      byYear[year] = (byYear[year] ?? 0) + 1;
      totalBytes += (doc['size_bytes'] as int?) ?? 0;
    }

    final expired = retention.where((r) => r['status'] == 'expired').length;
    final expiringSoon =
        retention.where((r) => r['status'] == 'expiring_soon').length;
    final duplicateDocs = duplicates.fold<int>(
      0,
      (sum, g) => sum + ((g['count'] as int?) ?? 0) - 1,
    );

    final recommendations = <Map<String, String>>[];
    if (expired > 0) {
      recommendations.add({
        'priority': 'high',
        'title': 'Review expired records',
        'detail':
            '$expired document(s) exceeded retention period. Schedule disposal review.',
      });
    }
    if (duplicateDocs > 0) {
      recommendations.add({
        'priority': 'medium',
        'title': 'Resolve duplicate uploads',
        'detail':
            '$duplicateDocs redundant copy(ies) detected. Consolidate to save storage.',
      });
    }
    if (expiringSoon > 0) {
      recommendations.add({
        'priority': 'medium',
        'title': 'Plan upcoming disposals',
        'detail':
            '$expiringSoon document(s) expire within 90 days. Prepare approval workflow.',
      });
    }
    if (recommendations.isEmpty) {
      recommendations.add({
        'priority': 'low',
        'title': 'Records in good standing',
        'detail': 'No urgent compliance actions required at this time.',
      });
    }

    return {
      'totals': {
        'students': students.length,
        'documents': docs.length,
        'storage_bytes': totalBytes,
        'storage_mb': (totalBytes / (1024 * 1024)).toStringAsFixed(2),
      },
      'retention_summary': {
        'active': retention.where((r) => r['status'] == 'active').length,
        'expiring_soon': expiringSoon,
        'expired': expired,
      },
      'documents_by_type': byType,
      'documents_by_college': byCollege,
      'documents_by_school_year': byYear,
      'duplicate_groups': duplicates.length,
      'decisions': recommendations,
    };
  }

  Future<Map<String, Object?>> createBackup() async {
    final timestamp = DateTime.now().toUtc();
    final label =
        'backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';

    final backupRoot = Directory(
      p.join(Directory.current.path, 'backups', label),
    );
    await backupRoot.create(recursive: true);

    final dbSource = File(ServerConfig.resolvedDbPath);
    if (!await dbSource.exists()) {
      throw StateError('Database file not found');
    }
    final dbDest = File(p.join(backupRoot.path, 'e_archive.sqlite'));
    await dbSource.copy(dbDest.path);

    var uploadsBytes = 0;
    final uploadsDest = Directory(p.join(backupRoot.path, 'uploads'));
    if (_store.uploadsDir.existsSync()) {
      await _copyDirectory(_store.uploadsDir, uploadsDest);
      uploadsBytes = await _directorySize(uploadsDest);
    }

    final dbBytes = await dbDest.length();
    final totalBytes = dbBytes + uploadsBytes;

    final manifest = {
      'label': label,
      'created_at': timestamp.toIso8601String(),
      'database_bytes': dbBytes,
      'uploads_bytes': uploadsBytes,
      'total_bytes': totalBytes,
    };
    await File(p.join(backupRoot.path, 'manifest.json')).writeAsString(
      const JsonEncoder.withIndent('  ').convert(manifest),
    );

    final record = await _store.insertBackupRecord(
      label: label,
      backupPath: backupRoot.path,
      sizeBytes: totalBytes,
      status: 'completed',
    );

    await _store.insertAuditLog(
      actor: 'system',
      action: 'backup_created',
      resourceType: 'backup',
      resourceId: label,
      details: 'Backup size: ${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
    );

    return {...record, 'manifest': manifest};
  }

  Future<List<Map<String, Object?>>> fetchBackups() async {
    return _store.fetchBackupRecords();
  }

  Future<Map<String, Object?>> restoreBackup(String label) async {
    final records = await _store.fetchBackupRecords();
    final match = records.cast<Map<String, Object?>>().where(
          (r) => (r['label'] ?? '').toString() == label,
        );
    if (match.isEmpty) {
      throw StateError('Backup not found: $label');
    }

    final backupPath = (match.first['backup_path'] ?? '').toString();
    final backupDir = Directory(backupPath);
    if (!backupDir.existsSync()) {
      throw StateError('Backup directory missing on disk');
    }

    final dbBackup = File(p.join(backupPath, 'e_archive.sqlite'));
    if (!dbBackup.existsSync()) {
      throw StateError('Backup database file missing');
    }

    await _store.close();
    final liveDb = File(ServerConfig.resolvedDbPath);
    if (liveDb.existsSync()) {
      final safety = File('${liveDb.path}.pre_restore');
      await liveDb.copy(safety.path);
    }
    await dbBackup.copy(liveDb.path);

    final uploadsBackup = Directory(p.join(backupPath, 'uploads'));
    if (uploadsBackup.existsSync()) {
      if (_store.uploadsDir.existsSync()) {
        await _store.uploadsDir.delete(recursive: true);
      }
      await _copyDirectory(uploadsBackup, _store.uploadsDir);
    }

    await _store.open(_store.uploadsDir);

    await _store.insertAuditLog(
      actor: 'system',
      action: 'backup_restored',
      resourceType: 'backup',
      resourceId: label,
      details: 'Database and uploads restored from $label',
    );

    return {'restored': true, 'label': label};
  }

  Future<Map<String, Object?>> fetchPrivacyCompliance() async {
    final docs = await _store.fetchDocuments();
    final students = await _store.fetchStudents();
    final auditCount = (await _store.fetchAuditLogs(limit: 1000)).length;
    final backups = await _store.fetchBackupRecords();

    final checks = <Map<String, Object?>>[
      {
        'requirement': 'RA 10173 — Lawful processing basis',
        'status': 'compliant',
        'detail':
            'Records processed for legitimate educational/registrar purposes.',
        'reference': 'Data Privacy Act of 2012, Sec. 11',
      },
      {
        'requirement': 'RA 10173 — Security measures',
        'status': backups.isNotEmpty ? 'compliant' : 'partial',
        'detail': backups.isNotEmpty
            ? 'Backup procedures in place (${backups.length} backup(s)).'
            : 'No backups recorded. Create a backup to strengthen data protection.',
        'reference': 'Data Privacy Act of 2012, Sec. 20',
      },
      {
        'requirement': 'RA 10173 — Access logging',
        'status': auditCount > 0 ? 'compliant' : 'partial',
        'detail': auditCount > 0
            ? '$auditCount audit event(s) recorded.'
            : 'Enable activity logging for accountability.',
        'reference': 'NPC Circular 16-01',
      },
      {
        'requirement': 'PII inventory',
        'status': 'compliant',
        'detail':
            '${students.length} student record(s) and ${docs.length} document(s) catalogued.',
        'reference': 'RA 10173, Sec. 16 (Rights of data subjects)',
      },
      {
        'requirement': 'Retention limits',
        'status': 'compliant',
        'detail':
            'Retention policies configured per document type (ISO 15489 aligned).',
        'reference': 'RA 9470 + ISO 15489-1:2016',
      },
    ];

    final compliant = checks.where((c) => c['status'] == 'compliant').length;
    final partial = checks.where((c) => c['status'] == 'partial').length;
    final score = ((compliant + partial * 0.5) / checks.length * 100).round();

    return {
      'framework': 'Philippine Data Privacy Act (RA 10173)',
      'compliance_score': score,
      'checks': checks,
      'data_subjects': students.length,
      'personal_data_records': docs.length,
    };
  }

  Future<List<Map<String, Object?>>> fetchDisposalRecommendations() async {
    final retention = await fetchRetentionMonitoring();
    final existing = await _store.fetchDisposalQueue();
    final existingByDoc = {
      for (final row in existing)
        (row['document_id'] as int? ?? -1): row,
    };

    final recommendations = <Map<String, Object?>>[];
    for (final row in retention) {
      final status = (row['status'] ?? '').toString();
      if (status != 'expired' && status != 'expiring_soon') continue;

      final docId = row['id'] as int?;
      if (docId == null) continue;

      final queued = existingByDoc[docId];
      if (queued != null) {
        recommendations.add({...queued, 'document': row});
        continue;
      }

      final reason = status == 'expired'
          ? 'Retention period exceeded'
          : 'Retention period ends within 90 days';

      recommendations.add({
        'document_id': docId,
        'status': 'pending',
        'reason': reason,
        'recommended_date': row['expiry_date'],
        'document': row,
      });
    }

    recommendations.sort((a, b) {
      final sa = (a['document'] as Map?)?['status']?.toString() ?? '';
      final sb = (b['document'] as Map?)?['status']?.toString() ?? '';
      if (sa == 'expired' && sb != 'expired') return -1;
      if (sb == 'expired' && sa != 'expired') return 1;
      return 0;
    });
    return recommendations;
  }

  Future<Map<String, Object?>> approveDisposal(int documentId) async {
    final row = await _store.upsertDisposalQueue(
      documentId: documentId,
      status: 'approved',
      reason: 'Approved for secure disposal',
    );
    await _store.insertAuditLog(
      actor: 'admin',
      action: 'disposal_approved',
      resourceType: 'document',
      resourceId: '$documentId',
      details: 'Disposal approved per retention policy',
    );
    return row;
  }

  Future<Map<String, Object?>> fetchIsoCompliance() async {
    final policies = await _store.fetchRetentionPolicies();
    final auditLogs = await _store.fetchAuditLogs(limit: 50);
    final accessRules = await _store.fetchAccessRules();
    final docs = await _store.fetchDocuments();

    final controls = <Map<String, Object?>>[
      {
        'standard': 'ISO 15489-1:2016',
        'control': 'Records classification',
        'status': docs.isNotEmpty ? 'implemented' : 'partial',
        'detail': 'Documents classified by type, college, program, and school year.',
      },
      {
        'standard': 'ISO 15489-1:2016',
        'control': 'Retention schedules',
        'status': policies.isNotEmpty ? 'implemented' : 'not_implemented',
        'detail': '${policies.length} retention polic(ies) defined.',
      },
      {
        'standard': 'ISO 15489-1:2016',
        'control': 'Metadata capture',
        'status': 'implemented',
        'detail':
            'Document metadata includes student, program, school year, and storage path.',
      },
      {
        'standard': 'ISO 30301:2019',
        'control': 'Access control rules',
        'status': accessRules.isNotEmpty ? 'implemented' : 'partial',
        'detail': '${accessRules.length} rule-based access polic(ies) active.',
      },
      {
        'standard': 'ISO 27001:2022',
        'control': 'Audit trail',
        'status': auditLogs.isNotEmpty ? 'implemented' : 'partial',
        'detail': '${auditLogs.length} audit event(s) on record.',
      },
      {
        'standard': 'ISO 15489-1:2016',
        'control': 'Disposal procedures',
        'status': 'implemented',
        'detail': 'Disposal recommendations generated from retention monitoring.',
      },
    ];

    final implemented =
        controls.where((c) => c['status'] == 'implemented').length;
    final partial = controls.where((c) => c['status'] == 'partial').length;
    final score =
        ((implemented + partial * 0.5) / controls.length * 100).round();

    return {
      'standards': ['ISO 15489-1:2016', 'ISO 30301:2019', 'ISO 27001:2022'],
      'overall_score': score,
      'controls': controls,
    };
  }

  Future<Map<String, Object?>> logAudit({
    required String actor,
    required String action,
    String resourceType = '',
    String resourceId = '',
    String details = '',
  }) async {
    return _store.insertAuditLog(
      actor: actor,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      details: details,
    );
  }

  Future<List<Map<String, Object?>>> fetchAuditLogs({int limit = 100}) async {
    return _store.fetchAuditLogs(limit: limit);
  }

  Future<Map<String, Object?>?> findDuplicateByHash(String hash) async {
    if (hash.isEmpty) return null;
    return _store.findDocumentByHash(hash);
  }

  Future<void> _copyDirectory(Directory source, Directory dest) async {
    await dest.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final name = p.basename(entity.path);
      final target = p.join(dest.path, name);
      if (entity is File) {
        await entity.copy(target);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(target));
      }
    }
  }

  Future<int> _directorySize(Directory dir) async {
    var total = 0;
    if (!dir.existsSync()) return 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}
