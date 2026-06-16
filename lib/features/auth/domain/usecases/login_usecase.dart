import '../../../../models/user_role.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call({
    required String username,
    required String password,
    required UserRole role,
  }) {
    return _repository.login(username: username, password: password, role: role);
  }
}
