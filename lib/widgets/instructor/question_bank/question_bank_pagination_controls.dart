import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/instructor/shared/instructor_colors.dart';
import 'package:flutter/material.dart';

class QuestionBankPaginationControls extends StatelessWidget {
  const QuestionBankPaginationControls({
    super.key,
    required this.isDark,
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  final bool isDark;
  final int page;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPrevious = page > 1;
    final hasNext = page < totalPages;
    if (totalPages <= 1) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            tooltip: l10n.previous,
            onPressed: hasPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$page / $totalPages',
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.next,
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
