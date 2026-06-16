part of '../../dashboard_shell_page.dart';

class _StudentRow {
  _StudentRow({
    this.id,
    required this.studentNo,
    required this.fullName,
    required this.course,
    required this.year,
    required this.status,
    required this.email,
  });

  final int? id;
  final String studentNo;
  final String fullName;
  final String course;
  final int year;
  final String status;
  final String? email;
}

class _CourseRow {
  const _CourseRow({this.id, required this.name, this.collegeId, this.code});
  final int? id;
  final String name;
  final int? collegeId;
  final String? code;
}

class _DocRow {
  const _DocRow({
    this.id = '',
    required this.title,
    required this.student,
    required this.type,
    required this.size,
    required this.uploaded,
    this.schoolYear = '',
    this.localImagePath,
    this.remoteImageUrl = '',
  });

  final String id;
  final String title;
  final String student;
  final String type;
  final String size;
  final String uploaded;
  final String schoolYear;
  final String? localImagePath;
  final String remoteImageUrl;
}

class _AuditRow {
  const _AuditRow(
      {required this.actor, required this.action, required this.date});
  final String actor;
  final String action;
  final String date;
}

class _ComplianceDecisionRow {
  const _ComplianceDecisionRow({
    required this.priority,
    required this.title,
    required this.detail,
  });

  final String priority;
  final String title;
  final String detail;
}

class _ComplianceDashboardData {
  const _ComplianceDashboardData({
    this.retentionActive = 0,
    this.retentionExpired = 0,
    this.duplicateGroups = 0,
    this.disposalPending = 0,
    this.privacyScore = 0,
    this.isoScore = 0,
    this.backupCount = 0,
    this.decisionCount = 0,
    this.lastBackup,
    this.decisions = const [],
  });

  final int retentionActive;
  final int retentionExpired;
  final int duplicateGroups;
  final int disposalPending;
  final int privacyScore;
  final int isoScore;
  final int backupCount;
  final int decisionCount;
  final String? lastBackup;
  final List<_ComplianceDecisionRow> decisions;
}