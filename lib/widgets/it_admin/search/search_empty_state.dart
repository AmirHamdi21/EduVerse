import 'package:flutter/material.dart';
import '../shared/it_colors.dart';

class ITSearchEmptyState extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;

  const ITSearchEmptyState({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: ITColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: ITColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: ITColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
