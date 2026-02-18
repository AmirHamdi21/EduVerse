import 'package:flutter/material.dart';
import '../shared/admin_colors.dart';

class AdminSearchSuggestions extends StatelessWidget {
  final bool isDark;
  final Function(String) onSuggestionTap;

  const AdminSearchSuggestions({
    super.key,
    required this.isDark,
    required this.onSuggestionTap,
  });

  static const List<Map<String, dynamic>> _suggestions = [
    {'icon': Icons.people_rounded, 'text': 'All students', 'color': Color(0xFF155DFC)},
    {'icon': Icons.school_rounded, 'text': 'Active courses', 'color': Color(0xFF00C950)},
    {'icon': Icons.warning_rounded, 'text': 'Low attendance', 'color': Color(0xFFF0B100)},
    {'icon': Icons.security_rounded, 'text': 'Security logs', 'color': Color(0xFFFB2C36)},
    {'icon': Icons.payment_rounded, 'text': 'Payment issues', 'color': Color(0xFF8B5CF6)},
    {'icon': Icons.assessment_rounded, 'text': 'Recent reports', 'color': Color(0xFF00B8DB)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return _buildSuggestionChip(
                icon: suggestion['icon'] as IconData,
                text: suggestion['text'] as String,
                color: suggestion['color'] as Color,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onSuggestionTap(text),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminQuickActions extends StatelessWidget {
  final bool isDark;
  final Function(String) onActionTap;

  const AdminQuickActions({
    super.key,
    required this.isDark,
    required this.onActionTap,
  });

  static const List<Map<String, dynamic>> _actions = [
    {'icon': Icons.person_add_rounded, 'text': 'Add User', 'route': '/admin/users/add'},
    {'icon': Icons.add_circle_rounded, 'text': 'Create Course', 'route': '/admin/courses/add'},
    {'icon': Icons.send_rounded, 'text': 'Send Announcement', 'route': '/admin/notifications'},
    {'icon': Icons.assessment_rounded, 'text': 'Generate Report', 'route': '/admin/analytics'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _actions.map((action) {
              return Expanded(
                child: _buildActionItem(
                  icon: action['icon'] as IconData,
                  text: action['text'] as String,
                  route: action['route'] as String,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String text,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onActionTap(route),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AdminColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AdminColors.darkText : AdminColors.lightText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
