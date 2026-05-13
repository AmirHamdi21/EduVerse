import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/course_chapter_model.dart';
import '../shared/instructor_colors.dart';

class QuestionChapterFormCard extends StatefulWidget {
  const QuestionChapterFormCard({
    super.key,
    this.initial,
    this.suggestedOrder,
    this.occupiedOrders = const <int>[],
    required this.onSubmit,
    this.onCancel,
    this.isSubmitting = false,
  });

  final CourseChapterModel? initial;
  final int? suggestedOrder;
  final List<int> occupiedOrders;
  final void Function(String name, int order, bool isActive) onSubmit;
  final VoidCallback? onCancel;
  final bool isSubmitting;

  @override
  State<QuestionChapterFormCard> createState() =>
      _QuestionChapterFormCardState();
}

class _QuestionChapterFormCardState extends State<QuestionChapterFormCard> {
  late TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late TextEditingController _order = TextEditingController(
    text: (widget.initial?.chapterOrder ?? widget.suggestedOrder ?? 1)
        .toString(),
  );
  late bool _isActive = widget.initial?.isActive ?? true;

  @override
  void didUpdateWidget(covariant QuestionChapterFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final initialChanged = oldWidget.initial?.id != widget.initial?.id;
    final suggestedChanged =
        oldWidget.suggestedOrder != widget.suggestedOrder &&
        widget.initial == null;
    if (initialChanged || suggestedChanged) {
      _name.dispose();
      _order.dispose();
      _name = TextEditingController(text: widget.initial?.name ?? '');
      _order = TextEditingController(
        text: (widget.initial?.chapterOrder ?? widget.suggestedOrder ?? 1)
            .toString(),
      );
      _isActive = widget.initial?.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.initial == null
        ? InstructorColors.teal
        : InstructorColors.accent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  widget.initial == null
                      ? Icons.create_new_folder_outlined
                      : Icons.edit_note_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.initial == null
                      ? l10n.qbCreateChapter
                      : l10n.qbEditChapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (widget.onCancel != null)
                IconButton(
                  onPressed: widget.onCancel,
                  style: IconButton.styleFrom(
                    backgroundColor: InstructorColors.surfaceColor(isDark),
                    foregroundColor: InstructorColors.textPrimaryColor(isDark),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: _decoration(
              context,
              l10n.qbChapterName,
              Icons.title_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _order,
            keyboardType: TextInputType.number,
            decoration: _decoration(
              context,
              l10n.qbChapterOrder,
              Icons.format_list_numbered_rounded,
            ),
          ),
          if (_visibleOccupiedOrders.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: InstructorColors.warning.withValues(
                  alpha: isDark ? 0.18 : 0.08,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: InstructorColors.warning.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: InstructorColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.qbChapterOrderTakenHint(_takenOrdersLabel),
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.initial != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: InstructorColors.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: InstructorColors.borderColor(isDark)),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  12,
                  2,
                  8,
                  2,
                ),
                value: _isActive,
                activeThumbColor: InstructorColors.success,
                onChanged: (value) => setState(() => _isActive = value),
                title: Text(
                  _isActive ? l10n.qbChapterActive : l10n.qbChapterInactive,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              const actionButtonHeight = 54.0;
              final saveButton = FilledButton.icon(
                onPressed: widget.isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: InstructorColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, actionButtonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: widget.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  l10n.save,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              final cancelButton = OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: InstructorColors.primary,
                  side: const BorderSide(color: InstructorColors.primary),
                  minimumSize: const Size(0, actionButtonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    saveButton,
                    if (widget.onCancel != null) ...[
                      const SizedBox(height: 10),
                      cancelButton,
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: saveButton),
                  if (widget.onCancel != null) ...[
                    const SizedBox(width: 10),
                    Expanded(child: cancelButton),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    widget.onSubmit(_name.text, int.tryParse(_order.text) ?? 1, _isActive);
  }

  List<int> get _visibleOccupiedOrders {
    final current = widget.initial?.chapterOrder;
    final orders =
        widget.occupiedOrders
            .where((order) => order > 0 && order != current)
            .toSet()
            .toList()
          ..sort();
    return orders;
  }

  String get _takenOrdersLabel => _visibleOccupiedOrders.join(', ');

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: InstructorColors.surfaceColor(isDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: InstructorColors.borderColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: InstructorColors.primary,
          width: 1.4,
        ),
      ),
    );
  }
}
