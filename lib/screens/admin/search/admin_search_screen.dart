import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/search/search_barrel.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Users',
    'Courses',
    'Settings',
    'Reports',
    'Logs',
  ];
  List<SearchResult> _results = [];
  List<String> _recentSearches = [
    'Ahmed Hassan',
    'CS301',
    'Payment settings',
    'User reports',
  ];
  Map<String, dynamic> _filters = {};

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

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final queryLower = query.toLowerCase();

      // Mock search results
      final allResults = [
        const SearchResult(
          id: '1',
          title: 'Ahmed Hassan',
          subtitle: 'Student • CS301 Operating Systems',
          type: SearchResultType.user,
          icon: Icons.person_rounded,
          route: '/admin/users/1',
        ),
        const SearchResult(
          id: '2',
          title: 'Dr. Sarah Johnson',
          subtitle: 'Instructor • Computer Science',
          type: SearchResultType.user,
          icon: Icons.person_rounded,
          route: '/admin/users/2',
        ),
        const SearchResult(
          id: '3',
          title: 'Operating Systems',
          subtitle: 'CS301 • Dr. Ahmed Hassan • 45 students',
          type: SearchResultType.course,
          icon: Icons.menu_book_rounded,
          route: '/admin/courses/1',
        ),
        const SearchResult(
          id: '4',
          title: 'Data Structures',
          subtitle: 'CS201 • Dr. Sarah Johnson • 52 students',
          type: SearchResultType.course,
          icon: Icons.menu_book_rounded,
          route: '/admin/courses/2',
        ),
        const SearchResult(
          id: '5',
          title: 'Payment Settings',
          subtitle: 'Configure payment gateways and methods',
          type: SearchResultType.setting,
          icon: Icons.payment_rounded,
          route: '/admin/settings/payment',
        ),
        const SearchResult(
          id: '6',
          title: 'Email Configuration',
          subtitle: 'SMTP and email template settings',
          type: SearchResultType.setting,
          icon: Icons.email_rounded,
          route: '/admin/settings/email',
        ),
        const SearchResult(
          id: '7',
          title: 'Attendance Report',
          subtitle: 'Generated on Feb 15, 2026',
          type: SearchResultType.report,
          icon: Icons.assessment_rounded,
          route: '/admin/reports/1',
        ),
        const SearchResult(
          id: '8',
          title: 'User Login Activity',
          subtitle: '1,234 logins today',
          type: SearchResultType.log,
          icon: Icons.history_rounded,
          route: '/admin/audit',
        ),
      ];

      // Filter by query
      var filtered = allResults
          .where(
            (r) =>
                r.title.toLowerCase().contains(queryLower) ||
                r.subtitle.toLowerCase().contains(queryLower),
          )
          .toList();

      // Filter by category
      if (_selectedCategory != 'All') {
        final typeMap = {
          'Users': SearchResultType.user,
          'Courses': SearchResultType.course,
          'Settings': SearchResultType.setting,
          'Reports': SearchResultType.report,
          'Logs': SearchResultType.log,
        };
        final type = typeMap[_selectedCategory];
        if (type != null) {
          filtered = filtered.where((r) => r.type == type).toList();
        }
      }

      setState(() {
        _results = filtered;
        _isLoading = false;
      });

      // Add to recent searches
      if (!_recentSearches.contains(query) && query.length > 2) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) {
            _recentSearches = _recentSearches.take(10).toList();
          }
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _isLoading = false;
    });
  }

  void _onResultTap(SearchResult result) {
    if (result.route != null) {
      context.push(result.route!);
    }
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AdminSearchFilterSheet(
          isDark: isDark,
          currentFilters: _filters,
          onApply: (filters) {
            setState(() {
              _filters = filters;
            });
            if (_searchController.text.isNotEmpty) {
              _performSearch(_searchController.text);
            }
          },
          onReset: () {
            setState(() {
              _filters = {};
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            body: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      AdminSearchHeader(
                        isDark: isDark,
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSearch: _performSearch,
                        onClear: _clearSearch,
                        onBack: () => context.pop(),
                        onFilterTap: () => _showFilterSheet(context, isDark),
                        hasActiveFilters: _filters.isNotEmpty,
                      ),
                      AdminSearchFilters(
                        isDark: isDark,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          if (_searchController.text.isNotEmpty) {
                            _performSearch(_searchController.text);
                          }
                        },
                        categories: _categories,
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: _buildBody(isDark, l10n)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    // Show loading
    if (_isLoading) {
      return AdminSearchResults(
        isDark: isDark,
        results: _results,
        onResultTap: _onResultTap,
        isLoading: true,
        searchQuery: _searchController.text,
      );
    }

    // Show results if we have a query
    if (_searchController.text.isNotEmpty) {
      return AdminSearchResults(
        isDark: isDark,
        results: _results,
        onResultTap: _onResultTap,
        searchQuery: _searchController.text,
      );
    }

    // Show initial state with suggestions
    return SingleChildScrollView(
      child: Column(
        children: [
          AdminRecentSearches(
            isDark: isDark,
            recentSearches: _recentSearches,
            onSearchTap: (search) {
              _searchController.text = search;
              _performSearch(search);
            },
            onRemove: (search) {
              setState(() {
                _recentSearches.remove(search);
              });
            },
            onClearAll: () {
              setState(() {
                _recentSearches.clear();
              });
            },
          ),
          AdminSearchSuggestions(
            isDark: isDark,
            onSuggestionTap: (suggestion) {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          ),
          AdminQuickActions(
            isDark: isDark,
            onActionTap: (route) => context.push(route),
          ),
        ],
      ),
    );
  }
}
