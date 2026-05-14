import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_search_model.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';

/// Instructor Search Screen - Overall search for instructor features
class InstructorSearchScreen extends StatefulWidget {
  const InstructorSearchScreen({super.key});

  @override
  State<InstructorSearchScreen> createState() => _InstructorSearchScreenState();
}

class _InstructorSearchScreenState extends State<InstructorSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  InstructorSearchCategory _selectedCategory = InstructorSearchCategory.all;
  List<InstructorSearchResult> _results = [];
  List<String> _recentSearches = [
    'John Smith',
    'CS 101',
    'Assignment 3',
    'Midterm grades',
  ];
  bool _isLoading = false;
  String _searchQuery = '';

  // Mock data
  final List<InstructorSearchResult> _mockData = [
    const InstructorSearchResult(
      id: '1',
      title: 'John Smith',
      subtitle: 'CS 101, CS 201 • john.smith@university.edu',
      category: InstructorSearchCategory.students,
      route: '/instructor/student-details',
    ),
    const InstructorSearchResult(
      id: '2',
      title: 'Emily Johnson',
      subtitle: 'CS 101 • emily.j@university.edu',
      category: InstructorSearchCategory.students,
      route: '/instructor/student-details',
    ),
    const InstructorSearchResult(
      id: '3',
      title: 'CS 101 - Introduction to Computer Science',
      subtitle: '45 students • Fall 2024',
      category: InstructorSearchCategory.courses,
      route: '/instructor/course-management',
    ),
    const InstructorSearchResult(
      id: '4',
      title: 'CS 201 - Data Structures',
      subtitle: '32 students • Fall 2024',
      category: InstructorSearchCategory.courses,
      route: '/instructor/course-management',
    ),
    const InstructorSearchResult(
      id: '5',
      title: 'Assignment 3: Linked Lists',
      subtitle: 'CS 201 • Due: Oct 15, 2024 • 28 submissions',
      category: InstructorSearchCategory.assignments,
      route: '/instructor/grading',
    ),
    const InstructorSearchResult(
      id: '6',
      title: 'Midterm Exam',
      subtitle: 'CS 101 • Due: Oct 20, 2024 • 42 submissions',
      category: InstructorSearchCategory.assignments,
      route: '/instructor/grading',
    ),
    const InstructorSearchResult(
      id: '7',
      title: 'CS 101 - Midterm Grades',
      subtitle: 'Posted Oct 25, 2024 • 45 students',
      category: InstructorSearchCategory.grades,
      route: '/instructor/grading',
    ),
    const InstructorSearchResult(
      id: '8',
      title: 'Week 5 Lecture Slides',
      subtitle: 'CS 101 • PDF • 2.4 MB',
      category: InstructorSearchCategory.materials,
      route: '/instructor/upload-materials',
    ),
    const InstructorSearchResult(
      id: '9',
      title: 'Lab 3 Instructions',
      subtitle: 'CS 201 • PDF • 1.1 MB',
      category: InstructorSearchCategory.materials,
      route: '/instructor/upload-materials',
    ),
    const InstructorSearchResult(
      id: '10',
      title: 'Exam Schedule Update',
      subtitle: 'CS 101, CS 201 • Oct 10, 2024',
      category: InstructorSearchCategory.announcements,
      route: '/instructor/announcements',
    ),
  ];

  final List<InstructorSearchQuickAction> _quickActions = [
    const InstructorSearchQuickAction(
      title: 'Grade Submissions',
      icon: Icons.grading_outlined,
      color: Color(0xFF8B5CF6),
      route: '/instructor/grading',
    ),
    const InstructorSearchQuickAction(
      title: 'Create Assignment',
      icon: Icons.assignment_add,
      color: Color(0xFFF59E0B),
      route: '/instructor/create-assignment',
    ),
    const InstructorSearchQuickAction(
      title: 'Upload Materials',
      icon: Icons.upload_file_outlined,
      color: Color(0xFF06B6D4),
      route: '/instructor/upload-materials',
    ),
    const InstructorSearchQuickAction(
      title: 'Post Announcement',
      icon: Icons.campaign_outlined,
      color: Color(0xFFEC4899),
      route: '/instructor/announcements',
    ),
    const InstructorSearchQuickAction(
      title: 'Take Attendance',
      icon: Icons.how_to_reg_outlined,
      color: Color(0xFF10B981),
      route: '/instructor/attendance',
    ),
    const InstructorSearchQuickAction(
      title: 'View Reports',
      icon: Icons.analytics_outlined,
      color: Color(0xFF155CFB),
      route: '/instructor/reports',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final lowerQuery = query.toLowerCase();
      var filteredResults = _mockData.where((result) {
        final matchesQuery =
            result.title.toLowerCase().contains(lowerQuery) ||
            result.subtitle.toLowerCase().contains(lowerQuery);

        if (_selectedCategory == InstructorSearchCategory.all) {
          return matchesQuery;
        }
        return matchesQuery && result.category == _selectedCategory;
      }).toList();

      setState(() {
        _results = filteredResults;
        _isLoading = false;
      });
    });
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchHeader(isDark, l10n),
                const SizedBox(height: 8),
                _buildCategoryChips(isDark),
                const SizedBox(height: 8),
                Expanded(child: _buildBody(isDark, l10n)),
              ],
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
            onTap: () => safeBack(context, '/instructor/dashboard'),
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
                iosBackIcon(context),
                color: InstructorColors.textPrimaryColor(isDark),
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
                      onChanged: _performSearch,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addToRecentSearches(value);
                        }
                      },
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.instructorSearchHint,
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _performSearch('');
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
        ],
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: InstructorSearchCategory.values.length,
        itemBuilder: (context, index) {
          final category = InstructorSearchCategory.values[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category);
                if (_searchQuery.isNotEmpty) {
                  _performSearch(_searchQuery);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? InstructorColors.primary
                      : isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : const Color(0xFFE2E8F0),
                        ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : InstructorColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : InstructorColors.textSecondaryColor(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(InstructorColors.primary),
        ),
      );
    }

    if (_searchQuery.isNotEmpty) {
      if (_results.isEmpty) {
        return _buildEmptyResults(isDark, l10n);
      }
      return _buildSearchResults(isDark, l10n);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) _buildRecentSearches(isDark, l10n),
          const SizedBox(height: 16),
          _buildQuickActions(isDark, l10n),
          const SizedBox(height: 16),
          _buildSearchTips(isDark, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentSearches,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _recentSearches.clear()),
                child: Text(
                  l10n.clearAll,
                  style: TextStyle(
                    color: InstructorColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: InstructorColors.textTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _recentSearches.remove(search)),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: InstructorColors.textTertiaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return GestureDetector(
                onTap: () => context.push(action.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: InstructorColors.cardColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: InstructorColors.borderColor(isDark),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(action.icon, color: action.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          action.title,
                          style: TextStyle(
                            color: InstructorColors.textPrimaryColor(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildSearchTips(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    InstructorColors.primary.withValues(alpha: 0.08),
                    InstructorColors.accent.withValues(alpha: 0.05),
                  ]
                : [
                    InstructorColors.primary.withValues(alpha: 0.04),
                    InstructorColors.accent.withValues(alpha: 0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.15 : 0.08,
            ),
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
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTipItem(l10n.instructorSearchTip1, isDark),
            const SizedBox(height: 6),
            _buildTipItem(l10n.instructorSearchTip2, isDark),
            const SizedBox(height: 6),
            _buildTipItem(l10n.instructorSearchTip3, isDark),
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
            color: InstructorColors.textTertiaryColor(isDark),
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark, AppLocalizations l10n) {
    // Group results by category
    final groupedResults =
        <InstructorSearchCategory, List<InstructorSearchResult>>{};
    for (final result in _results) {
      groupedResults.putIfAbsent(result.category, () => []).add(result);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${_results.length} ${l10n.resultsFound}',
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ),
        ...groupedResults.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    Icon(entry.key.icon, size: 16, color: entry.key.color),
                    const SizedBox(width: 8),
                    Text(
                      entry.key.displayName,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: entry.key.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${entry.value.length}',
                        style: TextStyle(
                          color: entry.key.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((result) => _buildResultCard(result, isDark)),
            ],
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResultCard(InstructorSearchResult result, bool isDark) {
    return GestureDetector(
      onTap: () {
        _addToRecentSearches(_searchQuery);
        if (result.route != null) {
          context.push(result.route!, extra: result.extra);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: result.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: result.category == InstructorSearchCategory.students
                  ? Center(
                      child: Text(
                        result.title.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: result.category.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Icon(
                      result.category.icon,
                      color: result.category.color,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.subtitle,
                    style: TextStyle(
                      color: InstructorColors.textTertiaryColor(isDark),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: InstructorColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noResultsDescription,
              style: TextStyle(
                color: InstructorColors.textTertiaryColor(isDark),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
