part of '../../dashboard_shell_page.dart';

class _ManagedUser {
  const _ManagedUser({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
  });

  final String id;
  final String fullName;
  final String role;
  final String email;

  _ManagedUser copyWith({String? role}) {
    return _ManagedUser(
      id: id,
      fullName: fullName,
      role: role ?? this.role,
      email: email,
    );
  }
}

class _RoleChangeRequest {
  const _RoleChangeRequest({required this.user, required this.role});
  final _ManagedUser user;
  final String role;
}

enum _UserToastKind { ok, err }

class _UserToast {
  const _UserToast({required this.kind, required this.msg});
  final _UserToastKind kind;
  final String msg;
}

/// Demo users until backend user management is wired.
const _demoManagedUsers = <_ManagedUser>[
  _ManagedUser(
    id: 'S2024-0003',
    fullName: 'Ana Gomez',
    role: 'staff',
    email: 'ana.gomez3@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0015',
    fullName: 'Andrea Mendoza',
    role: 'student',
    email: 'andrea.mendoza15@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0065',
    fullName: 'Andrea Mendoza',
    role: 'admin',
    email: 'andrea.mendoza65@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0040',
    fullName: 'Andrea Mendoza',
    role: 'student',
    email: 'andrea.mendoza40@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0044',
    fullName: 'Bianca Cruz',
    role: 'staff',
    email: 'bianca.cruz44@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0069',
    fullName: 'Bianca Cruz',
    role: 'student',
    email: 'bianca.cruz69@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0019',
    fullName: 'Bianca Cruz',
    role: 'student',
    email: 'bianca.cruz19@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0042',
    fullName: 'Camille Tan',
    role: 'staff',
    email: 'camille.tan42@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0067',
    fullName: 'Camille Tan',
    role: 'student',
    email: 'camille.tan67@student.jrmsu.edu.ph',
  ),
  _ManagedUser(
    id: 'S2024-0017',
    fullName: 'Camille Tan',
    role: 'student',
    email: 'camille.tan17@student.jrmsu.edu.ph',
  ),
];
