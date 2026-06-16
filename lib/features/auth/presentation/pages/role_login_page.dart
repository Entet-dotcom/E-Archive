import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../home/presentation/pages/dashboard_shell_page.dart';
import '../viewmodels/login_view_model.dart';

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({
    super.key,
    required this.role,
    required this.loginUseCase,
  });

  final UserRole role;
  final LoginUseCase loginUseCase;

  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<RoleLoginPage> {
  late final LoginViewModel _viewModel;
  late UserRole _role;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
    _viewModel = LoginViewModel(widget.loginUseCase);
    _viewModel.selectRole(_role);
    _viewModel.addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_refresh);
    _viewModel.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _isAdmin => _role == UserRole.admin;
  Color get _roleTint =>
      _isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE);
  Color get _roleIconColor =>
      _isAdmin ? const Color(0xFFB45309) : const Color(0xFF0284C7);
  String get _roleLabel =>
      _isAdmin ? 'Administrator Access' : 'Staff Access';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFF0F8FF), Color(0xFFFFF8EA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              children: [
                _HeaderBar(
                  onBackHome: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _roleTint,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _isAdmin
                                      ? Icons.verified_user_outlined
                                      : Icons.groups_2_outlined,
                                  color: _roleIconColor,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleTint,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  _roleLabel,
                                  style: TextStyle(
                                    color: _roleIconColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _isAdmin ? 'Administrator Login' : 'Staff Login',
                                style: const TextStyle(
                                  fontSize: 48,
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                _isAdmin
                                    ? 'Sign in to manage the E-Archive System'
                                    : 'Sign in to access daily registrar operations',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _viewModel.usernameController,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration:
                                  _inputDecoration('you@jmsu.edu.ph').copyWith(
                                prefixIcon: const Icon(
                                  Icons.mail_outline,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _viewModel.passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration:
                                  _inputDecoration('Enter your password')
                                      .copyWith(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF6B7280),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF334155),
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _viewModel.isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D4B8F),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _viewModel.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isAdmin
                                            ? 'Sign in as Admin'
                                            : 'Sign in as Staff',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),
                            if (_viewModel.message != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _viewModel.message!,
                                style: TextStyle(
                                  color: _viewModel.loginSuccess
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _switchRole,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF111827),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  _isAdmin
                                      ? Icons.groups_2_outlined
                                      : Icons.verified_user_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  _isAdmin
                                      ? 'Switch to Staff Login'
                                      : 'Switch to Administrator Login',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Center(
                              child: Text(
                                'Access is restricted to administrators and registrar staff only.',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    '© 2026 JRMSU Registrar\'s Office',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _switchRole() {
    setState(() {
      _role = _role == UserRole.admin ? UserRole.staff : UserRole.admin;
      _viewModel.selectRole(_role);
      _viewModel.usernameController.clear();
      _viewModel.passwordController.clear();
    });
  }

  Future<void> _handleSignIn() async {
    await _viewModel.submit();
    if (!mounted || !_viewModel.loginSuccess) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DashboardShellPage(
          role: _role,
          loginUseCase: widget.loginUseCase,
          accountName: _viewModel.usernameController.text.trim(),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF93C5FD)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onBackHome});

  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/university-logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E-Archive',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'JRMSU Registrar',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 40),
          ),
          child: const Icon(
            Icons.dark_mode_outlined,
            size: 18,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onBackHome,
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
            color: Color(0xFF6B7280),
          ),
          tooltip: 'Home',
        ),
        TextButton(
          onPressed: onBackHome,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4B5563),
          ),
          child: const Text(
            'Home',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
