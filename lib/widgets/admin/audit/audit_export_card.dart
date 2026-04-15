import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AuditExportCard extends StatelessWidget {
  final bool isDark;
  final String selectedFormat;
  final bool includeDetails;
  final bool isExporting;
  final ValueChanged<String> onFormatChanged;
  final ValueChanged<bool> onIncludeDetailsChanged;
  final VoidCallback onExport;
  final VoidCallback onScheduleReport;

  const AuditExportCard({
    super.key,
    required this.isDark,
    required this.selectedFormat,
    required this.includeDetails,
    required this.isExporting,
    required this.onFormatChanged,
    required this.onIncludeDetailsChanged,
    required this.onExport,
    required this.onScheduleReport,
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
                  gradient: AdminColors.greenGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.file_download_rounded,
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
                      l10n.exportReport,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.exportAuditData,
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
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.exportFormat,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.getTextColor(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildFormatChip('pdf', 'PDF', Icons.picture_as_pdf_rounded),
              _buildFormatChip('csv', 'CSV', Icons.table_chart_rounded),
              _buildFormatChip('excel', 'Excel', Icons.grid_on_rounded),
              _buildFormatChip('json', 'JSON', Icons.code_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.includeDetailedInfo,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.includeIpUserAgent,
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
                Switch(
                  value: includeDetails,
                  onChanged: onIncludeDetailsChanged,
                  activeColor: AdminColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isExporting ? null : onExport,
                  icon: isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(isExporting ? l10n.exporting : l10n.exportNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onScheduleReport,
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(l10n.scheduleReport),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AdminColors.primary),
                    foregroundColor: AdminColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String value, String label, IconData icon) {
    final isSelected = selectedFormat == value;
    return GestureDetector(
      onTap: () => onFormatChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AdminColors.greenGradient : null,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : AdminColors.getTextColor(isDark),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : AdminColors.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
