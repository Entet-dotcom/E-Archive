enum UserRole { admin, staff }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.staff:
        return 'Staff';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.admin:
        return 'Full system access';
      case UserRole.staff:
        return 'Registrar operations';
    }
  }
}
