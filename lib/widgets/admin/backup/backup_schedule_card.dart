import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class BackupScheduleCard extends StatelessWidget {
  final bool isDark;
  final bool autoBackupEnabled;
  final String backupFrequency;
  final int retentionDays;
  final String nextBackupTime;
  final ValueChanged<bool> onAutoBackupChanged;
  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<int> onRetentionChanged;

  const BackupScheduleCard({
    super.key,
    required this.isDark,
    required this.autoBackupEnabled,
    required this.backupFrequency,
    required this.retentionDays,
    required this.nextBackupTime,
    required this.onAutoBackupChanged,
    required this.onFrequencyChanged,
    required this.onRetentionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  gradient: AdminColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.automaticBackups,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.scheduleAutomaticBackups,
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.getTextColor(
                          isDark,
                        ).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoBackupEnabled,
                onChanged: onAutoBackupChanged,
                activeColor: AdminColors.primary,
              ),
            ],
          ),
          if (autoBackupEnabled) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AdminColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AdminColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${l10n.nextBackup}: $nextBackupTime',
                      style: TextStyle(
                        fontSize: 13,
                        color: AdminColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.frequency,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFrequencyChip(context, 'hourly', l10n.hourly),
                _buildFrequencyChip(context, 'daily', l10n.daily),
                _buildFrequencyChip(context, 'weekly', l10n.weekly),
                _buildFrequencyChip(context, 'monthly', l10n.monthly),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.retentionPeriod,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.keepBackupsFor,
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.getTextColor(
                            isDark,
                          ).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: retentionDays,
                      isDense: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AdminColors.getTextColor(isDark),
                      ),
                      dropdownColor: AdminColors.getCardColor(isDark),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.getTextColor(isDark),
                      ),
                      items: [7, 14, 30, 60, 90]
                          .map(
                            (days) => DropdownMenuItem(
                              value: days,
                              child: Text('$days ${l10n.days}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onRetentionChanged(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(BuildContext context, String value, String label) {
    final isSelected = backupFrequency == value;
    return GestureDetector(
      onTap: () => onFrequencyChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AdminColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AdminColors.getTextColor(isDark),
          ),
        ),
      ),
    );
  }
}
