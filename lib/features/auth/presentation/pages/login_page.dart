import 'package:flutter/material.dart';

import '../../../../models/user_role.dart';
import '../../domain/usecases/login_usecase.dart';
import 'role_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.loginUseCase});

  final LoginUseCase loginUseCase;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  UserRole _selectedRole = UserRole.admin;
  late final AnimationController _heroController;
  late final Animation<double> _heroFloat;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _heroFloat = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1024;
    final titleSize = width >= 1280
        ? 64.0
        : width >= 1100
            ? 56.0
            : 46.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -120,
              child: _blurBlob(
                size: 420,
                color: const Color(0xFF7DD3FC).withOpacity(0.12),
              ),
            ),
            Positioned(
              top: 160,
              left: width * 0.3,
              child: _blurBlob(
                size: 380,
                color: const Color(0xFF86EFAC).withOpacity(0.14),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Image.asset(
                                'assets/images/university-logo.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'E-Archive',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  'JRMSU Registrar',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () => _openRoleLogin(UserRole.staff),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1F2937),
                                side: const BorderSide(color: Color(0xFFE5E7EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                              ),
                              child: const Text('Staff Login'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _openRoleLogin(UserRole.admin),
                              icon: const Icon(Icons.arrow_right_alt, size: 16),
                              label: const Text('Admin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isWide
                          ? _buildDesktopLayout(titleSize)
                          : _buildMobileLayout(titleSize),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(double titleSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30,
              right: 24,
              left: 34,
              bottom: 20,
            ),
            child: _buildContent(titleSize: titleSize, compact: false),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 22, left: 8, bottom: 20),
            child: _buildHeroCard(height: 650),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(double titleSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(height: 360),
          const SizedBox(height: 18),
          _buildContent(titleSize: titleSize.clamp(38, 48), compact: true),
        ],
      ),
    );
  }

  Widget _buildContent({required double titleSize, required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECFEFF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: Color(0xFF334155),
              ),
              SizedBox(width: 6),
              Text(
                'Restricted access portal',
                style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: titleSize,
              height: 0.98,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
            children: const [
              TextSpan(text: 'Student records,\n'),
              TextSpan(
                text: 'organized.',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          compact
              ? 'A friendly, modern records platform for the JRMSU Registrar\'s Office - archiving every document since 2022. Choose your role to begin.'
              : 'A friendly, modern records platform for the JRMSU Registrar\'s Office - archiving every document since 2022. Choose your role to begin.',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 17,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        compact
            ? Column(
                children: [
                  _CompactRoleCard(
                    role: UserRole.admin,
                    selected: _selectedRole == UserRole.admin,
                    onTap: () => _openRoleLogin(UserRole.admin),
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  _CompactRoleCard(
                    role: UserRole.staff,
                    selected: _selectedRole == UserRole.staff,
                    onTap: () => _openRoleLogin(UserRole.staff),
                    fullWidth: true,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _CompactRoleCard(
                      role: UserRole.admin,
                      selected: _selectedRole == UserRole.admin,
                      onTap: () => _openRoleLogin(UserRole.admin),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactRoleCard(
                      role: UserRole.staff,
                      selected: _selectedRole == UserRole.staff,
                      onTap: () => _openRoleLogin(UserRole.staff),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildHeroCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFBAE6FD).withOpacity(0.35),
            const Color(0xFFA7F3D0).withOpacity(0.25),
            const Color(0xFFBFDBFE).withOpacity(0.2),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 42,
            right: 38,
            child: _blurBlob(
              size: 132,
              color: const Color(0xFF86EFAC).withOpacity(0.32),
            ),
          ),
          Positioned(
            bottom: 38,
            left: 34,
            child: _blurBlob(
              size: 160,
              color: const Color(0xFF7DD3FC).withOpacity(0.24),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _heroFloat,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _heroFloat.value),
                child: child,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Image.asset(
                  'assets/images/login_page_image.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurBlob({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 70,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }

  void _openRoleLogin(UserRole role) {
    setState(() {
      _selectedRole = role;
    });

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoleLoginPage(
          role: role,
          loginUseCase: widget.loginUseCase,
        ),
      ),
    );
  }
}

class _CompactRoleCard extends StatelessWidget {
  const _CompactRoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    final iconBg = isAdmin ? const Color(0xFFFFF7D6) : const Color(0xFFDBF5FF);
    final iconColor =
        isAdmin ? const Color(0xFFF59E0B) : const Color(0xFF0EA5E9);

    return SizedBox(
      width: fullWidth ? double.infinity : 210,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected ? const Color(0xFF93C5FD) : const Color(0xFFE5E7EB),
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1A2563EB),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  isAdmin ? Icons.shield_outlined : Icons.groups_2_outlined,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAdmin ? 'Administrator' : 'Staff',
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isAdmin ? 'Full system access' : 'Registrar operations',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in  ->',
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
