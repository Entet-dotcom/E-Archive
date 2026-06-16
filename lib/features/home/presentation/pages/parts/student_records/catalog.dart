part of '../../dashboard_shell_page.dart';

enum _StudentFormTab { student, academic, contact, notes, dates }

enum _ProgramCatalogKind { college, program }

class _ProgramCatalogEntry {
  const _ProgramCatalogEntry(this.kind, this.label);

  final _ProgramCatalogKind kind;
  final String label;
}

/// Board and non-board programs for the student form Program dropdown.
const _studentProgramCatalog = <_ProgramCatalogEntry>[
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Education (COEd)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Elementary Education (BEEd)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Physical Education (BPEd)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Secondary Education major in Filipino',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Secondary Education major in Mathematics',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Secondary Education major in Science',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Secondary Education major in Social Studies',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Agriculture and Forestry (CAF)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Agriculture major in Animal Science',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Agriculture major in Crop Science',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Agricultural and Biosystems Engineering',
  ),
  _ProgramCatalogEntry(
      _ProgramCatalogKind.program, 'Bachelor of Science in Forestry'),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Criminal Justice Education (CCJE)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Criminology',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Agriculture and Forestry (CAF)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Agribusiness',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Computer Studies (CCS)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Computer Science',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Information Systems',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.college,
    'College of Business Administration and Hospitality Management (CBAHM)',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Business Administration major in Human Resource Management',
  ),
  _ProgramCatalogEntry(
    _ProgramCatalogKind.program,
    'Bachelor of Science in Hospitality Management',
  ),
];

/// Maps department/college names in the database to catalog college labels.
const _collegeNameToCatalogLabel = <String, String>{
  'CCS': 'College of Computer Studies (CCS)',
  'EDUC': 'College of Education (COEd)',
  'COED': 'College of Education (COEd)',
  'CRIM': 'College of Criminal Justice Education (CCJE)',
  'CCJE': 'College of Criminal Justice Education (CCJE)',
  'CAF': 'College of Agriculture and Forestry (CAF)',
  'BSBA':
      'College of Business Administration and Hospitality Management (CBAHM)',
  'CBAHM':
      'College of Business Administration and Hospitality Management (CBAHM)',
  'FORESTRY': 'College of Agriculture and Forestry (CAF)',
  'ENGINEERING': 'College of Agriculture and Forestry (CAF)',
};

String? _resolveCatalogCollegeLabel(String? collegeName) {
  final name = collegeName?.trim();
  if (name == null || name.isEmpty) return null;

  // Colleges are often stored as add-dialog labels (e.g. "CCS - College of …").
  final presetCode = _resolvePresetCollegeCode(name);
  if (presetCode != null) {
    final fromPreset =
        _collegeNameToCatalogLabel[presetCode.toUpperCase()];
    if (fromPreset != null) return fromPreset;
  }

  final mapped = _collegeNameToCatalogLabel[name.toUpperCase()];
  if (mapped != null) return mapped;
  for (final entry in _studentProgramCatalog) {
    if (entry.kind != _ProgramCatalogKind.college) continue;
    final label = entry.label;
    if (label.toLowerCase() == name.toLowerCase() ||
        label.toLowerCase().contains(name.toLowerCase())) {
      return label;
    }
  }
  return null;
}

String _programDropdownHeaderValue(String label) => '\u0000header:$label';

List<String> _catalogSelectablePrograms() {
  return _studentProgramCatalog
      .where((e) => e.kind == _ProgramCatalogKind.program)
      .map((e) => e.label)
      .toList();
}

/// Programs under one department; all programs when [collegeName] is unknown.
List<String> _catalogProgramsForCollege(String? collegeName) {
  final target = _resolveCatalogCollegeLabel(collegeName);
  if (target == null) return _catalogSelectablePrograms();

  final programs = <String>[];
  String? activeCollege;
  for (final entry in _studentProgramCatalog) {
    switch (entry.kind) {
      case _ProgramCatalogKind.college:
        activeCollege = entry.label;
      case _ProgramCatalogKind.program:
        if (activeCollege == target) programs.add(entry.label);
    }
  }
  return programs;
}

List<String> _catalogDepartments() {
  final seen = <String>{};
  final departments = <String>[];
  for (final entry in _studentProgramCatalog) {
    if (entry.kind != _ProgramCatalogKind.college) continue;
    if (seen.add(entry.label)) departments.add(entry.label);
  }
  return departments;
}

String? _departmentForProgram(String program) {
  final target = program.trim();
  if (target.isEmpty) return null;
  String? activeCollege;
  for (final entry in _studentProgramCatalog) {
    switch (entry.kind) {
      case _ProgramCatalogKind.college:
        activeCollege = entry.label;
      case _ProgramCatalogKind.program:
        if (entry.label == target) return activeCollege;
    }
  }
  return null;
}

String _shortDepartmentLabel(String department) {
  final match = RegExp(r'\(([^)]+)\)\s*$').firstMatch(department.trim());
  if (match != null) return match.group(1)!.trim();
  return department;
}

List<DropdownMenuItem<String>> _flatProgramDropdownItems(
    List<String> programs) {
  return programs
      .map(
        (name) => DropdownMenuItem(
          value: name,
          child: Text(name, style: _studentFieldTextStyle),
        ),
      )
      .toList();
}

List<DropdownMenuItem<String>> _programDropdownItems({
  required List<String> selectablePrograms,
}) {
  final selectable = selectablePrograms.toSet();
  final items = <DropdownMenuItem<String>>[];
  for (final entry in _studentProgramCatalog) {
    switch (entry.kind) {
      case _ProgramCatalogKind.college:
        items.add(
          DropdownMenuItem(
            enabled: false,
            value: _programDropdownHeaderValue(entry.label),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(entry.label, style: _studentDropdownHeaderTextStyle),
            ),
          ),
        );
      case _ProgramCatalogKind.program:
        if (!selectable.contains(entry.label)) continue;
        items.add(
          DropdownMenuItem(
            value: entry.label,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(entry.label, style: _studentFieldTextStyle),
            ),
          ),
        );
    }
  }
  return items;
}

String? _resolvedProgramDropdownValue(
  String current,
  List<String> selectablePrograms,
) {
  final trimmed = current.trim();
  if (trimmed.isNotEmpty && selectablePrograms.contains(trimmed)) {
    return trimmed;
  }
  if (selectablePrograms.isNotEmpty) return selectablePrograms.first;
  return null;
}