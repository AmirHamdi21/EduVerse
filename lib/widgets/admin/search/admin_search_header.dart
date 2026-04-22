import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminSearchHeader extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final VoidCallback onBack;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const AdminSearchHeader({
    super.key,
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
    required this.onBack,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: focusNode.hasFocus
                      ? AdminColors.primary
                      : (isDark
                            ? AdminColors.darkCardBorder
                            : AdminColors.lightCardBorder),
                  width: focusNode.hasFocus ? 2 : 1,
                ),
                boxShadow: focusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AdminColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onSearch,
                style: TextStyle(
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search users, courses, settings...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AdminColors.darkTextTertiary
                        : AdminColors.lightTextTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AdminColors.darkTextSecondary
                        : AdminColors.lightTextSecondary,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark
                                ? AdminColors.darkTextSecondary
                                : AdminColors.lightTextSecondary,
                          ),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 8),
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: hasActiveFilters
                        ? AdminColors.primary
                        : (isDark
                              ? AdminColors.darkTextSecondary
                              : AdminColors.lightTextSecondary),
                  ),
                  onPressed: onFilterTap,
                ),
                if (hasActiveFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AdminColors.primary,
                        shape: BoxShape.circle,
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
}
