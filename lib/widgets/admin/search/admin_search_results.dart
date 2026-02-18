import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

enum SearchResultType { user, course, setting, report, log }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final IconData icon;
  final String? route;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    this.route,
    this.metadata,
  });
}

class AdminSearchResults extends StatelessWidget {
  final bool isDark;
  final List<SearchResult> results;
  final Function(SearchResult) onResultTap;
  final bool isLoading;
  final String searchQuery;

  const AdminSearchResults({
    super.key,
    required this.isDark,
    required this.results,
    required this.onResultTap,
    this.isLoading = false,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (results.isEmpty && searchQuery.isNotEmpty) {
      return _buildEmptyState();
    }

    final groupedResults = _groupResults();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedResults.length,
      itemBuilder: (context, index) {
        final group = groupedResults[index];
        return _buildResultGroup(group);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyle(
              color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check spelling',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ResultGroup> _groupResults() {
    final Map<SearchResultType, List<SearchResult>> grouped = {};
    
    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    return grouped.entries.map((e) => _ResultGroup(type: e.key, results: e.value)).toList();
  }

  Widget _buildResultGroup(_ResultGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                _getTypeIcon(group.type),
                size: 18,
                color: _getTypeColor(group.type),
              ),
              const SizedBox(width: 8),
              Text(
                _getTypeName(group.type),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(group.type),
                ),
              ),
              const Spacer(),
              Text(
                '${group.results.length} found',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ),
        ...group.results.map((result) => _buildResultItem(result)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultItem(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.darkCardBorder : AdminColors.lightCardBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onResultTap(result),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getTypeColor(result.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    result.icon,
                    color: _getTypeColor(result.type),
                    size: 20,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AdminColors.darkText : AdminColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AdminColors.darkTextSecondary : AdminColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AdminColors.darkTextTertiary : AdminColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return Icons.people_rounded;
      case SearchResultType.course:
        return Icons.menu_book_rounded;
      case SearchResultType.setting:
        return Icons.settings_rounded;
      case SearchResultType.report:
        return Icons.assessment_rounded;
      case SearchResultType.log:
        return Icons.history_rounded;
    }
  }

  Color _getTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return AdminColors.primary;
      case SearchResultType.course:
        return AdminColors.success;
      case SearchResultType.setting:
        return AdminColors.secondary;
      case SearchResultType.report:
        return AdminColors.warning;
      case SearchResultType.log:
        return AdminColors.accent;
    }
  }

  String _getTypeName(SearchResultType type) {
    switch (type) {
      case SearchResultType.user:
        return 'Users';
      case SearchResultType.course:
        return 'Courses';
      case SearchResultType.setting:
        return 'Settings';
      case SearchResultType.report:
        return 'Reports';
      case SearchResultType.log:
        return 'Activity Logs';
    }
  }
}

class _ResultGroup {
  final SearchResultType type;
  final List<SearchResult> results;

  const _ResultGroup({required this.type, required this.results});
}
