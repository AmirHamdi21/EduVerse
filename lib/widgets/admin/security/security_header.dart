import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class SecurityHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onExport;
  final VoidCallback onSettings;

  const SecurityHeader({
    super.key,
    required this.isDark,
    required this.onExport,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 20, top: 30, bottom: 30),
      decoration: BoxDecoration(
        gradient: AdminColors.secondaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AdminColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          // const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityAndActivityLogs,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.monitorSecurityEvents,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                onTap: onSettings,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              _buildHeaderButton(
                icon: Icons.file_download_outlined,
                onTap: onExport,
                isPrimary: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isPrimary ? AdminColors.secondary : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
