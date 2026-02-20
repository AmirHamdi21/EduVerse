import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITBackupTabSection extends StatelessWidget {
  final bool isDark;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const ITBackupTabSection({
    super.key,
    required this.isDark,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.backup_rounded, 'label': 'Backup Jobs'},
      {'icon': Icons.restore_rounded, 'label': 'Restore'},
      {'icon': Icons.menu_book_rounded, 'label': 'DR Runbooks'},
      {'icon': Icons.verified_rounded, 'label': 'Integrity'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : ITColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final tab = tabs[index];
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ITColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: ITColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : ITColors.textTertiaryColor(isDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : ITColors.textSecondaryColor(isDark),
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
