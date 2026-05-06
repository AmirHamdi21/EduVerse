import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_availability_model.dart';
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
    final data = availability;
    if (data == null && !isLoading) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.examAvailabilityTitle,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (data != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.examAvailabilitySummary(
                data.totalAvailable,
                data.totalRequired,
              ),
            ),
            const SizedBox(height: 10),
            ...data.buckets.map((bucket) {
              final color = bucket.canGenerate
                  ? bucket.isClose
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF059669)
                  : Theme.of(context).colorScheme.error;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          bucket.canGenerate
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${localizedGenerationScope(l10n, bucket.scope)}: '
                            '${bucket.available}/${bucket.required}',
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (bucket.hasTooLargeGroups)
                          Chip(
                            avatar: const Icon(Icons.info_outline, size: 16),
                            label: Text(
                              l10n.examSkippedGroupsTooLarge(
                                bucket.skippedGroupsTooLarge,
                                bucket.largestSkippedGroupSize,
                              ),
                            ),
                          ),
                        TextButton.icon(
                          onPressed: onViewMatchingQuestions == null
                              ? null
                              : () => onViewMatchingQuestions!(bucket),
                          icon: const Icon(Icons.search_outlined),
                          label: Text(l10n.examViewMatchingQuestions),
                        ),
                        TextButton.icon(
                          onPressed: onApproveMoreQuestions == null
                              ? null
                              : () => onApproveMoreQuestions!(bucket),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.examApproveMoreQuestions),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            if (!data.canGenerate)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.examAvailabilityLowHelp,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
