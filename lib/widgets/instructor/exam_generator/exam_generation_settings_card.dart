import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generator_enums.dart';
import 'exam_generator_localized_labels.dart';

class ExamGenerationSettingsCard extends StatelessWidget {
  const ExamGenerationSettingsCard({
    super.key,
    required this.totalMarks,
    required this.markMode,
    required this.rounding,
    required this.groupSelectionMode,
    required this.seed,
    this.durationMinutes,
    required this.instructions,
    required this.headerText,
    required this.footerText,
    required this.onTotalMarksChanged,
    required this.onMarkModeChanged,
    required this.onRoundingChanged,
    required this.onGroupModeChanged,
    required this.onSeedChanged,
    required this.onRandomSeed,
    required this.onClearSeed,
    required this.onDurationChanged,
    required this.onInstructionsChanged,
    required this.onHeaderChanged,
    required this.onFooterChanged,
  });

  final double? totalMarks;
  final ExamMarkDistributionMode markMode;
  final ExamRoundingPolicy rounding;
  final ExamGroupSelectionMode groupSelectionMode;
  final String seed;
  final int? durationMinutes;
  final String instructions;
  final String headerText;
  final String footerText;
  final ValueChanged<double?> onTotalMarksChanged;
  final ValueChanged<ExamMarkDistributionMode> onMarkModeChanged;
  final ValueChanged<ExamRoundingPolicy> onRoundingChanged;
  final ValueChanged<ExamGroupSelectionMode> onGroupModeChanged;
  final ValueChanged<String> onSeedChanged;
  final VoidCallback onRandomSeed;
  final VoidCallback onClearSeed;
  final ValueChanged<int?> onDurationChanged;
  final ValueChanged<String> onInstructionsChanged;
  final ValueChanged<String> onHeaderChanged;
  final ValueChanged<String> onFooterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.examGenerationSettings, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _box(TextFormField(
                initialValue: totalMarks?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.totalMarks),
                onChanged: (value) => onTotalMarksChanged(double.tryParse(value)),
              )),
              _box(DropdownButtonFormField<ExamMarkDistributionMode>(
                initialValue: markMode,
                decoration: InputDecoration(labelText: l10n.examMarkDistribution),
                items: ExamMarkDistributionMode.values
                    .map((value) => DropdownMenuItem(value: value, child: Text(localizedMarkMode(l10n, value))))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onMarkModeChanged(value);
                },
              )),
              _box(DropdownButtonFormField<ExamRoundingPolicy>(
                initialValue: rounding,
                decoration: InputDecoration(labelText: l10n.examRoundingPolicy),
                items: ExamRoundingPolicy.values
                    .map((value) => DropdownMenuItem(value: value, child: Text(localizedRounding(l10n, value))))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onRoundingChanged(value);
                },
              )),
              _box(TextFormField(
                initialValue: seed,
                decoration: InputDecoration(
                  labelText: l10n.examVersionCode,
                  helperText: l10n.examSeedHelp,
                ),
                onChanged: onSeedChanged,
              )),
              _box(TextFormField(
                initialValue: durationMinutes?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.examDurationMinutes),
                onChanged: (value) => onDurationChanged(int.tryParse(value)),
              )),
              _box(DropdownButtonFormField<ExamGroupSelectionMode>(
                isExpanded: true,
                initialValue: groupSelectionMode,
                decoration: InputDecoration(
                  labelText: l10n.examGroupSelectionMode,
                  helperText: _groupModeHelp(l10n, groupSelectionMode),
                ),
                items: ExamGroupSelectionMode.values
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(localizedGroupSelectionMode(l10n, value)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onGroupModeChanged(value);
                },
              )),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onRandomSeed,
                icon: const Icon(Icons.shuffle_rounded),
                label: Text(l10n.examRandomSeed),
              ),
              TextButton.icon(
                onPressed: onClearSeed,
                icon: const Icon(Icons.clear_rounded),
                label: Text(l10n.clear),
              ),
              Chip(
                avatar: const Icon(Icons.verified_outlined, size: 16),
                label: Text(l10n.examApprovedOnlyHelp),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: instructions,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.instructions),
            onChanged: onInstructionsChanged,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _box(TextFormField(
                initialValue: headerText,
                decoration: InputDecoration(labelText: l10n.examHeaderText),
                onChanged: onHeaderChanged,
              )),
              _box(TextFormField(
                initialValue: footerText,
                decoration: InputDecoration(labelText: l10n.examFooterText),
                onChanged: onFooterChanged,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      child: child,
    );
  }

  String _groupModeHelp(AppLocalizations l10n, ExamGroupSelectionMode mode) {
    switch (mode) {
      case ExamGroupSelectionMode.independent:
        return l10n.examGroupedIndependentHelp;
      case ExamGroupSelectionMode.keepGroupTogether:
        return l10n.examGroupedTogetherHelp;
      case ExamGroupSelectionMode.excludeGrouped:
        return l10n.examExcludeGroupedHelp;
    }
  }
}
