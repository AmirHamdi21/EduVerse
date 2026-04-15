import 'package:flutter/material.dart';
import 'announcement_colors.dart';

class AnnouncementEmptyState extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final VoidCallback onCreateNew;

  const AnnouncementEmptyState({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.onCreateNew,
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
                color: isDark
                    ? AnnouncementColors.primary.withOpacity(0.1)
                    : AnnouncementColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 48,
                color: AnnouncementColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AnnouncementColors.textSecondaryColor(isDark),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Announcement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnouncementColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementLoadingSkeleton extends StatefulWidget {
  final bool isDark;

  const AnnouncementLoadingSkeleton({super.key, required this.isDark});

  @override
  State<AnnouncementLoadingSkeleton> createState() =>
      _AnnouncementLoadingSkeletonState();
}

class _AnnouncementLoadingSkeletonState
    extends State<AnnouncementLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          itemBuilder: (context, index) {
            return _buildSkeletonCard(index);
          },
        );
      },
    );
  }

  Widget _buildSkeletonCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? AnnouncementColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? AnnouncementColors.darkBorder.withOpacity(0.3)
              : AnnouncementColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: double.infinity, height: 18),
                    const SizedBox(height: 10),
                    _buildShimmerBox(width: 200, height: 14),
                  ],
                ),
              ),
              _buildShimmerBox(width: 24, height: 24, isCircle: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBox(width: 80, height: 28, borderRadius: 14),
              const SizedBox(width: 10),
              _buildShimmerBox(width: 50, height: 28, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBox(width: 120, height: 14),
              const SizedBox(width: 16),
              _buildShimmerBox(width: 100, height: 14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 44, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: _buildShimmerBox(height: 44, borderRadius: 12)),
              const SizedBox(width: 10),
              _buildShimmerBox(width: 44, height: 44, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    double? width,
    required double height,
    double borderRadius = 8,
    bool isCircle = false,
  }) {
    final baseColor = widget.isDark
        ? AnnouncementColors.darkSurface
        : AnnouncementColors.surface;
    final highlightColor = widget.isDark
        ? AnnouncementColors.darkBorder.withOpacity(0.5)
        : AnnouncementColors.border;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * _shimmerController.value, 0),
          end: Alignment(1 + 2 * _shimmerController.value, 0),
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

class AnnouncementErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;

  const AnnouncementErrorState({
    super.key,
    required this.isDark,
    required this.message,
    required this.onRetry,
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
                color: AnnouncementColors.delete.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AnnouncementColors.delete,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: AnnouncementColors.textSecondaryColor(isDark),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnouncementColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
