import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';

class StudentStatsSection extends StatelessWidget {
  const StudentStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return SizedBox(
          height: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${l10n.goodEvening}, Amir 👋',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101727),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: l10n.gpa,
                value: '3.62',
                isDark: isDark,
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: l10n.semesterProgress,
                value: '67',
                isDark: isDark,
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              _upComingCard(
                title: l10n.upcomingDeadline,
                value: 'Nov 12, 2025',
                isDark: isDark,
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: l10n.attendance,
                value: '100',
                isDark: isDark,
                l10n: l10n,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF495565),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value +
                ((title == l10n.gpa || title == l10n.upcomingDeadline)
                    ? ''
                    : '%'),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101727),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          title != l10n.upcomingDeadline
              ? LinearProgressIndicator(
                  value: title == l10n.gpa
                      ? (double.parse(value) / 4.0)
                      : double.parse(value) / 100,

                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    title == l10n.gpa
                        ? double.parse(value) / 4.0 != 1.0
                              ? const Color(0xFF155CFB)
                              : const Color(0xFF22C55E)
                        : double.parse(value) / 100 != 1.0
                        ? const Color(0xFF155CFB)
                        : const Color(0xFF22C55E),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _upComingCard({
    required String title,
    required String value,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF495565),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF51A2FF).withOpacity(0.1)
                      : const Color(0xFF155DFC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: isDark
                      ? const Color(0xFF51A2FF)
                      : const Color(0xFF155DFC),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF101727),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.calculusII + ' ' + l10n.exam,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF495565),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
