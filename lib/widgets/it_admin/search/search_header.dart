import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSearchHeader extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onBack;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const ITSearchHeader({
    super.key,
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onBack,
    required this.onClear,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ITColors.textPrimaryColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ITColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: focusNode.hasFocus
                      ? ITColors.primary
                      : ITColors.borderColor(isDark),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: ITColors.textTertiaryColor(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: ITColors.textSecondaryColor(isDark),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: onClear,
                          icon: Icon(
                            Icons.close_rounded,
                            color: ITColors.textSecondaryColor(isDark),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: ITColors.textPrimaryColor(isDark),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onFilterTap,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: ITColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
