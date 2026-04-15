import 'package:flutter/material.dart';
import 'reports_colors.dart';

/// Export bottom sheet for reports
class ReportsExportSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onExportPDF;
  final VoidCallback onExportCSV;
  final VoidCallback onExportAll;

  const ReportsExportSheet({
    super.key,
    required this.isDark,
    required this.onExportPDF,
    required this.onExportCSV,
    required this.onExportAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ReportsColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Export options
              Row(
                children: [
                  Expanded(
                    child: _buildExportOption(
                      context,
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Export PDF',
                      onTap: () {
                        Navigator.pop(context);
                        onExportPDF();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExportOption(
                      context,
                      icon: Icons.table_chart_rounded,
                      label: 'Export CSV',
                      onTap: () {
                        Navigator.pop(context);
                        onExportCSV();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Export all button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onExportAll();
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Export All Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ReportsColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? ReportsColors.darkSurface : ReportsColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ReportsColors.borderColor(isDark)),
        ),
        child: Column(
          children: [
            Icon(icon, color: ReportsColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: ReportsColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
