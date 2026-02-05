import 'package:equatable/equatable.dart';

// Models
class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final String level;
  final String levelTitle;
  final int currentXp;
  final int xpToNextRank;
  final double progressToNextRank;
  final int rank;
  final String rankPercentile;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.levelTitle,
    required this.currentXp,
    required this.xpToNextRank,
    required this.progressToNextRank,
    required this.rank,
    required this.rankPercentile,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? level,
    String? levelTitle,
    int? currentXp,
    int? xpToNextRank,
    double? progressToNextRank,
    int? rank,
    String? rankPercentile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      currentXp: currentXp ?? this.currentXp,
      xpToNextRank: xpToNextRank ?? this.xpToNextRank,
      progressToNextRank: progressToNextRank ?? this.progressToNextRank,
      rank: rank ?? this.rank,
      rankPercentile: rankPercentile ?? this.rankPercentile,
    );
  }
}

class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredXp;
  final BadgeCategory category;

  const AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    this.unlockedAt,
    required this.requiredXp,
    required this.category,
  });

  AchievementBadge copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? requiredXp,
    BadgeCategory? category,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requiredXp: requiredXp ?? this.requiredXp,
      category: category ?? this.category,
    );
  }
}

enum BadgeCategory {
  consistency,
  quiz,
  learning,
  performance,
  social,
  ai,
}

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final String levelTitle;
  final int xp;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.levelTitle,
    required this.xp,
    required this.rank,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? levelTitle,
    int? xp,
    int? rank,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      levelTitle: levelTitle ?? this.levelTitle,
      xp: xp ?? this.xp,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int cost;
  final bool isOwned;
  final RewardCategory category;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.cost,
    required this.isOwned,
    required this.category,
  });

  Reward copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? cost,
    bool? isOwned,
    RewardCategory? category,
  }) {
    return Reward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      cost: cost ?? this.cost,
      isOwned: isOwned ?? this.isOwned,
      category: category ?? this.category,
    );
  }
}

enum RewardCategory {
  avatar,
  theme,
  badge,
  feature,
}

enum TimeFilter {
  weekly,
  monthly,
  allTime,
}

enum LeaderboardFilter {
  global,
  perCourse,
  friends,
}

// State
class GamificationState extends Equatable {
  final bool isLoading;
  final String? error;
  final UserProfile? userProfile;
  final List<AchievementBadge> badges;
  final List<AchievementBadge> filteredBadges;
  final List<LeaderboardEntry> leaderboard;
  final List<LeaderboardEntry> filteredLeaderboard;
  final List<Reward> rewards;
  final TimeFilter timeFilter;
  final LeaderboardFilter leaderboardFilter;
  final String searchQuery;
  final String? successMessage;
  final bool isComparing;
  final List<LeaderboardEntry> compareUsers;
  final int userCoins;

  const GamificationState({
    this.isLoading = false,
    this.error,
    this.userProfile,
    this.badges = const [],
    this.filteredBadges = const [],
    this.leaderboard = const [],
    this.filteredLeaderboard = const [],
    this.rewards = const [],
    this.timeFilter = TimeFilter.weekly,
    this.leaderboardFilter = LeaderboardFilter.global,
    this.searchQuery = '',
    this.successMessage,
    this.isComparing = false,
    this.compareUsers = const [],
    this.userCoins = 0,
  });

  GamificationState copyWith({
    bool? isLoading,
    String? error,
    UserProfile? userProfile,
    List<AchievementBadge>? badges,
    List<AchievementBadge>? filteredBadges,
    List<LeaderboardEntry>? leaderboard,
    List<LeaderboardEntry>? filteredLeaderboard,
    List<Reward>? rewards,
    TimeFilter? timeFilter,
    LeaderboardFilter? leaderboardFilter,
    String? searchQuery,
    String? successMessage,
    bool? isComparing,
    List<LeaderboardEntry>? compareUsers,
    int? userCoins,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      userProfile: userProfile ?? this.userProfile,
      badges: badges ?? this.badges,
      filteredBadges: filteredBadges ?? this.filteredBadges,
      leaderboard: leaderboard ?? this.leaderboard,
      filteredLeaderboard: filteredLeaderboard ?? this.filteredLeaderboard,
      rewards: rewards ?? this.rewards,
      timeFilter: timeFilter ?? this.timeFilter,
      leaderboardFilter: leaderboardFilter ?? this.leaderboardFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isComparing: isComparing ?? this.isComparing,
      compareUsers: compareUsers ?? this.compareUsers,
      userCoins: userCoins ?? this.userCoins,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        userProfile,
        badges,
        filteredBadges,
        leaderboard,
        filteredLeaderboard,
        rewards,
        timeFilter,
        leaderboardFilter,
        searchQuery,
        successMessage,
        isComparing,
        compareUsers,
        userCoins,
      ];
}
