import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';
import '../shared/instructor_colors.dart';
import 'question_bank_localized_labels.dart';

class QuestionStatusActions extends StatelessWidget {
  const QuestionStatusActions({
    super.key,
    required this.status,
    required this.onAction,
    this.isMutating = false,
  });

  final QuestionBankStatus status;
  final ValueChanged<String> onAction;
  final bool isMutating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = _actions(l10n);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor(
                    status,
                  ).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.tune_rounded, color: _statusColor(status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.qbStatusWorkflow,
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
                      l10n.qbCurrentStatus(
                        localizedQuestionStatus(l10n, status),
                      ),
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
          ),
          const SizedBox(height: 12),
          Text(
            l10n.qbStatusWorkflowHint,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 430 ? 1 : 2;
              final width =
                  (constraints.maxWidth - ((columns - 1) * 10)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final action in actions)
                    SizedBox(
                      width: width,
                      child: _StatusActionTile(
                        action: action,
                        isDark: isDark,
                        isBusy: isMutating,
                        onAction: onAction,
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

  List<_StatusActionData> _actions(AppLocalizations l10n) {
    return [
      _StatusActionData(
        value: 'submit-for-review',
        label: l10n.submitForReview,
        hint: l10n.qbSubmitForReviewHint,
        disabledHint: l10n.qbSubmitForReviewDisabledHint,
        icon: Icons.outbox_rounded,
        color: InstructorColors.info,
        enabled:
            status == QuestionBankStatus.draft ||
            status == QuestionBankStatus.rejected,
      ),
      _StatusActionData(
        value: 'approve',
        label: l10n.qbApprove,
        hint: l10n.qbApproveHint,
        disabledHint: l10n.qbApproveDisabledHint,
        icon: Icons.verified_rounded,
        color: InstructorColors.success,
        enabled:
            status == QuestionBankStatus.draft ||
            status == QuestionBankStatus.underReview,
      ),
      _StatusActionData(
        value: 'reject',
        label: l10n.qbReject,
        hint: l10n.qbRejectHint,
        disabledHint: l10n.qbRejectDisabledHint,
        icon: Icons.undo_rounded,
        color: InstructorColors.warning,
        enabled: status == QuestionBankStatus.underReview,
      ),
      _StatusActionData(
        value: 'archive',
        label: l10n.qbArchive,
        hint: l10n.qbArchiveHint,
        disabledHint: l10n.qbArchiveDisabledHint,
        icon: Icons.archive_outlined,
        color: InstructorColors.orange,
        enabled: status != QuestionBankStatus.archived,
      ),
      _StatusActionData(
        value: 'restore',
        label: l10n.qbRestore,
        hint: l10n.qbRestoreHint,
        disabledHint: l10n.qbRestoreDisabledHint,
        icon: Icons.restore_rounded,
        color: InstructorColors.teal,
        enabled: status == QuestionBankStatus.archived,
      ),
    ];
  }
}

class _StatusActionTile extends StatelessWidget {
  const _StatusActionTile({
    required this.action,
    required this.isDark,
    required this.isBusy,
    required this.onAction,
  });

  final _StatusActionData action;
  final bool isDark;
  final bool isBusy;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final enabled = action.enabled && !isBusy;
    final color = enabled
        ? action.color
        : InstructorColors.textTertiaryColor(isDark);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? () => onAction(action.value) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? action.color.withValues(alpha: isDark ? 0.18 : 0.08)
              : InstructorColors.surfaceColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled
                ? action.color.withValues(alpha: 0.26)
                : InstructorColors.borderColor(isDark),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: isBusy && action.enabled
                  ? Padding(
                      padding: const EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: action.color,
                      ),
                    )
                  : Icon(action.icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: enabled
                          ? action.color
                          : InstructorColors.textSecondaryColor(isDark),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.enabled ? action.hint : action.disabledHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusActionData {
  const _StatusActionData({
    required this.value,
    required this.label,
    required this.hint,
    required this.disabledHint,
    required this.icon,
    required this.color,
    required this.enabled,
  });

  final String value;
  final String label;
  final String hint;
  final String disabledHint;
  final IconData icon;
  final Color color;
  final bool enabled;
}

Color _statusColor(QuestionBankStatus status) {
  switch (status) {
    case QuestionBankStatus.approved:
      return InstructorColors.success;
    case QuestionBankStatus.underReview:
      return InstructorColors.info;
    case QuestionBankStatus.rejected:
      return InstructorColors.error;
    case QuestionBankStatus.archived:
      return InstructorColors.textSecondary;
    case QuestionBankStatus.draft:
      return InstructorColors.primary;
  }
}
