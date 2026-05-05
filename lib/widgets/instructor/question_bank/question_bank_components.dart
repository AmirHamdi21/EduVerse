import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class QuestionBankHeader extends StatelessWidget {
  const QuestionBankHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.stats = const <Widget>[],
    this.actions = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final List<Widget> stats;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return _CompactHeader(
      title: title,
      subtitle: subtitle,
      icon: Icons.quiz_outlined,
      stats: stats,
      actions: actions,
    );
  }
}

class QuestionBankFilterPanel extends StatelessWidget {
  const QuestionBankFilterPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _ResponsivePanel(children: children);
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.chips = const <Widget>[],
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget> chips;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FeatureCard(
      title: title,
      subtitle: subtitle,
      leading: leading ?? const Icon(Icons.help_outline),
      chips: chips,
      actions: actions,
      onTap: onTap,
    );
  }
}

class QuestionStatusBadge extends StatelessWidget {
  const QuestionStatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: color ?? InstructorColors.primary);
  }
}

class QuestionTypeChip extends StatelessWidget {
  const QuestionTypeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: InstructorColors.teal);
  }
}

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: color ?? InstructorColors.warning);
  }
}

class BloomLevelChip extends StatelessWidget {
  const BloomLevelChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: InstructorColors.accent);
  }
}

class ChapterSelector<T> extends StatelessWidget {
  const ChapterSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class QuestionTypeSegmentedControl<T> extends StatelessWidget {
  const QuestionTypeSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  final List<ButtonSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: <T>{selected},
      onSelectionChanged: (values) => onSelectionChanged(values.first),
    );
  }
}

class QuestionPromptEditor extends StatelessWidget {
  const QuestionPromptEditor({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 5,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class QuestionImageUploader extends StatelessWidget {
  const QuestionImageUploader({
    super.key,
    required this.label,
    required this.onUpload,
    this.onClear,
    this.preview,
    this.isUploading = false,
  });

  final String label;
  final VoidCallback onUpload;
  final VoidCallback? onClear;
  final Widget? preview;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return _UploadBox(
      label: label,
      icon: Icons.image_outlined,
      preview: preview,
      isUploading: isUploading,
      onUpload: onUpload,
      onClear: onClear,
    );
  }
}

class McqOptionsEditor extends StatelessWidget {
  const McqOptionsEditor({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class TrueFalseAnswerEditor extends StatelessWidget {
  const TrueFalseAnswerEditor({
    super.key,
    required this.value,
    required this.onChanged,
    required this.trueLabel,
    required this.falseLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String trueLabel;
  final String falseLabel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: <ButtonSegment<bool>>[
        ButtonSegment<bool>(value: true, label: Text(trueLabel)),
        ButtonSegment<bool>(value: false, label: Text(falseLabel)),
      ],
      selected: <bool>{value},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class FillBlanksEditor extends StatelessWidget {
  const FillBlanksEditor({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class WrittenAnswerEditor extends StatelessWidget {
  const WrittenAnswerEditor({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class QuestionAttachmentList extends StatelessWidget {
  const QuestionAttachmentList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

class QuestionPreviewPanel extends StatelessWidget {
  const QuestionPreviewPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _OutlinedPanel(child: child);
  }
}

class ChapterFormSheet extends StatelessWidget {
  const ChapterFormSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _BottomSheetSurface(child: child);
  }
}

class QuestionGroupCard extends StatelessWidget {
  const QuestionGroupCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FeatureCard(
      title: title,
      subtitle: subtitle,
      leading: const Icon(Icons.account_tree_outlined),
      actions: actions,
      onTap: onTap,
    );
  }
}

class QuestionGroupFormSheet extends StatelessWidget {
  const QuestionGroupFormSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _BottomSheetSurface(child: child);
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stats,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> stats;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: InstructorColors.headerGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: .9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[...stats, ...actions],
          ),
        ],
      ),
    );
  }
}

class _ResponsivePanel extends StatelessWidget {
  const _ResponsivePanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    this.chips = const <Widget>[],
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final List<Widget> chips;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: InstructorColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                    if (chips.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: chips),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty)
                Wrap(spacing: 4, runSpacing: 4, children: actions),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: .24)),
      backgroundColor: color.withValues(alpha: .12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.label,
    required this.icon,
    required this.onUpload,
    required this.isUploading,
    this.preview,
    this.onClear,
  });

  final String label;
  final IconData icon;
  final VoidCallback onUpload;
  final VoidCallback? onClear;
  final Widget? preview;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return _OutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (preview != null) ...<Widget>[
            preview!,
            const SizedBox(height: 12),
          ],
          Row(
            children: <Widget>[
              Icon(icon, color: InstructorColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
              if (isUploading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: label,
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_file_outlined),
                ),
              if (onClear != null)
                IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlinedPanel extends StatelessWidget {
  const _OutlinedPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.border),
      ),
      child: child,
    );
  }
}

class _BottomSheetSurface extends StatelessWidget {
  const _BottomSheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: child,
      ),
    );
  }
}
