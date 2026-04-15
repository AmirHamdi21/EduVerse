import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/gamification/gamification_cubit.dart';
import 'package:edu_verse/bloc/gamification/gamification_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';

class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return BlocBuilder<GamificationCubit, GamificationState>(
      builder: (context, state) {
        final nextUser = state.leaderboard
            .where(
              (e) =>
                  !e.isCurrentUser &&
                  e.rank == (state.userProfile?.rank ?? 0) - 1,
            )
            .firstOrNull;

        final xpDifference = nextUser != null
            ? nextUser.xp - (state.userProfile?.currentXp ?? 0)
            : 150;

        final nextName = nextUser?.name ?? 'Ahmed';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF2B7FFF).withValues(alpha: 0.2),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    ]
                  : [const Color(0xFFEFF6FF), const Color(0xFFF5F3FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2B7FFF).withValues(alpha: 0.3)
                  : const Color(0xFF2B7FFF).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.keepItUp,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                        children: [
                          TextSpan(text: '${l10n.youreOnly} '),
                          TextSpan(
                            text: '$xpDifference XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B7FFF),
                            ),
                          ),
                          TextSpan(text: ' ${l10n.awayFromSurpassing} '),
                          TextSpan(
                            text: nextName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const TextSpan(text: '!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
