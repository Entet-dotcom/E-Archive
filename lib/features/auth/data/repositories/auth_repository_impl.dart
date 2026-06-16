import '../../../../models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  }) {
    return _localDataSource.validate(
      username: username,
      password: password,
      role: role,
    );
  }
}
