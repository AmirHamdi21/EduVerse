import 'package:flutter/material.dart';
import '../shared/instructor_colors.dart';

class InstructorChatEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isFiltered;
  final VoidCallback? onClearFilters;
  final VoidCallback? onNewChat;

  const InstructorChatEmptyState({
    super.key,
    required this.isDark,
    this.isFiltered = false,
    this.onClearFilters,
    this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.filter_list_off : Icons.chat_bubble_outline_rounded,
                size: 48,
                color: InstructorColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'No matching conversations' : 'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: InstructorColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your search or filters'
                  : 'Start a new conversation with students or colleagues',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
            ),
            const SizedBox(height: 24),
            if (isFiltered && onClearFilters != null)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.primary,
                  side: BorderSide(color: InstructorColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (!isFiltered && onNewChat != null)
              ElevatedButton.icon(
                onPressed: onNewChat,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Start New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: InstructorColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
