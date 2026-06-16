part of '../../dashboard_shell_page.dart';

class _StudentDocumentDraft {
  _StudentDocumentDraft({
    this.title = '',
    this.documentType = 'Other',
    this.fileName,
    this.filePath,
    this.receivedAt,
    this.remarks = '',
  });

  String title;
  String documentType;
  String? fileName;
  String? filePath;
  DateTime? receivedAt;
  String remarks;
}

class _StudentNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9-]'), '');
    if (upper == newValue.text) return newValue;
    final offset = newValue.selection.end.clamp(0, upper.length);
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}