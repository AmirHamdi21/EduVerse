import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../generated_l10n/app_localizations.dart';

/// Admin User Management Screen
/// Displays list of users with filtering, search, and CRUD operations
class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _sortBy = 'name';
  bool _isLoading = true;
  String? _errorMessage;
  List<_UserModel> _users = [];
  List<_UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedFilter = 'all';
          break;
        case 1:
          _selectedFilter = 'student';
          break;
        case 2:
          _selectedFilter = 'instructor';
          break;
        case 3:
          _selectedFilter = 'ta';
          break;
        case 4:
          _selectedFilter = 'admin';
          break;
      }
      _applyFilters();
    });
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _users = [
        _UserModel(
          id: '1',
          name: 'Ahmed Hassan',
          email: 'ahmed.hassan@campus.edu',
          role: 'student',
          department: 'Computer Science',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 120)),
          avatar: null,
        ),
        _UserModel(
          id: '2',
          name: 'Dr. Sarah Miller',
          email: 'sarah.miller@campus.edu',
          role: 'instructor',
          department: 'Computer Science',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 365)),
          avatar: null,
        ),
        _UserModel(
          id: '3',
          name: 'John Smith',
          email: 'john.smith@campus.edu',
          role: 'ta',
          department: 'Computer Science',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 90)),
          avatar: null,
        ),
        _UserModel(
          id: '4',
          name: 'Admin User',
          email: 'admin@campus.edu',
          role: 'admin',
          department: 'Administration',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 500)),
          avatar: null,
        ),
        _UserModel(
          id: '5',
          name: 'Maria Garcia',
          email: 'maria.garcia@campus.edu',
          role: 'student',
          department: 'Mathematics',
          status: 'inactive',
          joinedDate: DateTime.now().subtract(const Duration(days: 200)),
          avatar: null,
        ),
        _UserModel(
          id: '6',
          name: 'Prof. James Wilson',
          email: 'james.wilson@campus.edu',
          role: 'instructor',
          department: 'Physics',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 730)),
          avatar: null,
        ),
        _UserModel(
          id: '7',
          name: 'Emily Chen',
          email: 'emily.chen@campus.edu',
          role: 'ta',
          department: 'Chemistry',
          status: 'pending',
          joinedDate: DateTime.now().subtract(const Duration(days: 7)),
          avatar: null,
        ),
        _UserModel(
          id: '8',
          name: 'Michael Brown',
          email: 'michael.brown@campus.edu',
          role: 'student',
          department: 'Engineering',
          status: 'active',
          joinedDate: DateTime.now().subtract(const Duration(days: 45)),
          avatar: null,
        ),
      ];

      _applyFilters();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        // Role filter
        if (_selectedFilter != 'all' && user.role != _selectedFilter) {
          return false;
        }

        // Search filter
        final query = _searchController.text.toLowerCase();
        if (query.isNotEmpty) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.department.toLowerCase().contains(query);
        }

        return true;
      }).toList();

      // Sort
      _filteredUsers.sort((a, b) {
        switch (_sortBy) {
          case 'name':
            return a.name.compareTo(b.name);
          case 'email':
            return a.email.compareTo(b.email);
          case 'date':
            return b.joinedDate.compareTo(a.joinedDate);
          case 'role':
            return a.role.compareTo(b.role);
          default:
            return a.name.compareTo(b.name);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: Column(
                children: [
                  _buildAppBar(isDark, l10n),
                  _buildTabBar(isDark, l10n),
                  Expanded(child: _buildContent(isDark, l10n)),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/admin/users/add'),
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_rounded),
            label: Text(l10n.addUser),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkSurface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AdminColors.darkDivider
                : AdminColors.lightCardBorder,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.userManagement,
                      style: TextStyle(
                        color: AdminColors.getTextColor(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_users.length} ${l10n.totalUsers.toLowerCase()}',
                      style: TextStyle(
                        color: AdminColors.getTextSecondaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSortButton(isDark, l10n),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildSortButton(bool isDark, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AdminColors.darkCardBorder
                : AdminColors.lightDivider,
          ),
        ),
        child: Icon(
          Icons.sort_rounded,
          color: AdminColors.getTextSecondaryColor(isDark),
          size: 20,
        ),
      ),
      onSelected: (value) {
        setState(() {
          _sortBy = value;
          _applyFilters();
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: _sortBy == 'name' ? AdminColors.primary : null,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.name,
                style: TextStyle(
                  color: _sortBy == 'name' ? AdminColors.primary : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'email',
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 18,
                color: _sortBy == 'email' ? AdminColors.primary : null,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.email,
                style: TextStyle(
                  color: _sortBy == 'email' ? AdminColors.primary : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'date',
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: _sortBy == 'date' ? AdminColors.primary : null,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.date,
                style: TextStyle(
                  color: _sortBy == 'date' ? AdminColors.primary : null,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'role',
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 18,
                color: _sortBy == 'role' ? AdminColors.primary : null,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.role,
                style: TextStyle(
                  color: _sortBy == 'role' ? AdminColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightDivider,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        style: TextStyle(color: AdminColors.getTextColor(isDark)),
        decoration: InputDecoration(
          hintText: l10n.searchUsers,
          hintStyle: TextStyle(color: AdminColors.getTextTertiaryColor(isDark)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AdminColors.getTextTertiaryColor(isDark),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      color: isDark
          ? AdminColors.darkSurface.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.5),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AdminColors.primary,
        unselectedLabelColor: AdminColors.getTextSecondaryColor(isDark),
        indicatorColor: AdminColors.primary,
        indicatorWeight: 3,
        tabAlignment: TabAlignment.start,
        tabs: [
          _buildTab(l10n.all, _getUserCount('all')),
          _buildTab(l10n.students, _getUserCount('student')),
          _buildTab(l10n.instructors, _getUserCount('instructor')),
          _buildTab(l10n.tas, _getUserCount('ta')),
          _buildTab(l10n.admins, _getUserCount('admin')),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  int _getUserCount(String role) {
    if (role == 'all') return _users.length;
    return _users.where((u) => u.role == role).length;
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark, l10n);
    }

    if (_filteredUsers.isEmpty) {
      return _buildEmptyState(isDark, l10n);
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AdminColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          return _buildUserCard(_filteredUsers[index], isDark, l10n);
        },
      ),
    );
  }

  Widget _buildUserCard(_UserModel user, bool isDark, AppLocalizations l10n) {
    final roleColor = _getRoleColor(user.role);
    final statusColor = _getStatusColor(user.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.darkCard
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showUserDetails(user, isDark, l10n),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildUserAvatar(user, roleColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                color: AdminColors.getTextColor(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _buildStatusBadge(user.status, statusColor, isDark),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AdminColors.getTextSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleBadge(user.role, roleColor, isDark, l10n),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.business_outlined,
                            size: 14,
                            color: AdminColors.getTextTertiaryColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.department,
                              style: TextStyle(
                                color: AdminColors.getTextTertiaryColor(isDark),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(user, isDark, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(_UserModel user, Color roleColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [roleColor, roleColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(
    String role,
    Color color,
    bool isDark,
    AppLocalizations l10n,
  ) {
    String roleText;
    IconData roleIcon;

    switch (role) {
      case 'student':
        roleText = l10n.student;
        roleIcon = Icons.school_outlined;
        break;
      case 'instructor':
        roleText = l10n.instructor;
        roleIcon = Icons.person_outline;
        break;
      case 'ta':
        roleText = l10n.ta;
        roleIcon = Icons.support_agent_outlined;
        break;
      case 'admin':
        roleText = l10n.admin;
        roleIcon = Icons.admin_panel_settings_outlined;
        break;
      default:
        roleText = role;
        roleIcon = Icons.person_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            roleText,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(_UserModel user, bool isDark, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AdminColors.getTextSecondaryColor(isDark),
      ),
      onSelected: (value) => _handleUserAction(value, user, l10n),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.viewDetails),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset_password',
          child: Row(
            children: [
              const Icon(Icons.lock_reset_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.resetPassword),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AdminColors.error),
              const SizedBox(width: 8),
              Text(l10n.delete, style: TextStyle(color: AdminColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleUserAction(
    String action,
    _UserModel user,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'view':
        _showUserDetails(user, context.read<ThemeBloc>().state.isDark, l10n);
        break;
      case 'edit':
        context.push('/admin/users/edit/${user.id}');
        break;
      case 'reset_password':
        _showResetPasswordDialog(user, l10n);
        break;
      case 'delete':
        _showDeleteConfirmation(user, l10n);
        break;
    }
  }

  void _showUserDetails(_UserModel user, bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AdminColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AdminColors.darkDivider
                    : AdminColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRoleColor(user.role),
                          _getRoleColor(user.role).withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: AdminColors.getTextSecondaryColor(isDark),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleBadge(
                        user.role,
                        _getRoleColor(user.role),
                        isDark,
                        l10n,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(
                        user.status,
                        _getStatusColor(user.status),
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildDetailRow(
                      l10n.department,
                      user.department,
                      Icons.business_outlined,
                      isDark,
                    ),
                    _buildDetailRow(
                      l10n.joinedDate,
                      _formatDate(user.joinedDate),
                      Icons.calendar_today_outlined,
                      isDark,
                    ),
                    _buildDetailRow(
                      l10n.userId,
                      '#${user.id}',
                      Icons.tag_outlined,
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/admin/users/edit/${user.id}');
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.edit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.primary,
                        side: BorderSide(color: AdminColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(l10n.close),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminColors.darkDivider : AdminColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AdminColors.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AdminColors.getTextTertiaryColor(isDark),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(_UserModel user, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetPassword),
        content: Text('${l10n.resetPasswordConfirmation} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.passwordResetSent),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.resetPassword),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(_UserModel user, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteUser),
        content: Text('${l10n.deleteUserConfirmation} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.userDeleted),
                  backgroundColor: AdminColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return AdminColors.primary;
      case 'instructor':
        return AdminColors.secondary;
      case 'ta':
        return AdminColors.accent;
      case 'admin':
        return AdminColors.error;
      default:
        return AdminColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AdminColors.success;
      case 'inactive':
        return AdminColors.warning;
      case 'pending':
        return AdminColors.accent;
      default:
        return AdminColors.success;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AdminColors.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading users...',
            style: TextStyle(
              color: AdminColors.getTextSecondaryColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AdminColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: AdminColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUsersFound,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noUsersFoundDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/users/add'),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(l10n.addUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final DateTime joinedDate;
  final String? avatar;

  _UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    required this.joinedDate,
    this.avatar,
  });
}
