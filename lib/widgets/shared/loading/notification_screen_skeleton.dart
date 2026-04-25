import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class NotificationScreenSkeleton extends StatelessWidget {
  const NotificationScreenSkeleton({
    super.key,
    required this.isDark,
    this.showSearchBar = false,
    this.showActionButtons = false,
    this.showTabs = false,
  });

  final bool isDark;
  final bool showSearchBar;
  final bool showActionButtons;
  final bool showTabs;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (showSearchBar) ...[
          SkeletonBox(isDark: isDark, height: 48),
          const SizedBox(height: 12),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              5,
              (index) => SkeletonBox(
                isDark: isDark,
                width: index == 0 ? 88 : 96,
                height: 34,
                borderRadius: BorderRadius.circular(20),
                margin: const EdgeInsets.only(right: 8),
              ),
            ),
          ),
        ),
        if (showActionButtons) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SkeletonBox(isDark: isDark, height: 40)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonBox(isDark: isDark, height: 40)),
            ],
          ),
        ],
        if (showTabs) ...[
          const SizedBox(height: 16),
          SkeletonBox(isDark: isDark, height: 44, borderRadius: BorderRadius.circular(16)),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            SkeletonBox(isDark: isDark, width: 150, height: 18),
            const Spacer(),
            SkeletonBox(isDark: isDark, width: 56, height: 16),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          5,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  isDark: isDark,
                  width: 44,
                  height: 44,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SkeletonBox(
                              isDark: isDark,
                              height: 14,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SkeletonBox(isDark: isDark, width: 52, height: 12),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SkeletonBox(
                        isDark: isDark,
                        height: 12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      SkeletonBox(
                        isDark: isDark,
                        width: 180,
                        height: 12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SkeletonBox(
                            isDark: isDark,
                            width: 78,
                            height: 22,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          const SizedBox(width: 8),
                          SkeletonBox(
                            isDark: isDark,
                            width: 94,
                            height: 22,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
