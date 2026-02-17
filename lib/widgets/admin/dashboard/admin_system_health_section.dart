import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class AdminSystemHealthSection extends StatelessWidget {
  const AdminSystemHealthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AdminColors.darkCard.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AdminColors.darkCardBorder
                  : AdminColors.lightCardBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monitor_heart_rounded,
                    color: AdminColors.getTextColor(isDark),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.systemHealth,
                    style: TextStyle(
                      color: AdminColors.getTextColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProgressBar(
                isDark: isDark,
                label: l10n.serverLoad,
                value: 0.45,
                percentage: '45%',
                color: AdminColors.warning,
              ),
              const SizedBox(height: 16),
              _buildProgressBar(
                isDark: isDark,
                label: l10n.apiPerformance,
                value: 0.92,
                percentage: '92%',
                color: AdminColors.success,
              ),
              const SizedBox(height: 16),
              _buildProgressBar(
                isDark: isDark,
                label: l10n.database,
                value: 0.78,
                percentage: '78%',
                color: AdminColors.primary,
              ),
              const SizedBox(height: 16),
              _buildProgressBar(
                isDark: isDark,
                label: l10n.aiProcessing,
                value: 0.65,
                percentage: '65%',
                color: AdminColors.primary,
              ),
              const SizedBox(height: 20),
              Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              _buildStatusRow(
                isDark: isDark,
                label: l10n.systemUptime,
                value: '99.8%',
                isSuccess: true,
              ),
              const SizedBox(height: 8),
              _buildStatusRow(
                isDark: isDark,
                label: l10n.errorRate,
                value: '0.2%',
                isSuccess: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar({
    required bool isDark,
    required String label,
    required double value,
    required String percentage,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AdminColors.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required bool isDark,
    required String label,
    required String value,
    required bool isSuccess,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AdminColors.getTextSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSuccess
                ? AdminColors.success.withOpacity(0.2)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFECEEF2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isSuccess
                  ? AdminColors.success
                  : AdminColors.getTextColor(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
