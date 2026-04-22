import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminSettingsSearchDelegate extends SearchDelegate<String> {
  final bool isDark;
  final AppLocalizations l10n;

  AdminSettingsSearchDelegate({required this.isDark, required this.l10n})
    : super(
        searchFieldLabel: 'Search settings...',
        searchFieldStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AdminColors.darkBackground
            : AdminColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
      ),
      scaffoldBackgroundColor: isDark
          ? AdminColors.darkBackground
          : AdminColors.lightBackground,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        color: isDark ? Colors.white : Colors.black87,
      ),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final settingsOptions = [
      _SearchItem(
        icon: Icons.tune_rounded,
        title: l10n.generalSettings,
        subtitle: l10n.generalSettingsDesc,
        route: '/admin/settings/general',
      ),
      _SearchItem(
        icon: Icons.people_outline_rounded,
        title: l10n.userManagement,
        subtitle: l10n.userManagementSettingsDesc,
        route: '/admin/users',
      ),
      _SearchItem(
        icon: Icons.security_outlined,
        title: l10n.securityPolicies,
        subtitle: l10n.securityPoliciesDesc,
        route: '/admin/settings/security',
      ),
      _SearchItem(
        icon: Icons.email_outlined,
        title: l10n.emailConfiguration,
        subtitle: l10n.emailConfigurationDesc,
        route: '/admin/settings/email',
      ),
      _SearchItem(
        icon: Icons.palette_outlined,
        title: l10n.appearance,
        subtitle: l10n.appearanceSettingsDesc,
        route: '/admin/settings/appearance',
      ),
      _SearchItem(
        icon: Icons.language_rounded,
        title: l10n.language,
        subtitle: l10n.languageSettingsDesc,
        route: '/admin/settings/language',
      ),
      _SearchItem(
        icon: Icons.backup_outlined,
        title: l10n.backupRestore,
        subtitle: l10n.backupRestoreDesc,
        route: '/admin/settings/backup',
      ),
      _SearchItem(
        icon: Icons.api_rounded,
        title: l10n.apiManagement,
        subtitle: l10n.apiManagementDesc,
        route: '/admin/settings/api',
      ),
      _SearchItem(
        icon: Icons.build_circle_outlined,
        title: l10n.maintenanceMode,
        subtitle: l10n.maintenanceModeDesc,
        route: '/admin/settings/maintenance',
      ),
      _SearchItem(
        icon: Icons.integration_instructions_outlined,
        title: l10n.integrations,
        subtitle: l10n.integrationsDesc,
        route: '/admin/settings/integrations',
      ),
      _SearchItem(
        icon: Icons.notifications_outlined,
        title: l10n.notificationSettings,
        subtitle: l10n.notificationSettingsDesc,
        route: '/admin/settings/notifications',
      ),
    ];

    final filteredOptions = query.isEmpty
        ? settingsOptions
        : settingsOptions
              .where(
                (item) =>
                    item.title.toLowerCase().contains(query.toLowerCase()) ||
                    item.subtitle.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    if (filteredOptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AdminColors.getTextTertiaryColor(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOptions.length,
      itemBuilder: (context, index) {
        final item = filteredOptions[index];
        return _buildSearchItem(context, item);
      },
    );
  }

  Widget _buildSearchItem(BuildContext context, _SearchItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: ListTile(
        onTap: () => close(context, item.route),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AdminColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 20, color: Colors.white),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AdminColors.getTextColor(isDark),
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AdminColors.getTextSecondaryColor(isDark),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AdminColors.getTextTertiaryColor(isDark),
        ),
      ),
    );
  }
}

class _SearchItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _SearchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
