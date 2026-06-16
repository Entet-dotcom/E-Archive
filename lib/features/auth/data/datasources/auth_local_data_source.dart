import '../../../../models/user_role.dart';

class AuthLocalDataSource {
  Future<bool> validate({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    // Demo mode: accept any non-empty credentials for now.
    return username.trim().isNotEmpty && password.trim().isNotEmpty;
  }
}
