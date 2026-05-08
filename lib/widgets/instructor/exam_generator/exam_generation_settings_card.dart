import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generator_enums.dart';
import '../question_bank/question_form_menu_field.dart';
import '../shared/instructor_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.tune_rounded,
            color: InstructorColors.accent,
            title: l10n.examGenerationSettings,
            subtitle: l10n.examCreateSettingsHint,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final gap = narrow ? 10.0 : 12.0;
              final width = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      initialValue: totalMarks?.toString() ?? '',
                      label: l10n.totalMarks,
                      icon: Icons.star_outline_rounded,
                      color: InstructorColors.orange,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          onTotalMarksChanged(double.tryParse(value)),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<ExamMarkDistributionMode>(
                      label: l10n.examMarkDistribution,
                      value: markMode,
                      icon: Icons.pie_chart_outline_rounded,
                      color: InstructorColors.primary,
                      options: ExamMarkDistributionMode.values
                          .map(
                            (value) =>
                                QuestionFormMenuOption<
                                  ExamMarkDistributionMode
                                >(
                                  value: value,
                                  label: localizedMarkMode(l10n, value),
                                  icon: Icons.pie_chart_outline_rounded,
                                ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onMarkModeChanged(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<ExamRoundingPolicy>(
                      label: l10n.examRoundingPolicy,
                      value: rounding,
                      icon: Icons.exposure_outlined,
                      color: InstructorColors.teal,
                      options: ExamRoundingPolicy.values
                          .map(
                            (value) =>
                                QuestionFormMenuOption<ExamRoundingPolicy>(
                                  value: value,
                                  label: localizedRounding(l10n, value),
                                  icon: Icons.exposure_outlined,
                                ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onRoundingChanged(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      initialValue: durationMinutes?.toString() ?? '',
                      label: l10n.examDurationMinutes,
                      icon: Icons.timer_outlined,
                      color: InstructorColors.info,
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          onDurationChanged(int.tryParse(value)),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: QuestionFormMenuField<ExamGroupSelectionMode>(
                      label: l10n.examGroupSelectionMode,
                      value: groupSelectionMode,
                      icon: Icons.folder_copy_outlined,
                      color: InstructorColors.teal,
                      valueMaxLines: 2,
                      options: ExamGroupSelectionMode.values
                          .map(
                            (value) =>
                                QuestionFormMenuOption<ExamGroupSelectionMode>(
                                  value: value,
                                  label: localizedGroupSelectionMode(
                                    l10n,
                                    value,
                                  ),
                                  icon: Icons.folder_copy_outlined,
                                ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onGroupModeChanged(value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      initialValue: seed,
                      label: l10n.examVersionCode,
                      helperText: l10n.examSeedHelp,
                      icon: Icons.tag_rounded,
                      color: InstructorColors.accent,
                      onChanged: onSeedChanged,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionPill(
                label: l10n.examRandomSeed,
                icon: Icons.shuffle_rounded,
                color: InstructorColors.primary,
                onTap: onRandomSeed,
              ),
              _ActionPill(
                label: l10n.clear,
                icon: Icons.clear_rounded,
                color: InstructorColors.error,
                onTap: onClearSeed,
              ),
              _InfoPill(
                label: l10n.examApprovedOnlyHelp,
                icon: Icons.verified_outlined,
                color: InstructorColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ModernTextField(
            initialValue: instructions,
            label: l10n.instructions,
            icon: Icons.notes_rounded,
            color: InstructorColors.primary,
            minLines: 3,
            maxLines: 5,
            onChanged: onInstructionsChanged,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 520;
              final gap = narrow ? 10.0 : 12.0;
              final width = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      initialValue: headerText,
                      label: l10n.examHeaderText,
                      icon: Icons.vertical_align_top_rounded,
                      color: InstructorColors.cyan,
                      onChanged: onHeaderChanged,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _ModernTextField(
                      initialValue: footerText,
                      label: l10n.examFooterText,
                      icon: Icons.vertical_align_bottom_rounded,
                      color: InstructorColors.orange,
                      onChanged: onFooterChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: InstructorColors.textSecondaryColor(isDark),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModernTextField extends StatefulWidget {
  const _ModernTextField({
    required this.initialValue,
    required this.label,
    required this.icon,
    required this.color,
    required this.onChanged,
    this.helperText,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String initialValue;
  final String label;
  final String? helperText;
  final IconData icon;
  final Color color;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperMaxLines: 3,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
        prefixIcon: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(widget.icon, color: widget.color, size: 20),
        ),
        filled: true,
        fillColor: InstructorColors.surfaceColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: InstructorColors.primary,
            width: 1.4,
          ),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
