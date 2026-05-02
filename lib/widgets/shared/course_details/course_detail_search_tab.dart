import 'package:flutter/material.dart';

class CourseDetailSearchEntry {
  const CourseDetailSearchEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.description,
  });

  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
}

class CourseDetailSearchTab extends StatefulWidget {
  const CourseDetailSearchTab({
    super.key,
    required this.isDark,
    required this.entries,
    required this.hintText,
    required this.promptTitle,
    required this.promptSubtitle,
    required this.noResultsTitle,
    required this.noResultsSubtitle,
    this.accentColor = const Color(0xFF155DFC),
  });

  final bool isDark;
  final List<CourseDetailSearchEntry> entries;
  final String hintText;
  final String promptTitle;
  final String promptSubtitle;
  final String noResultsTitle;
  final String noResultsSubtitle;
  final Color accentColor;

  @override
  State<CourseDetailSearchTab> createState() => _CourseDetailSearchTabState();
}

class _CourseDetailSearchTabState extends State<CourseDetailSearchTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final hasQuery = query.isNotEmpty;
    final results = widget.entries
        .where((entry) => _matches(query, entry))
        .toList(growable: false);
    final bodyChildren = <Widget>[
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF121C35) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFD8E1EF),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search_rounded),
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ];

    if (!hasQuery) {
      bodyChildren.add(
        _SearchEmptyState(
          isDark: widget.isDark,
          title: widget.promptTitle,
          subtitle: widget.promptSubtitle,
          accentColor: widget.accentColor,
        ),
      );
    } else if (results.isEmpty) {
      bodyChildren.add(
        _SearchEmptyState(
          isDark: widget.isDark,
          title: widget.noResultsTitle,
          subtitle: widget.noResultsSubtitle,
          accentColor: widget.accentColor,
        ),
      );
    } else {
      bodyChildren.addAll(
        List<Widget>.generate(
          results.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == results.length - 1 ? 0 : 12,
            ),
            child: _SearchResultCard(
              isDark: widget.isDark,
              accentColor: widget.accentColor,
              entry: results[index],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bodyChildren,
          );
        }

        return ListView(
          padding: EdgeInsets.zero,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: bodyChildren,
        );
      },
    );
  }

  bool _matches(String query, CourseDetailSearchEntry entry) {
    if (query.isEmpty) {
      return false;
    }

    return entry.title.toLowerCase().contains(query) ||
        entry.subtitle.toLowerCase().contains(query) ||
        (entry.description?.toLowerCase().contains(query) ?? false);
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.isDark,
    required this.accentColor,
    required this.entry,
  });

  final bool isDark;
  final Color accentColor;
  final CourseDetailSearchEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: entry.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121C35) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFD8E1EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(entry.icon, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF667085),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121C35) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD8E1EF),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.travel_explore_rounded,
              color: accentColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF667085),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
