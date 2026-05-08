import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_availability_model.dart';
import '../shared/instructor_colors.dart';
import 'exam_generator_localized_labels.dart';

class ExamAvailabilityPanel extends StatelessWidget {
  const ExamAvailabilityPanel({
    super.key,
    required this.availability,
    this.isLoading = false,
    this.onViewMatchingQuestions,
    this.onApproveMoreQuestions,
  });

  final ExamAvailabilityModel? availability;
  final bool isLoading;
  final ValueChanged<ExamAvailabilityBucketModel>? onViewMatchingQuestions;
  final ValueChanged<ExamAvailabilityBucketModel>? onApproveMoreQuestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = availability;
    if (data == null && !isLoading) return const SizedBox.shrink();
    final canGenerate = data?.canGenerate ?? false;
    final color = data == null
        ? InstructorColors.primary
        : canGenerate
        ? InstructorColors.success
        : InstructorColors.error;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  canGenerate
                      ? Icons.check_circle_outline_rounded
                      : Icons.fact_check_outlined,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.examAvailabilityTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (data != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.examAvailabilitySummary(
                          data.totalAvailable,
                          data.totalRequired,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: color,
                  ),
                ),
            ],
          ),
          if (data != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.buckets
                  .map(
                    (bucket) => _BucketTile(
                      bucket: bucket,
                      onView: onViewMatchingQuestions,
                      onApprove: onApproveMoreQuestions,
                    ),
                  )
                  .toList(),
            ),
            if (!data.canGenerate) ...[
              const SizedBox(height: 10),
              _HelpStrip(
                text: l10n.examAvailabilityLowHelp,
                color: InstructorColors.error,
                icon: Icons.priority_high_rounded,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({required this.bucket, this.onView, this.onApprove});

  final ExamAvailabilityBucketModel bucket;
  final ValueChanged<ExamAvailabilityBucketModel>? onView;
  final ValueChanged<ExamAvailabilityBucketModel>? onApprove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = bucket.canGenerate
        ? bucket.isClose
              ? InstructorColors.warning
              : InstructorColors.success
        : InstructorColors.error;
    return Container(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 520),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                bucket.canGenerate
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${localizedGenerationScope(l10n, bucket.scope)}: '
                  '${bucket.available}/${bucket.required}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (bucket.hasTooLargeGroups) ...[
            const SizedBox(height: 8),
            _HelpStrip(
              text: l10n.examSkippedGroupsTooLarge(
                bucket.skippedGroupsTooLarge,
                bucket.largestSkippedGroupSize,
              ),
              color: InstructorColors.warning,
              icon: Icons.info_outline_rounded,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InlineAction(
                label: l10n.examViewMatchingQuestions,
                icon: Icons.search_rounded,
                color: InstructorColors.primary,
                onTap: onView == null ? null : () => onView!(bucket),
              ),
              if (!bucket.canGenerate || bucket.isClose)
                _InlineAction(
                  label: l10n.examApproveMoreQuestions,
                  icon: Icons.check_circle_outline_rounded,
                  color: bucket.canGenerate
                      ? InstructorColors.warning
                      : InstructorColors.success,
                  onTap: onApprove == null ? null : () => onApprove!(bucket),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpStrip extends StatelessWidget {
  const _HelpStrip({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
