import 'package:flutter/material.dart';

import '../../../../models/user_role.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._loginUseCase);

  final LoginUseCase _loginUseCase;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  UserRole selectedRole = UserRole.admin;
  bool isLoading = false;
  String? message;
  bool loginSuccess = false;

  void selectRole(UserRole role) {
    selectedRole = role;
    message = null;
    notifyListeners();
  }

  Future<void> submit() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      message = 'Please enter username and password.';
      loginSuccess = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    message = null;
    notifyListeners();

    final result = await _loginUseCase(
      username: usernameController.text,
      password: passwordController.text,
      role: selectedRole,
    );

    isLoading = false;
    loginSuccess = result;
    message = result
        ? 'Login successful for ${selectedRole.label}.'
        : 'Invalid credentials for ${selectedRole.label}.';
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
