import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/instructor_colors.dart';

class InstructorChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const InstructorChatSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: l10n.searchConversations,
            hintStyle: TextStyle(
              color: InstructorColors.textTertiaryColor(isDark),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
              size: 20,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: InstructorColors.textTertiaryColor(isDark),
                      size: 20,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
