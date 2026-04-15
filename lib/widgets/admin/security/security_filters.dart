import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

enum ActivityType {
  all,
  login,
  logout,
  passwordChange,
  roleChange,
  dataAccess,
  systemChange,
}

enum UserRoleFilter { all, admin, instructor, ta, student }

enum DateRangeFilter { today, lastWeek, lastMonth, custom }

class SecurityFilters extends StatelessWidget {
  final bool isDark;
  final String searchQuery;
  final ActivityType activityType;
  final UserRoleFilter userRole;
  final DateRangeFilter dateRange;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ActivityType> onActivityTypeChanged;
  final ValueChanged<UserRoleFilter> onUserRoleChanged;
  final ValueChanged<DateRangeFilter> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const SecurityFilters({
    super.key,
    required this.isDark,
    required this.searchQuery,
    required this.activityType,
    required this.userRole,
    required this.dateRange,
    required this.onSearchChanged,
    required this.onActivityTypeChanged,
    required this.onUserRoleChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchField(l10n),
          const SizedBox(height: 16),
          // Filter Dropdowns
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActivityTypeDropdown(l10n),
                const SizedBox(width: 12),
                _buildUserRoleDropdown(l10n),
                const SizedBox(width: 12),
                _buildDateRangeDropdown(l10n),
                const SizedBox(width: 12),
                _buildClearButton(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getDividerColor(isDark)),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(color: AdminColors.getTextColor(isDark), fontSize: 14),
        decoration: InputDecoration(
          hintText: l10n.searchActivityLogs,
          hintStyle: TextStyle(
            color: AdminColors.getTextTertiaryColor(isDark),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTypeDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.getDividerColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ActivityType>(
          value: activityType,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          dropdownColor: AdminColors.getCardColor(isDark),
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 13,
          ),
          items: ActivityType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getActivityTypeLabel(type, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onActivityTypeChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildUserRoleDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.getDividerColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRoleFilter>(
          value: userRole,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          dropdownColor: AdminColors.getCardColor(isDark),
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 13,
          ),
          items: UserRoleFilter.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(_getUserRoleLabel(role, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onUserRoleChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateRangeDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkSurface : AdminColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminColors.getDividerColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateRangeFilter>(
          value: dateRange,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AdminColors.getTextTertiaryColor(isDark),
            size: 20,
          ),
          dropdownColor: AdminColors.getCardColor(isDark),
          style: TextStyle(
            color: AdminColors.getTextColor(isDark),
            fontSize: 13,
          ),
          items: DateRangeFilter.values.map((range) {
            return DropdownMenuItem(
              value: range,
              child: Text(_getDateRangeLabel(range, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onDateRangeChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildClearButton(AppLocalizations l10n) {
    return InkWell(
      onTap: onClearFilters,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AdminColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_rounded, size: 16, color: AdminColors.error),
            const SizedBox(width: 6),
            Text(
              l10n.clearFilters,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AdminColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getActivityTypeLabel(ActivityType type, AppLocalizations l10n) {
    switch (type) {
      case ActivityType.all:
        return l10n.allActivities;
      case ActivityType.login:
        return l10n.loginActivity;
      case ActivityType.logout:
        return l10n.logoutActivity;
      case ActivityType.passwordChange:
        return l10n.passwordChangeActivity;
      case ActivityType.roleChange:
        return l10n.roleChangeActivity;
      case ActivityType.dataAccess:
        return l10n.dataAccessActivity;
      case ActivityType.systemChange:
        return l10n.systemChangeActivity;
    }
  }

  String _getUserRoleLabel(UserRoleFilter role, AppLocalizations l10n) {
    switch (role) {
      case UserRoleFilter.all:
        return l10n.allRoles;
      case UserRoleFilter.admin:
        return l10n.admin;
      case UserRoleFilter.instructor:
        return l10n.instructor;
      case UserRoleFilter.ta:
        return l10n.teachingAssistant;
      case UserRoleFilter.student:
        return l10n.student;
    }
  }

  String _getDateRangeLabel(DateRangeFilter range, AppLocalizations l10n) {
    switch (range) {
      case DateRangeFilter.today:
        return l10n.today;
      case DateRangeFilter.lastWeek:
        return l10n.lastWeek;
      case DateRangeFilter.lastMonth:
        return l10n.lastMonth;
      case DateRangeFilter.custom:
        return l10n.custom;
    }
  }
}
