import 'package:flutter/material.dart';

class SharedDiscussionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final bool canCreateThread;
  final VoidCallback? onCreateThread;

  const SharedDiscussionHeader({
    super.key,
    required this.title,
    required this.accentColor,
    required this.canCreateThread,
    this.onCreateThread,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
          ),
          if (canCreateThread)
            ElevatedButton.icon(
              onPressed: onCreateThread,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Thread'),
            ),
        ],
      ),
    );
  }
}
