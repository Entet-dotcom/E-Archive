part of '../../dashboard_shell_page.dart';

class _CollegeAddOption {
  const _CollegeAddOption({required this.code, required this.label});

  final String code;
  final String label;
}

const _collegeAddOptions = <_CollegeAddOption>[
  _CollegeAddOption(
    code: 'CCS',
    label: 'CCS - College of Computer Studies',
  ),
  _CollegeAddOption(
    code: 'EDUC',
    label: 'EDUC - College of Education (COEd)',
  ),
  _CollegeAddOption(
    code: 'CRIM',
    label: 'CRIM - College of Criminal Justice Education (CCJE)',
  ),
  _CollegeAddOption(
    code: 'CAF',
    label: 'CAF - College of Agriculture and Forestry',
  ),
  _CollegeAddOption(
    code: 'Engineering',
    label: 'Engineering - College of Engineering',
  ),
  _CollegeAddOption(
    code: 'BSBA',
    label:
        'BSBA - College of Business Administration and Hospitality Management',
  ),
];

List<String> get _presetCollegeCodes =>
    _collegeAddOptions.map((o) => o.code).toList(growable: false);

String _collegeAddOptionLabel(String code) {
  final trimmed = code.trim();
  final lower = trimmed.toLowerCase();
  if (lower == 'forestry' || lower.startsWith('forestry -')) {
    return 'CAF - College of Agriculture and Forestry';
  }
  for (final option in _collegeAddOptions) {
    if (option.code.toLowerCase() == lower) {
      return option.label;
    }
  }
  return trimmed;
}

String? _resolvePresetCollegeCode(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final lower = trimmed.toLowerCase();
  if (lower == 'forestry' || lower.startsWith('forestry -')) {
    return 'CAF';
  }
  for (final option in _collegeAddOptions) {
    final code = option.code.toLowerCase();
    if (code == lower ||
        option.label.toLowerCase() == lower ||
        lower.startsWith('$code -')) {
      return option.code;
    }
  }
  return null;
}

class _CollegeDisplayLabel {
  const _CollegeDisplayLabel({required this.code, required this.fullName});

  final String code;
  final String fullName;
}

_CollegeDisplayLabel _parseCollegeDisplayLabel(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return const _CollegeDisplayLabel(code: '', fullName: '');
  }
  final preset = _resolvePresetCollegeCode(trimmed);
  final label = _collegeAddOptionLabel(trimmed);
  if (preset != null) {
    return _CollegeDisplayLabel(code: preset, fullName: label);
  }
  final dash = trimmed.indexOf(' - ');
  if (dash > 0) {
    return _CollegeDisplayLabel(
      code: trimmed.substring(0, dash).trim(),
      fullName: trimmed,
    );
  }
  return _CollegeDisplayLabel(code: trimmed, fullName: label);
}

Future<bool?> _showCollegeDeleteDialog(
  BuildContext context, {
  required String collegeName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete college?'),
      content: Text(
        'Remove ${_collegeAddOptionLabel(collegeName)}? This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
