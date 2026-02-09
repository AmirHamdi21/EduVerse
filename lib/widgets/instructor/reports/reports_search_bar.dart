import 'package:flutter/material.dart';
import 'reports_colors.dart';

/// Search bar for filtering students in reports
class ReportsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ReportsSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ReportsColors.borderColor(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: ReportsColors.textPrimaryColor(isDark),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: ReportsColors.textTertiaryColor(isDark),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ReportsColors.textTertiaryColor(isDark),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: ReportsColors.textTertiaryColor(isDark),
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Selection header showing count and export button
class ReportsSelectionHeader extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onExport;
  final bool isDark;

  const ReportsSelectionHeader({
    super.key,
    required this.selectedCount,
    required this.onExport,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? ReportsColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ReportsColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            selectedCount > 0
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            color: selectedCount > 0
                ? ReportsColors.primary
                : ReportsColors.textTertiaryColor(isDark),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount selected',
            style: TextStyle(
              color: ReportsColors.textSecondaryColor(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onExport,
            icon: Icon(
              Icons.download_rounded,
              size: 18,
              color: ReportsColors.primary,
            ),
            label: Text(
              'Export',
              style: TextStyle(
                color: ReportsColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
