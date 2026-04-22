import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AccessControl {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final IconData icon;
  final Color color;

  const AccessControl({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.icon,
    required this.color,
  });
}

class AccessControlsCard extends StatelessWidget {
  final bool isDark;
  final List<AccessControl> controls;
  final Function(AccessControl, bool) onToggle;
  final VoidCallback onManage;

  const AccessControlsCard({
    super.key,
    required this.isDark,
    required this.controls,
    required this.onToggle,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AdminColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accessControls,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    Text(
                      l10n.accessControlsDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.getTextSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onManage,
                icon: Icon(Icons.settings_rounded, size: 18),
                label: Text(l10n.manage),
                style: TextButton.styleFrom(
                  foregroundColor: AdminColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...controls.map((control) => _buildControlItem(control, l10n)),
        ],
      ),
    );
  }

  Widget _buildControlItem(AccessControl control, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : AdminColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: control.isEnabled
                ? control.color.withValues(alpha: 0.3)
                : AdminColors.getCardBorderColor(isDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: control.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(control.icon, color: control.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    control.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    control.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: control.isEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                onToggle(control, value);
              },
              activeTrackColor: control.color,
              activeColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
