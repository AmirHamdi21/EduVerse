import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_question_model.dart';
import '../shared/instructor_colors.dart';
import 'question_bank_localized_labels.dart';
import 'question_text_renderer.dart';

class QuestionBankCard extends StatelessWidget {
  const QuestionBankCard({
    super.key,
    required this.question,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.selectionMode = false,
    this.onSelectionChanged,
  });

  final QuestionBankQuestionModel question;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool selectionMode;
  final ValueChanged<bool?>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _statusColor(question.status);
    final cardColor = InstructorColors.cardColor(isDark);
    final textColor = InstructorColors.textPrimaryColor(isDark);
    final secondaryText = InstructorColors.textSecondaryColor(isDark);
    final borderColor = isSelected
        ? accent.withValues(alpha: 0.72)
        : InstructorColors.borderColor(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: selectionMode ? null : () => _showQuestionActions(context),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(width: 5, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        activeColor: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _typeIcon(question.questionType.value),
                      color: accent,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuestionCardBody(
                      question: question,
                      accent: accent,
                      isDark: isDark,
                      textColor: textColor,
                      secondaryText: secondaryText,
                    ),
                  ),
                  if (!selectionMode) ...[
                    const SizedBox(width: 8),
                    _CardQuickActions(
                      editTooltip: l10n.edit,
                      deleteTooltip: l10n.qbDeleteQuestion,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _statusColor(question.status);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _QuestionActionSheet(
          title: questionTextForDisplay(
            question.questionText,
            fallback: l10n.questionBankImageQuestion,
          ),
          accent: accent,
          isDark: isDark,
          onView: () {
            Navigator.of(sheetContext).pop();
            onTap();
          },
          onEdit: () {
            Navigator.of(sheetContext).pop();
            onEdit();
          },
          onDelete: onDelete == null
              ? null
              : () {
                  Navigator.of(sheetContext).pop();
                  onDelete!();
                },
        );
      },
    );
  }

  Color _statusColor(dynamic status) {
    final value = status.value.toString();
    switch (value) {
      case 'approved':
        return InstructorColors.success;
      case 'under_review':
        return InstructorColors.warning;
      case 'rejected':
        return InstructorColors.error;
      case 'archived':
        return InstructorColors.textTertiary;
      case 'draft':
      default:
        return InstructorColors.primary;
    }
  }

  IconData _typeIcon(String typeName) {
    switch (typeName) {
      case 'mcq':
        return Icons.radio_button_checked_rounded;
      case 'true_false':
        return Icons.rule_rounded;
      case 'fill_blanks':
        return Icons.short_text_rounded;
      case 'essay':
        return Icons.subject_rounded;
      case 'written':
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class _QuestionCardBody extends StatelessWidget {
  const _QuestionCardBody({
    required this.question,
    required this.accent,
    required this.isDark,
    required this.textColor,
    required this.secondaryText,
  });

  final QuestionBankQuestionModel question;
  final Color accent;
  final bool isDark;
  final Color textColor;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = question.questionText?.trim().isNotEmpty == true
        ? question.questionText!.trim()
        : l10n.questionBankImageQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        QuestionFormattedText(
          text: title,
          fallback: l10n.questionBankImageQuestion,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 10),
        _QuestionMetaPanel(question: question, accent: accent, isDark: isDark),
        if (question.groups.isNotEmpty) ...[
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 15,
                color: secondaryText.withValues(alpha: 0.88),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  question.groups
                      .map(
                        (group) =>
                            group.title ?? '${l10n.qbGroups} ${group.groupId}',
                      )
                      .join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _QuestionMetaPanel extends StatelessWidget {
  const _QuestionMetaPanel({
    required this.question,
    required this.accent,
    required this.isDark,
  });

  final QuestionBankQuestionModel question;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(
          isDark,
        ).withValues(alpha: isDark ? 0.42 : 0.72),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaCell(
                  label: localizedQuestionType(l10n, question.questionType),
                  icon: Icons.category_outlined,
                  color: InstructorColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _MetaCell(
                  label: localizedDifficulty(l10n, question.difficulty),
                  icon: Icons.speed_rounded,
                  color: InstructorColors.teal,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MetaCell(
            label: localizedBloomLevel(l10n, question.bloomLevel),
            icon: Icons.psychology_alt_outlined,
            color: InstructorColors.accent,
            isDark: isDark,
            isWide: true,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _MetaCell(
                  label: localizedQuestionStatus(l10n, question.status),
                  icon: Icons.verified_outlined,
                  color: accent,
                  isDark: isDark,
                ),
              ),
              if (question.hasAttachments) ...[
                const SizedBox(width: 6),
                _SignalBadge(
                  tooltip: l10n.attachments,
                  icon: Icons.attach_file_rounded,
                  color: InstructorColors.orange,
                  isDark: isDark,
                ),
              ],
              if (question.isGrouped) ...[
                const SizedBox(width: 6),
                _SignalBadge(
                  tooltip: l10n.qbGroups,
                  icon: Icons.folder_copy_outlined,
                  color: InstructorColors.cyan,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    this.isWide = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white.withValues(alpha: 0.9) : color,
          size: 15,
        ),
      ),
    );
  }
}

class _CardQuickActions extends StatelessWidget {
  const _CardQuickActions({
    required this.editTooltip,
    required this.deleteTooltip,
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
  });

  final String editTooltip;
  final String deleteTooltip;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIconButton(
          tooltip: editTooltip,
          icon: Icons.edit_rounded,
          color: InstructorColors.primary,
          isDark: isDark,
          onPressed: onEdit,
        ),
        if (onDelete != null) ...[
          const SizedBox(height: 8),
          _ActionIconButton(
            tooltip: deleteTooltip,
            icon: Icons.delete_outline_rounded,
            color: InstructorColors.error,
            isDark: isDark,
            onPressed: onDelete!,
          ),
        ],
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _QuestionActionSheet extends StatelessWidget {
  const _QuestionActionSheet({
    required this.title,
    required this.accent,
    required this.isDark,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final Color accent;
  final bool isDark;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textColor = InstructorColors.textPrimaryColor(isDark);
    final secondaryText = InstructorColors.textSecondaryColor(isDark);

    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 4,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: secondaryText.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.quiz_outlined, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.question,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SheetActionTile(
            label: l10n.qbViewQuestion,
            icon: Icons.visibility_outlined,
            color: InstructorColors.cyan,
            isDark: isDark,
            onTap: onView,
          ),
          _SheetActionTile(
            label: l10n.questionBankEditQuestion,
            icon: Icons.edit_rounded,
            color: InstructorColors.primary,
            isDark: isDark,
            onTap: onEdit,
          ),
          if (onDelete != null)
            _SheetActionTile(
              label: l10n.qbDeleteQuestion,
              icon: Icons.delete_outline_rounded,
              color: InstructorColors.error,
              isDark: isDark,
              onTap: onDelete!,
            ),
        ],
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: InstructorColors.textSecondaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
