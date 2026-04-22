import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class InstructorNotificationsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final ValueChanged<String> onChanged;

  const InstructorNotificationsSearchBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: TextStyle(
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textLight,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: isDarkMode ? AppTheme.darkCardColor : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
