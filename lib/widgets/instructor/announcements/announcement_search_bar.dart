import 'package:flutter/material.dart';
import 'announcement_colors.dart';

class AnnouncementSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hintText;
  final VoidCallback? onClear;

  const AnnouncementSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.hintText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AnnouncementColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AnnouncementColors.darkBorder.withOpacity(0.3)
              : AnnouncementColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : AnnouncementColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AnnouncementColors.textPrimaryColor(isDark),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AnnouncementColors.textTertiaryColor(isDark),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AnnouncementColors.textTertiaryColor(isDark),
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: AnnouncementColors.textTertiaryColor(isDark),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
