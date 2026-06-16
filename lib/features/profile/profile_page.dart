part of '../home/presentation/pages/dashboard_shell_page.dart';

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      title: 'Profile',
      icon: Icons.account_circle_outlined,
      child: Text(
        'Profile page placeholder matching registrar-vista route.\n'
        'Connect this to your user model (name, email, role, avatar) and provide update actions.',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
      ),
    );
  }
}

