import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/search/search_cubit.dart';
import '../../../bloc/search/search_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/search/search_category_chips.dart';
import '../../../widgets/student/search/search_recent_section.dart';
import '../../../widgets/student/search/search_quick_actions.dart';
import '../../../widgets/student/search/search_results_section.dart';
import '../../../widgets/student/search/search_empty_state.dart';
import '../../../widgets/student/search/search_filter_sheet.dart';

class OverallSearchScreen extends StatefulWidget {
  const OverallSearchScreen({super.key});

  @override
  State<OverallSearchScreen> createState() => _OverallSearchScreenState();
}

class _OverallSearchScreenState extends State<OverallSearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchHeader(isDark, l10n),
                  const SizedBox(height: 8),
                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      return SearchCategoryChips(
                        selected: state.filter.category,
                        onSelected: (category) {
                          context.read<SearchCubit>().setCategory(
                            category,
                            context,
                          );
                        },
                        isDark: isDark,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        return _buildBody(state, isDark, l10n);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        context.read<SearchCubit>().search(value, context);
                      },
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          context.read<SearchCubit>().addToRecentSearches(
                            value,
                          );
                        }
                      },
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchHintText,
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        context.read<SearchCubit>().clearSearch();
                        _searchFocusNode.requestFocus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              final hasFilters = state.filter.hasActiveFilters;
              return GestureDetector(
                onTap: () => _showFilterSheet(isDark, state.filter),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hasFilters
                        ? const Color(0xFF155DFC).withValues(alpha: 0.1)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: hasFilters
                        ? Border.all(
                            color: const Color(
                              0xFF155DFC,
                            ).withValues(alpha: 0.3),
                          )
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: hasFilters
                            ? const Color(0xFF155DFC)
                            : isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        size: 20,
                      ),
                      if (hasFilters)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF155DFC),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state, bool isDark, AppLocalizations l10n) {
    if (state is SearchLoading) {
      return _buildLoadingState(isDark, state);
    }

    if (state is SearchError) {
      return _buildErrorState(isDark, state, l10n);
    }

    if (state is SearchEmpty) {
      return SingleChildScrollView(
        child: SearchEmptyState(
          query: state.query,
          isDark: isDark,
          hasFilters: state.filter.hasActiveFilters,
          onClearFilters: () {
            context.read<SearchCubit>().clearFilters(context);
          },
        ),
      );
    }

    if (state is SearchLoaded) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SearchResultsSection(
          groupedResults: state.groupedResults,
          totalCount: state.totalCount,
          isDark: isDark,
        ),
      );
    }

    // Initial state - show recent searches and quick actions
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SearchRecentSection(
            recentSearches: state.recentSearches,
            onTap: (query) {
              _searchController.text = query;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: query.length),
              );
              context.read<SearchCubit>().search(query, context);
            },
            onRemove: (query) {
              context.read<SearchCubit>().removeRecentSearch(query);
            },
            onClearAll: () {
              context.read<SearchCubit>().clearRecentSearches();
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          SearchQuickActions(
            isDark: isDark,
            onNavigate: (route) => context.push(route),
          ),
          const SizedBox(height: 24),
          _buildSearchTips(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, SearchState state) {
    // Show previous results with a shimmer overlay while loading
    if (state.results.isNotEmpty) {
      return Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Opacity(
              opacity: 0.5,
              child: SearchResultsSection(
                groupedResults: state.groupedResults,
                totalCount: state.results.length,
                isDark: isDark,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF155DFC)),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Color(0xFF155DFC)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    bool isDark,
    SearchError state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.read<SearchCubit>().search(
                  _searchController.text,
                  context,
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTips(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF155DFC).withValues(alpha: 0.08),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                  ]
                : [
                    const Color(0xFF155DFC).withValues(alpha: 0.04),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF155DFC).withValues(alpha: 0.15)
                : const Color(0xFF155DFC).withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.searchTipsTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTipItem(l10n.searchTip1, isDark),
            const SizedBox(height: 6),
            _buildTipItem(l10n.searchTip2, isDark),
            const SizedBox(height: 6),
            _buildTipItem(l10n.searchTip3, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•  ',
          style: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(bool isDark, SearchFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SearchFilterSheet(
        filter: currentFilter,
        isDark: isDark,
        onApply: (filter) {
          context.read<SearchCubit>().setFilter(filter, context);
        },
      ),
    );
  }
}
