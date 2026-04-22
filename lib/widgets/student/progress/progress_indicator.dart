import 'package:flutter/material.dart';

class CourseProgressIndicator extends StatelessWidget {
  final int totalMaterials;
  final int viewedMaterials;

  const CourseProgressIndicator({
    super.key,
    required this.totalMaterials,
    required this.viewedMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalMaterials < 0 ? 0 : totalMaterials;
    final safeViewed = viewedMaterials.clamp(0, safeTotal);
    final progress = safeTotal == 0 ? 0.0 : safeViewed / safeTotal;
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Course Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Viewed $safeViewed of $safeTotal materials'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Text('$percentage% complete'),
        ],
      ),
    );
  }
}
