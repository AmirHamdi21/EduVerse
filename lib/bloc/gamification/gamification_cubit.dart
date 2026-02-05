import 'package:flutter_bloc/flutter_bloc.dart';
import 'gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit() : super(const GamificationState()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final userProfile = UserProfile(
        id: 'user_1',
        name: 'Alex Doe',
        avatarUrl: '',
        level: '8',
        levelTitle: 'Silver Learner',
        currentXp: 2480,
        xpToNextRank: 3000,
        progressToNextRank: 0.75,
        rank: 14,
        rankPercentile: 'Top 10%',
      );

      final badges = _getMockBadges();
      final leaderboard = _getMockLeaderboard();
      final rewards = _getMockRewards();

      emit(state.copyWith(
        isLoading: false,
        userProfile: userProfile,
        badges: badges,
        filteredBadges: badges,
        leaderboard: leaderboard,
        filteredLeaderboard: leaderboard,
        rewards: rewards,
        userCoins: 850,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void setTimeFilter(TimeFilter filter) {
    emit(state.copyWith(timeFilter: filter));
    _refreshLeaderboard();
  }

  void setLeaderboardFilter(LeaderboardFilter filter) {
    emit(state.copyWith(leaderboardFilter: filter));
    _refreshLeaderboard();
  }

  void searchLeaderboard(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      emit(state.copyWith(filteredLeaderboard: state.leaderboard));
    } else {
      final filtered = state.leaderboard
          .where((entry) =>
              entry.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(state.copyWith(filteredLeaderboard: filtered));
    }
  }

  void toggleCompareMode() {
    emit(state.copyWith(
      isComparing: !state.isComparing,
      compareUsers: state.isComparing ? [] : state.compareUsers,
    ));
  }

  void toggleCompareUser(LeaderboardEntry user) {
    final currentUsers = List<LeaderboardEntry>.from(state.compareUsers);
    
    if (currentUsers.any((u) => u.id == user.id)) {
      currentUsers.removeWhere((u) => u.id == user.id);
    } else if (currentUsers.length < 3) {
      currentUsers.add(user);
    } else {
      emit(state.copyWith(
        successMessage: 'Maximum 3 users can be compared',
      ));
      _clearSuccessMessage();
      return;
    }

    emit(state.copyWith(compareUsers: currentUsers));
  }

  void purchaseReward(Reward reward) {
    if (state.userCoins < reward.cost) {
      emit(state.copyWith(
        error: 'Not enough coins',
      ));
      return;
    }

    final updatedRewards = state.rewards.map((r) {
      if (r.id == reward.id) {
        return r.copyWith(isOwned: true);
      }
      return r;
    }).toList();

    emit(state.copyWith(
      rewards: updatedRewards,
      userCoins: state.userCoins - reward.cost,
      successMessage: 'Reward purchased successfully!',
    ));
    _clearSuccessMessage();
  }

  void claimDailyReward() {
    final newCoins = state.userCoins + 50;
    final newXp = (state.userProfile?.currentXp ?? 0) + 25;
    
    emit(state.copyWith(
      userCoins: newCoins,
      userProfile: state.userProfile?.copyWith(currentXp: newXp),
      successMessage: 'Daily reward claimed! +50 coins, +25 XP',
    ));
    _clearSuccessMessage();
  }

  void shareProgress() {
    emit(state.copyWith(
      successMessage: 'Progress shared successfully!',
    ));
    _clearSuccessMessage();
  }

  void _refreshLeaderboard() {
    // Simulate different data based on filters
    final baseLeaderboard = _getMockLeaderboard();
    
    List<LeaderboardEntry> filtered;
    switch (state.leaderboardFilter) {
      case LeaderboardFilter.perCourse:
        filtered = baseLeaderboard.take(8).toList();
      case LeaderboardFilter.friends:
        filtered = baseLeaderboard.where((e) => 
          e.name == 'Sofia' || e.name == 'Ken' || e.isCurrentUser
        ).toList();
      case LeaderboardFilter.global:
        filtered = baseLeaderboard;
    }

    // Apply search if any
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((entry) =>
              entry.name.toLowerCase().contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    emit(state.copyWith(filteredLeaderboard: filtered));
  }

  void _clearSuccessMessage() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(clearSuccess: true));
      }
    });
  }

  List<AchievementBadge> _getMockBadges() {
    return [
      const AchievementBadge(
        id: 'badge_1',
        name: 'Consistency Master',
        description: 'Study for 7 consecutive days',
        iconName: 'consistency',
        isUnlocked: true,
        requiredXp: 500,
        category: BadgeCategory.consistency,
      ),
      const AchievementBadge(
        id: 'badge_2',
        name: 'Quiz Champion',
        description: 'Score 100% on 5 quizzes',
        iconName: 'quiz',
        isUnlocked: true,
        requiredXp: 750,
        category: BadgeCategory.quiz,
      ),
      const AchievementBadge(
        id: 'badge_3',
        name: 'Fast Learner',
        description: 'Complete 10 lessons in a day',
        iconName: 'fast',
        isUnlocked: true,
        requiredXp: 600,
        category: BadgeCategory.learning,
      ),
      const AchievementBadge(
        id: 'badge_4',
        name: 'Top Performer',
        description: 'Reach top 10 in leaderboard',
        iconName: 'top',
        isUnlocked: false,
        requiredXp: 1000,
        category: BadgeCategory.performance,
      ),
      const AchievementBadge(
        id: 'badge_5',
        name: 'Rising Star',
        description: 'Gain 500 XP in a week',
        iconName: 'star',
        isUnlocked: false,
        requiredXp: 800,
        category: BadgeCategory.performance,
      ),
      const AchievementBadge(
        id: 'badge_6',
        name: 'AI Master',
        description: 'Use AI features 50 times',
        iconName: 'ai',
        isUnlocked: false,
        requiredXp: 1200,
        category: BadgeCategory.ai,
      ),
    ];
  }

  List<LeaderboardEntry> _getMockLeaderboard() {
    return [
      const LeaderboardEntry(
        id: 'leader_1',
        name: 'Sofia',
        avatarUrl: '',
        levelTitle: 'Diamond Learner',
        xp: 3120,
        rank: 1,
      ),
      const LeaderboardEntry(
        id: 'leader_2',
        name: 'Ken',
        avatarUrl: '',
        levelTitle: 'Platinum Learner',
        xp: 2980,
        rank: 2,
      ),
      const LeaderboardEntry(
        id: 'leader_3',
        name: 'Chloe',
        avatarUrl: '',
        levelTitle: 'Gold Learner',
        xp: 2750,
        rank: 3,
      ),
      const LeaderboardEntry(
        id: 'leader_4',
        name: 'Emma',
        avatarUrl: '',
        levelTitle: 'Gold Learner',
        xp: 2700,
        rank: 4,
      ),
      const LeaderboardEntry(
        id: 'leader_5',
        name: 'James',
        avatarUrl: '',
        levelTitle: 'Gold Learner',
        xp: 2650,
        rank: 5,
      ),
      const LeaderboardEntry(
        id: 'leader_6',
        name: 'Olivia',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2600,
        rank: 6,
      ),
      const LeaderboardEntry(
        id: 'leader_7',
        name: 'Liam',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2550,
        rank: 7,
      ),
      const LeaderboardEntry(
        id: 'leader_8',
        name: 'Ava',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2520,
        rank: 8,
      ),
      const LeaderboardEntry(
        id: 'leader_9',
        name: 'Noah',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2510,
        rank: 9,
      ),
      const LeaderboardEntry(
        id: 'leader_10',
        name: 'Mia',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2500,
        rank: 10,
      ),
      const LeaderboardEntry(
        id: 'leader_11',
        name: 'William',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2495,
        rank: 11,
      ),
      const LeaderboardEntry(
        id: 'leader_12',
        name: 'Isabella',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2490,
        rank: 12,
      ),
      const LeaderboardEntry(
        id: 'leader_13',
        name: 'Lucas',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2485,
        rank: 13,
      ),
      const LeaderboardEntry(
        id: 'user_1',
        name: 'You',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2480,
        rank: 14,
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        id: 'leader_15',
        name: 'Ahmed',
        avatarUrl: '',
        levelTitle: 'Silver Learner',
        xp: 2330,
        rank: 15,
      ),
    ];
  }

  List<Reward> _getMockRewards() {
    return [
      const Reward(
        id: 'reward_1',
        name: 'Golden Avatar Frame',
        description: 'A shiny golden frame for your avatar',
        iconName: 'frame',
        cost: 500,
        isOwned: false,
        category: RewardCategory.avatar,
      ),
      const Reward(
        id: 'reward_2',
        name: 'Dark Theme Pro',
        description: 'Unlock premium dark theme',
        iconName: 'theme',
        cost: 300,
        isOwned: true,
        category: RewardCategory.theme,
      ),
      const Reward(
        id: 'reward_3',
        name: 'Custom Badge',
        description: 'Create your own badge',
        iconName: 'badge',
        cost: 1000,
        isOwned: false,
        category: RewardCategory.badge,
      ),
      const Reward(
        id: 'reward_4',
        name: 'Priority Support',
        description: 'Get priority customer support',
        iconName: 'support',
        cost: 750,
        isOwned: false,
        category: RewardCategory.feature,
      ),
    ];
  }
}
