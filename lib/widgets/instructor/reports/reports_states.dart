import 'package:flutter/material.dart';
import 'reports_colors.dart';

/// Loading state skeleton for reports
class ReportsLoadingState extends StatelessWidget {
  final bool isDark;
  final String? message;

  const ReportsLoadingState({
    super.key,
    required this.isDark,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: ReportsColors.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: ReportsColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state for reports
class ReportsErrorState extends StatelessWidget {
  final bool isDark;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ReportsErrorState({
    super.key,
    required this.isDark,
    required this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ReportsColors.atRiskLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: ReportsColors.atRisk,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: ReportsColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  color: ReportsColors.textSecondaryColor(isDark),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportsColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for reports
class ReportsEmptyState extends StatelessWidget {
  final bool isDark;
  final String title;
  final String? subtitle;
  final IconData icon;

  const ReportsEmptyState({
    super.key,
    required this.isDark,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? ReportsColors.darkSurface
                    : ReportsColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: ReportsColors.textTertiaryColor(isDark),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: ReportsColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  color: ReportsColors.textSecondaryColor(isDark),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
