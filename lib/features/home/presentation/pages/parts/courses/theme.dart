part of '../../dashboard_shell_page.dart';

const _courseBlue = Color(0xFF2563EB);

final _courseFieldTextStyle = AppFonts.poppins(
  color: Color(0xFF000000),
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

InputDecoration _courseInputDecoration({
  required String label,
  required String hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: AppFonts.poppins(
      color: Color(0xFF000000),
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
    floatingLabelStyle: AppFonts.poppins(
      color: Color(0xFF000000),
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
    hintStyle: AppFonts.poppins(color: Color(0xFF9CA3AF), fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFB91C1C)),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  );
}
