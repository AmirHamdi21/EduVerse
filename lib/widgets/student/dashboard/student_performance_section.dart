import 'package:edu_verse/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class StudentPerformanceSection extends StatelessWidget {
  const StudentPerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceInsights,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101727),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              icon: Icons.psychology,
              title_topic: l10n.weakTopic,
              title: l10n.recursion,
              subtitle:
                  '${l10n.tryReviewing} "${l10n.recursion}" — ${l10n.chapter} 5 ${l10n.problems}',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              icon: Icons.access_time,
              title_topic: l10n.studySuggestion,
              title: l10n.peakLearningTime,
              subtitle:
                  '${l10n.youPerform} ${l10n.studying} ${l10n.inTheMorning}',
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title_topic,
    required String title,
    required String subtitle,
    required bool isDark,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF16213E) : const Color(0xffDEEAFE),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E7EB),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF155CFB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? const Color(0xFF51A2FF) : const Color(0xFF155DFC),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title_topic,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF51A2FF)
                        : const Color(0xFF155DFC),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF495565),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
