import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/ta_colors.dart';
import 'ta_lab_submissions_tab.dart';

class TAReviewSubmissionModal extends StatefulWidget {
  final bool isDark;
  final TALabSubmission submission;
  final String labTitle;
  final Function(int score, String feedback)? onSubmitReview;
  final Function(int aiScore)? onApplyAIScore;
  final VoidCallback? onCancel;

  const TAReviewSubmissionModal({
    super.key,
    required this.isDark,
    required this.submission,
    required this.labTitle,
    this.onSubmitReview,
    this.onApplyAIScore,
    this.onCancel,
  });

  @override
  State<TAReviewSubmissionModal> createState() =>
      _TAReviewSubmissionModalState();
}

class _TAReviewSubmissionModalState extends State<TAReviewSubmissionModal> {
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(widget.isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 20),
                  _buildStudentInfo(l10n),
                  const SizedBox(height: 16),
                  _buildSubmissionFiles(l10n),
                  const SizedBox(height: 16),
                  _buildAIGradingSection(l10n),
                  const SizedBox(height: 16),
                  _buildManualGradingSection(l10n),
                  const SizedBox(height: 20),
                  _buildActionButtons(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.taLabReviewSubmission,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.submission.studentName} • ${widget.labTitle}',
                style: TextStyle(
                  color: TAColors.textSecondaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: TAColors.textSecondaryColor(widget.isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(
                alpha: widget.isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.submission.studentName.isNotEmpty
                    ? widget.submission.studentName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.submission.studentName,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(widget.isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${l10n.taLabSubmitted} ${widget.submission.submittedAgo}',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(widget.isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionFiles(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taLabSubmissionFiles,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFileItem('lab3_solution.c'),
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TAColors.primary.withValues(
              alpha: widget.isDark ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description_outlined,
            size: 18,
            color: TAColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fileName,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 13,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.download_rounded,
            color: TAColors.textSecondaryColor(widget.isDark),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildAIGradingSection(AppLocalizations l10n) {
    final hasAIScore = widget.submission.aiScore != null;

    if (!hasAIScore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TAColors.primary.withValues(alpha: widget.isDark ? 0.2 : 0.1),
            TAColors.primary.withValues(alpha: widget.isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TAColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: TAColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.taLabAIGradingAssistant,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(widget.isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.taLabSuggestedScore,
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(widget.isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.submission.aiScore}/100',
                style: TextStyle(
                  color: TAColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (widget.submission.aiScore ?? 0) / 100,
              backgroundColor: TAColors.borderColor(widget.isDark),
              valueColor: AlwaysStoppedAnimation<Color>(TAColors.primary),
              minHeight: 6,
            ),
          ),
          if (widget.submission.aiComment != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.submission.aiComment!,
              style: TextStyle(
                color: TAColors.textSecondaryColor(widget.isDark),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.taLabPlagiarismCheck,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(widget.isDark),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '5% ${l10n.taLabSimilarity}',
                style: TextStyle(
                  color: TAColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApplyAIScore?.call(widget.submission.aiScore!);
                    _scoreController.text = widget.submission.aiScore
                        .toString();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.textPrimaryColor(widget.isDark),
                    side: BorderSide(
                      color: TAColors.borderColor(widget.isDark),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.taLabApplyAIScore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TAColors.textPrimaryColor(widget.isDark),
                    side: BorderSide(
                      color: TAColors.borderColor(widget.isDark),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.taLabViewRubric),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualGradingSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? TAColors.darkSurface.withValues(alpha: 0.5)
            : TAColors.surfaceColor(widget.isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(widget.isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taLabManualGrading,
            style: TextStyle(
              color: TAColors.textPrimaryColor(widget.isDark),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.taLabScore,
            style: TextStyle(
              color: TAColors.textSecondaryColor(widget.isDark),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.taLabEnterScore,
              hintStyle: TextStyle(
                color: TAColors.textTertiaryColor(widget.isDark),
                fontSize: 14,
              ),
              filled: true,
              fillColor: TAColors.cardColor(widget.isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TAColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            style: TextStyle(color: TAColors.textPrimaryColor(widget.isDark)),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.taLabFeedback,
            style: TextStyle(
              color: TAColors.textSecondaryColor(widget.isDark),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.taLabEnterFeedback,
              hintStyle: TextStyle(
                color: TAColors.textTertiaryColor(widget.isDark),
                fontSize: 14,
              ),
              filled: true,
              fillColor: TAColors.cardColor(widget.isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: TAColors.borderColor(widget.isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TAColors.primary),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
            style: TextStyle(color: TAColors.textPrimaryColor(widget.isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: TAColors.textSecondaryColor(widget.isDark),
              side: BorderSide(color: TAColors.borderColor(widget.isDark)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.taLabCancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              final score = int.tryParse(_scoreController.text) ?? 0;
              widget.onSubmitReview?.call(score, _feedbackController.text);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(l10n.taLabSubmitReview),
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
