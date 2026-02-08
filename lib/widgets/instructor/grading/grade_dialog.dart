import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/submission_model.dart';
import 'grading_theme_colors.dart';

/// Grade submission dialog with modern design
class GradeDialog extends StatefulWidget {
  final Submission submission;
  final bool isDark;
  final Function(int grade, String? feedback) onSubmit;

  const GradeDialog({
    super.key,
    required this.submission,
    required this.isDark,
    required this.onSubmit,
  });

  /// Show the grade dialog as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Submission submission,
    required bool isDark,
    required Function(int grade, String? feedback) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GradeDialog(
        submission: submission,
        isDark: isDark,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<GradeDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _gradeController;
  late TextEditingController _feedbackController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _gradeController = TextEditingController(
      text: widget.submission.grade?.toString() ?? '',
    );
    _feedbackController = TextEditingController(
      text: widget.submission.feedback ?? '',
    );
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final gradeText = _gradeController.text.trim();
    final grade = int.tryParse(gradeText);
    
    if (gradeText.isEmpty) {
      setState(() => _errorText = 'Please enter a grade');
      return;
    }
    
    if (grade == null) {
      setState(() => _errorText = 'Please enter a valid number');
      return;
    }
    
    if (grade < 0 || grade > widget.submission.maxGrade) {
      setState(() => _errorText = 'Grade must be between 0 and ${widget.submission.maxGrade}');
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    
    // Simulate submission delay for animation
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onSubmit(grade, _feedbackController.text.trim().isEmpty 
          ? null 
          : _feedbackController.text.trim());
      Navigator.pop(context);
    });
  }

  void _setQuickGrade(int percentage) {
    final grade = (widget.submission.maxGrade * percentage / 100).round();
    _gradeController.text = grade.toString();
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: GradingColors.cardColor(widget.isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: GradingColors.primaryGradient,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.grading_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.gradeSubmission,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.submission.studentName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assignment info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? GradingColors.darkSurface
                            : GradingColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_rounded,
                            color: GradingColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.submission.assignmentTitle,
                                  style: TextStyle(
                                    color: GradingColors.textPrimaryColor(widget.isDark),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.submission.courseName,
                                  style: TextStyle(
                                    color: GradingColors.textSecondaryColor(widget.isDark),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Grade input section
                    Text(
                      l10n.grade,
                      style: TextStyle(
                        color: GradingColors.textPrimaryColor(widget.isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _errorText != null
                                      ? GradingColors.late.withValues(alpha: 0.1)
                                      : GradingColors.primary.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _gradeController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: GradingColors.textPrimaryColor(widget.isDark),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (_) => setState(() => _errorText = null),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: GradingColors.cardColor(widget.isDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _errorText != null
                                        ? GradingColors.late
                                        : GradingColors.borderColor(widget.isDark),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _errorText != null
                                        ? GradingColors.late
                                        : GradingColors.borderColor(widget.isDark),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: _errorText != null
                                        ? GradingColors.late
                                        : GradingColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Text(
                            '/ ${widget.submission.maxGrade}',
                            style: TextStyle(
                              color: GradingColors.textSecondaryColor(widget.isDark),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (_errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          color: GradingColors.late,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Quick grade buttons
                    Text(
                      'Quick Grade',
                      style: TextStyle(
                        color: GradingColors.textSecondaryColor(widget.isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [100, 90, 80, 70, 60, 50].map((percentage) {
                        final isSelected = _gradeController.text ==
                            (widget.submission.maxGrade * percentage / 100)
                                .round()
                                .toString();
                        return _QuickGradeButton(
                          percentage: percentage,
                          isSelected: isSelected,
                          isDark: widget.isDark,
                          onTap: () => _setQuickGrade(percentage),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Feedback input
                    Text(
                      l10n.feedback,
                      style: TextStyle(
                        color: GradingColors.textPrimaryColor(widget.isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: GradingColors.primary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        style: TextStyle(
                          color: GradingColors.textPrimaryColor(widget.isDark),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.enterFeedback,
                          hintStyle: TextStyle(
                            color: GradingColors.textTertiaryColor(widget.isDark),
                          ),
                          filled: true,
                          fillColor: GradingColors.cardColor(widget.isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: GradingColors.borderColor(widget.isDark),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: GradingColors.borderColor(widget.isDark),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: GradingColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isSubmitting ? null : _validateAndSubmit,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: _isSubmitting
                                  ? LinearGradient(
                                      colors: [
                                        GradingColors.primary.withValues(alpha: 0.6),
                                        GradingColors.primaryLight.withValues(alpha: 0.6),
                                      ],
                                    )
                                  : GradingColors.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: GradingColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isSubmitting)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                const SizedBox(width: 10),
                                Text(
                                  _isSubmitting ? 'Submitting...' : l10n.submitGrade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickGradeButton extends StatelessWidget {
  final int percentage;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickGradeButton({
    required this.percentage,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = GradingColors.getGradeColor(percentage.toDouble());
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [gradeColor, gradeColor.withValues(alpha: 0.8)],
                  )
                : null,
            color: isSelected
                ? null
                : gradeColor.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? gradeColor
                  : gradeColor.withValues(alpha: 0.3),
              width: isSelected ? 0 : 1,
            ),
          ),
          child: Text(
            '$percentage%',
            style: TextStyle(
              color: isSelected ? Colors.white : gradeColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
