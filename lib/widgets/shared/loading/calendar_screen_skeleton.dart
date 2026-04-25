import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class CalendarScreenSkeleton extends StatelessWidget {
  const CalendarScreenSkeleton({
    super.key,
    required this.isDark,
    this.showHeroHeader = true,
    this.scrollable = true,
  });

  final bool isDark;
  final bool showHeroHeader;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeroHeader) ...[
            SkeletonBox(
              isDark: isDark,
              height: 96,
              borderRadius: BorderRadius.circular(24),
            ),
            const SizedBox(height: 16),
          ],
          SkeletonBox(
            isDark: isDark,
            height: 50,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => SkeletonBox(
                  isDark: isDark,
                  width: index == 0 ? 86 : 98,
                  height: 34,
                  borderRadius: BorderRadius.circular(20),
                  margin: const EdgeInsets.only(right: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101828) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E2939)
                    : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SkeletonBox(isDark: isDark, width: 28, height: 28),
                    const Spacer(),
                    SkeletonBox(isDark: isDark, width: 120, height: 18),
                    const Spacer(),
                    SkeletonBox(isDark: isDark, width: 28, height: 28),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (_) => SkeletonBox(isDark: isDark, width: 28, height: 12),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    35,
                    (index) => SkeletonBox(
                      isDark: isDark,
                      width: 38,
                      height: 38,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SkeletonBox(isDark: isDark, width: 190, height: 18),
          const SizedBox(height: 12),
          ...List.generate(
            2,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  SkeletonBox(isDark: isDark, width: 42, height: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(isDark: isDark, height: 14),
                        const SizedBox(height: 8),
                        SkeletonBox(isDark: isDark, width: 140, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SkeletonBox(isDark: isDark, width: 160, height: 18),
          const SizedBox(height: 12),
          ...List.generate(
            2,
            (_) => SkeletonBox(
              isDark: isDark,
              height: 84,
              borderRadius: BorderRadius.circular(18),
              margin: const EdgeInsets.only(bottom: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );

    if (!scrollable) {
      return content;
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: content,
    );
  }
}
