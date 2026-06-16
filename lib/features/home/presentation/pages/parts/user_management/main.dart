part of '../../dashboard_shell_page.dart';

class _UserManagementPage extends StatefulWidget {
  const _UserManagementPage({required this.isAdmin});
  final bool isAdmin;

  @override
  State<_UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<_UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _search = '';
  String? _updatingId;
  _RoleChangeRequest? _confirmChange;
  _UserToast? _toast;

  final List<_ManagedUser> _users = List<_ManagedUser>.from(_demoManagedUsers);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdmin) {
      return const _TemplatePagePlaceholder(
        title: 'User Management',
        subtitle: 'Admins only.',
      );
    }

    final filtered = _filteredUsers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageHeader(
          title: 'Users',
          subtitle: 'Manage accounts and roles.',
        ),
        if (_toast != null) ...[
          _UserToastBanner(toast: _toast!),
          const SizedBox(height: 10),
        ],
        _RecordListCard(
          child: Column(
            children: [
              _RecordListToolbar(
                search: _RecordSearchField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (value) => setState(() => _search = value),
                  hintText: 'Search by name, user no, or email…',
                  focusColor: _UserManagementTheme.accent,
                ),
                trailing: [
                  _RecordCountBadge(
                    icon: Icons.groups_2_outlined,
                    label: '${filtered.length} of ${_users.length}',
                  ),
                  OutlinedButton.icon(
                    onPressed: _importCsv,
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: const Text('Import CSV'),
                  ),
                  _RecordPrimaryButton(
                    label: 'Add user',
                    onPressed: _addUser,
                    color: _UserManagementTheme.accent,
                  ),
                ],
              ),
              const Divider(height: 1, color: _RecordListTheme.border),
              Container(
                height: 38,
                decoration: const BoxDecoration(
                  color: _UserManagementTheme.headerBg,
                  border: Border(
                    bottom: BorderSide(color: _UserManagementTheme.border),
                  ),
                ),
                child: const Row(
                  children: [
                    _UserHeaderCell(flex: 2, label: 'User No.'),
                    _UserHeaderCell(flex: 3, label: 'Name'),
                    _UserHeaderCell(flex: 2, label: 'Role'),
                    _UserHeaderCell(flex: 4, label: 'Email'),
                    _UserHeaderCell(flex: 2, label: 'Actions', alignEnd: true),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: Text(
                    'No users found.',
                    style: TextStyle(color: _UserManagementTheme.textMuted),
                  ),
                )
              else
                for (final user in filtered)
                  _UserDataRow(
                    user: user,
                    isUpdating: _updatingId == user.id,
                    onEdit: () => _requestRoleChange(user),
                    onDelete: () => _deleteUser(user),
                  ),
            ],
          ),
        ),
        if (_confirmChange != null) ...[
          const SizedBox(height: 14),
          _UserRoleConfirmCard(
            change: _confirmChange!,
            isUpdating: _updatingId == _confirmChange!.user.id,
            onCancel: () => setState(() => _confirmChange = null),
            onConfirm: () => _applyRoleChange(_confirmChange!),
          ),
        ],
      ],
    );
  }

  List<_ManagedUser> _filteredUsers() {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return List<_ManagedUser>.from(_users);
    return _users.where((user) {
      return user.id.toLowerCase().contains(q) ||
          user.fullName.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q);
    }).toList();
  }

  void _importCsv() {
    setState(() {
      _toast = const _UserToast(
        kind: _UserToastKind.ok,
        msg: 'CSV import will be available in a future release.',
      );
    });
  }

  void _addUser() {
    _showInfo(
      context,
      'Add user flow is UI-ready. Local user storage is not implemented yet.',
    );
  }

  void _requestRoleChange(_ManagedUser user) {
    final nextRole = _nextManagedUserRole(user.role);
    setState(() {
      _confirmChange = _RoleChangeRequest(user: user, role: nextRole);
    });
  }

  void _applyRoleChange(_RoleChangeRequest request) {
    setState(() => _updatingId = request.user.id);

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final idx = _users.indexWhere((u) => u.id == request.user.id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(role: request.role);
      }
      setState(() {
        _updatingId = null;
        _confirmChange = null;
        _toast = _UserToast(
          kind: _UserToastKind.ok,
          msg: 'Role updated to ${request.role}',
        );
      });
    });
  }

  void _deleteUser(_ManagedUser user) {
    setState(() {
      _users.removeWhere((u) => u.id == user.id);
      _toast = _UserToast(
        kind: _UserToastKind.err,
        msg: '${user.fullName} removed (demo action).',
      );
    });
  }
}
