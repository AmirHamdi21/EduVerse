import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/bloc/gamification/gamification_cubit.dart';
import 'package:edu_verse/bloc/gamification/gamification_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/student/gamification/gamification_app_bar.dart';
import 'package:edu_verse/widgets/student/gamification/user_profile_card.dart';
import 'package:edu_verse/widgets/student/gamification/achievements_section.dart';
import 'package:edu_verse/widgets/student/gamification/leaderboard_section.dart';
import 'package:edu_verse/widgets/student/gamification/motivation_card.dart';
import 'package:edu_verse/widgets/student/gamification/rewards_sheet.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GamificationCubit(),
      child: const _GamificationView(),
    );
  }
}

class _GamificationView extends StatelessWidget {
  const _GamificationView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeBloc>().state;
    final isDark = themeState.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF9FAFB),
      body: BlocConsumer<GamificationCubit, GamificationState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2B7FFF)),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                GamificationAppBar(
                  timeFilter: state.timeFilter,
                  onFilterChanged: (filter) {
                    context.read<GamificationCubit>().setTimeFilter(filter);
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        context.read<GamificationCubit>().loadData(),
                    color: const Color(0xFF2B7FFF),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildHeader(context, l10n, isDark),
                          const SizedBox(height: 20),
                          if (state.userProfile != null)
                            UserProfileCard(profile: state.userProfile!),
                          const SizedBox(height: 24),
                          AchievementsSection(badges: state.filteredBadges),
                          const SizedBox(height: 24),
                          LeaderboardSection(
                            entries: state.filteredLeaderboard,
                            filter: state.leaderboardFilter,
                            searchQuery: state.searchQuery,
                            isComparing: state.isComparing,
                            compareUsers: state.compareUsers,
                            onFilterChanged: (filter) {
                              context
                                  .read<GamificationCubit>()
                                  .setLeaderboardFilter(filter);
                            },
                            onSearch: (query) {
                              context
                                  .read<GamificationCubit>()
                                  .searchLeaderboard(query);
                            },
                            onToggleCompare: () {
                              context
                                  .read<GamificationCubit>()
                                  .toggleCompareMode();
                            },
                            onUserSelected: (user) {
                              context
                                  .read<GamificationCubit>()
                                  .toggleCompareUser(user);
                            },
                          ),
                          const SizedBox(height: 20),
                          const MotivationCard(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomButton(context, l10n, isDark),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.gamificationTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.gamificationSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => _showRewardsSheet(context),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.viewRewardsShop,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRewardsSheet(BuildContext context) {
    final cubit = context.read<GamificationCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          BlocProvider.value(value: cubit, child: const RewardsSheet()),
    );
  }
}
