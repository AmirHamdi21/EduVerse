import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TASearchScreen extends StatefulWidget {
  const TASearchScreen({super.key});

  @override
  State<TASearchScreen> createState() => _TASearchScreenState();
}

class _TASearchScreenState extends State<TASearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = 'all';
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = ['Assignment 3', 'John Smith', 'Lab 5', 'CS201'];
  bool _isSearching = false;

  // Mock data for search
  final List<Map<String, dynamic>> _allData = [
    // Students
    {'id': '1', 'title': 'John Smith', 'subtitle': 'CS201, CS301', 'type': 'student', 'icon': Icons.person_rounded},
    {'id': '2', 'title': 'Emily Davis', 'subtitle': 'CS201', 'type': 'student', 'icon': Icons.person_rounded},
    {'id': '3', 'title': 'Michael Brown', 'subtitle': 'CS301, CS401', 'type': 'student', 'icon': Icons.person_rounded},
    {'id': '4', 'title': 'Sarah Johnson', 'subtitle': 'CS201, CS301', 'type': 'student', 'icon': Icons.person_rounded},
    // Courses
    {'id': '5', 'title': 'CS201 - Data Structures', 'subtitle': '45 students', 'type': 'course', 'icon': Icons.school_rounded},
    {'id': '6', 'title': 'CS301 - Algorithms', 'subtitle': '32 students', 'type': 'course', 'icon': Icons.school_rounded},
    {'id': '7', 'title': 'CS401 - Database Systems', 'subtitle': '28 students', 'type': 'course', 'icon': Icons.school_rounded},
    // Labs
    {'id': '8', 'title': 'Lab 1 - Arrays', 'subtitle': 'CS201 • Due: Feb 15', 'type': 'lab', 'icon': Icons.science_rounded},
    {'id': '9', 'title': 'Lab 2 - Linked Lists', 'subtitle': 'CS201 • Due: Feb 22', 'type': 'lab', 'icon': Icons.science_rounded},
    {'id': '10', 'title': 'Lab 3 - Trees', 'subtitle': 'CS301 • Due: Feb 20', 'type': 'lab', 'icon': Icons.science_rounded},
    // Submissions
    {'id': '11', 'title': 'Assignment 3 - John Smith', 'subtitle': 'CS201 • Pending review', 'type': 'submission', 'icon': Icons.assignment_rounded},
    {'id': '12', 'title': 'Lab 2 - Emily Davis', 'subtitle': 'CS201 • Graded: 85%', 'type': 'submission', 'icon': Icons.assignment_rounded},
    // Materials
    {'id': '13', 'title': 'Lecture Notes - Week 5', 'subtitle': 'CS201 • PDF', 'type': 'material', 'icon': Icons.description_rounded},
    {'id': '14', 'title': 'Lab Guide - Arrays', 'subtitle': 'CS201 • PDF', 'type': 'material', 'icon': Icons.description_rounded},
    // Discussions
    {'id': '15', 'title': 'Help with recursion', 'subtitle': 'CS201 • 5 replies', 'type': 'discussion', 'icon': Icons.forum_rounded},
    {'id': '16', 'title': 'Assignment 2 clarification', 'subtitle': 'CS301 • 3 replies', 'type': 'discussion', 'icon': Icons.forum_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allData.where((item) {
        final matchesQuery = item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
            item['subtitle'].toString().toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'all' || item['type'] == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          backgroundColor: TAColors.scaffoldColor(isDark),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildSearchHeader(isDark, l10n),
                  const SizedBox(height: 8),
                  _buildCategoryChips(isDark, l10n),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildBody(isDark, l10n),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: TAColors.textPrimaryColor(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _searchFocusNode.hasFocus
                      ? TAColors.primary
                      : TAColors.borderColor(isDark),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: l10n.taSearchPlaceholder,
                  hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: TAColors.textSecondaryColor(isDark),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark, AppLocalizations l10n) {
    final categories = [
      {'id': 'all', 'label': l10n.all, 'icon': Icons.dashboard_rounded},
      {'id': 'student', 'label': l10n.students, 'icon': Icons.people_rounded},
      {'id': 'course', 'label': l10n.courses, 'icon': Icons.school_rounded},
      {'id': 'lab', 'label': l10n.taLabs, 'icon': Icons.science_rounded},
      {'id': 'submission', 'label': l10n.submissions, 'icon': Icons.assignment_rounded},
      {'id': 'material', 'label': l10n.materials, 'icon': Icons.folder_rounded},
      {'id': 'discussion', 'label': l10n.discussions, 'icon': Icons.forum_rounded},
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : TAColors.textSecondaryColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(category['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category['id'] as String);
                _performSearch(_searchController.text);
              },
              selectedColor: TAColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : TAColors.textSecondaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: TAColors.cardColor(isDark),
              side: BorderSide(
                color: isSelected ? TAColors.primary : TAColors.borderColor(isDark),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    if (_searchController.text.isEmpty) {
      return _buildInitialState(isDark, l10n);
    }

    if (_searchResults.isEmpty && _isSearching) {
      return _buildNoResults(isDark, l10n);
    }

    return _buildSearchResults(isDark, l10n);
  }

  Widget _buildInitialState(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSearches,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return ActionChip(
                  avatar: Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                  label: Text(search),
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  backgroundColor: TAColors.cardColor(isDark),
                  labelStyle: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                  ),
                  side: BorderSide(color: TAColors.borderColor(isDark)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Quick Actions
          Text(
            l10n.quickActions,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(isDark, l10n),
          const SizedBox(height: 24),
          // Browse by Category
          Text(
            l10n.taSearchBrowseCategories,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBrowseCategories(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    final actions = [
      {'icon': Icons.grading_rounded, 'label': l10n.pendingGrading, 'route': '/ta/ai-grading', 'color': TAColors.warning},
      {'icon': Icons.people_rounded, 'label': l10n.taAtRiskStudents, 'route': '/ta/student-performance', 'color': TAColors.error},
      {'icon': Icons.science_rounded, 'label': l10n.taUpcomingLabs, 'route': '/ta/labs', 'color': TAColors.info},
      {'icon': Icons.forum_rounded, 'label': l10n.taNewDiscussions, 'route': '/ta/discussions', 'color': TAColors.success},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(action['route'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (action['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action['label'] as String,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildBrowseCategories(bool isDark, AppLocalizations l10n) {
    final categories = [
      {'icon': Icons.people_rounded, 'label': l10n.allStudents, 'count': '87', 'type': 'student'},
      {'icon': Icons.school_rounded, 'label': l10n.allCourses, 'count': '3', 'type': 'course'},
      {'icon': Icons.science_rounded, 'label': l10n.allLabs, 'count': '12', 'type': 'lab'},
      {'icon': Icons.assignment_rounded, 'label': l10n.allSubmissions, 'count': '156', 'type': 'submission'},
      {'icon': Icons.folder_rounded, 'label': l10n.allMaterials, 'count': '24', 'type': 'material'},
      {'icon': Icons.forum_rounded, 'label': l10n.allDiscussions, 'count': '8', 'type': 'discussion'},
    ];

    return Column(
      children: categories.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _selectedCategory = category['type'] as String);
                _searchController.text = '';
                _performSearch('');
                // Show all items for this category
                setState(() {
                  _searchResults = _allData
                      .where((item) => item['type'] == category['type'])
                      .toList();
                  _isSearching = true;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TAColors.cardColor(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TAColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: TAColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        category['label'] as String,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TAColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category['count'] as String,
                        style: const TextStyle(
                          color: TAColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: TAColors.textTertiaryColor(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoResults(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResultsFound,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or category',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_searchResults.length} ${l10n.resultsFound}',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          );
        }

        final result = _searchResults[index - 1];
        return _buildResultCard(result, isDark);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, bool isDark) {
    final type = result['type'] as String;
    final color = _getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleResultTap(result),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    result['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['title'],
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result['subtitle'],
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getTypeLabel(type),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'student':
        return TAColors.primary;
      case 'course':
        return TAColors.success;
      case 'lab':
        return TAColors.info;
      case 'submission':
        return TAColors.warning;
      case 'material':
        return const Color(0xFF8B5CF6);
      case 'discussion':
        return TAColors.error;
      default:
        return TAColors.textSecondaryColor(false);
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'student':
        return 'Student';
      case 'course':
        return 'Course';
      case 'lab':
        return 'Lab';
      case 'submission':
        return 'Submission';
      case 'material':
        return 'Material';
      case 'discussion':
        return 'Discussion';
      default:
        return type;
    }
  }

  void _handleResultTap(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final query = _searchController.text;

    // Add to recent searches
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    // Navigate based on type
    switch (type) {
      case 'student':
        context.push('/ta/student-performance');
        break;
      case 'course':
        context.push('/ta/courses');
        break;
      case 'lab':
        context.push('/ta/labs');
        break;
      case 'submission':
        context.push('/ta/ai-grading');
        break;
      case 'material':
        context.push('/ta/lab-resources');
        break;
      case 'discussion':
        context.push('/ta/discussions');
        break;
    }
  }
}
