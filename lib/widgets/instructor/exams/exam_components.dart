import 'package:flutter/material.dart';

import '../shared/instructor_colors.dart';

class ExamHubHeader extends StatelessWidget {
  const ExamHubHeader({
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
    return _ExamHeader(
      title: title,
      subtitle: subtitle,
      icon: Icons.fact_check_outlined,
      stats: stats,
      actions: actions,
    );
  }
}

class ExamFilterPanel extends StatelessWidget {
  const ExamFilterPanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: children);
  }
}

class ExamCard extends StatelessWidget {
  const ExamCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.status,
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? status;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _ExamListCard(
      icon: Icons.description_outlined,
      title: title,
      subtitle: subtitle,
      status: status,
      actions: actions,
      onTap: onTap,
    );
  }
}

class ExamDraftCard extends StatelessWidget {
  const ExamDraftCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.status,
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? status;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _ExamListCard(
      icon: Icons.edit_note_outlined,
      title: title,
      subtitle: subtitle,
      status: status,
      actions: actions,
      onTap: onTap,
    );
  }
}

class ExamStatusBadge extends StatelessWidget {
  const ExamStatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: color ?? InstructorColors.success);
  }
}

class ExamDraftStatusBadge extends StatelessWidget {
  const ExamDraftStatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return _Badge(label: label, color: color ?? InstructorColors.warning);
  }
}

class ExamGenerationModeSwitch<T> extends StatelessWidget {
  const ExamGenerationModeSwitch({
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

class ExamRuleEditor extends StatelessWidget {
  const ExamRuleEditor({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(children: children));
  }
}

class ExamSectionRuleEditor extends StatelessWidget {
  const ExamSectionRuleEditor({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Panel(child: Column(children: children));
  }
}

class DraftSectionCard extends StatelessWidget {
  const DraftSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const <Widget>[],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (actions.isNotEmpty)
                Wrap(spacing: 4, runSpacing: 4, children: actions),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class DraftItemCard extends StatelessWidget {
  const DraftItemCard({
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
    return _ExamListCard(
      icon: Icons.drag_indicator,
      title: title,
      subtitle: subtitle,
      actions: actions,
      onTap: onTap,
    );
  }
}

class DraftItemEditorSheet extends StatelessWidget {
  const DraftItemEditorSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Sheet(child: child);
  }
}

class ExamQuestionPickerSheet extends StatelessWidget {
  const ExamQuestionPickerSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Sheet(child: child);
  }
}

class ExamExportSheet extends StatelessWidget {
  const ExamExportSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Sheet(child: child);
  }
}

class ExpiryCountdownChip extends StatelessWidget {
  const ExpiryCountdownChip({
    super.key,
    required this.label,
    this.isExpired = false,
  });

  final String label;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    return _Badge(
      label: label,
      color: isExpired ? InstructorColors.error : InstructorColors.info,
      icon: Icons.schedule_outlined,
    );
  }
}

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({
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

class _ExamListCard extends StatelessWidget {
  const _ExamListCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.actions = const <Widget>[],
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? status;
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
              Icon(icon, color: InstructorColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (status != null) status!,
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
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
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 16, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color.withValues(alpha: .24)),
      backgroundColor: color.withValues(alpha: .12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

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

class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});

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
