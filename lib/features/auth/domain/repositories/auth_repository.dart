import '../../../../models/user_role.dart';

abstract class AuthRepository {
  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  });
}
