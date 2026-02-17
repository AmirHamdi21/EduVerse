import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class DepartmentHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddDepartment;
  final VoidCallback? onSettings;

  const DepartmentHeader({
    super.key,
    required this.isDark,
    required this.onAddDepartment,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 20, top: 30, bottom: 30),
      decoration: BoxDecoration(
        gradient: AdminColors.primaryGradient,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primary.withValues(alpha: 0.3),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.departmentsAndPrograms ?? 'Departments & Programs',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.organizeAcademicStructures ??
                      'Organize academic structures across the institution',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.add_rounded,
                onTap: onAddDepartment,
                isPrimary: true,
              ),
              if (onSettings != null) ...[
                const SizedBox(width: 12),
                _buildHeaderButton(
                  icon: Icons.settings_outlined,
                  onTap: onSettings!,
                  isPrimary: false,
                ),
              ],
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
            color: isPrimary ? AdminColors.primary : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
