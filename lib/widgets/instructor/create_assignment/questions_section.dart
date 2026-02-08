import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/instructor/assignment_model.dart';
import 'create_assignment_colors.dart';

class QuestionsSection extends StatelessWidget {
  final List<AssignmentQuestion> questions;
  final bool isDark;
  final VoidCallback onAddQuestion;
  final Function(int, AssignmentQuestion) onUpdateQuestion;
  final Function(int) onRemoveQuestion;
  final Color? accentColor;

  const QuestionsSection({
    super.key,
    required this.questions,
    required this.isDark,
    required this.onAddQuestion,
    required this.onUpdateQuestion,
    required this.onRemoveQuestion,
    this.accentColor,
  });

  Color get _accent => accentColor ?? CreateAssignmentColors.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (questions.isEmpty)
          _buildEmptyState()
        else
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _QuestionCard(
              index: index,
              question: question,
              isDark: isDark,
              accentColor: _accent,
              onUpdated: (q) => onUpdateQuestion(index, q),
              onRemoved: () => onRemoveQuestion(index),
            );
          }),
        const SizedBox(height: 12),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
                    : CreateAssignmentColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 32,
                color: CreateAssignmentColors.textTertiaryColor(isDark),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No questions yet',
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onAddQuestion,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Question'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final AssignmentQuestion question;
  final bool isDark;
  final Color accentColor;
  final Function(AssignmentQuestion) onUpdated;
  final VoidCallback onRemoved;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.isDark,
    required this.accentColor,
    required this.onUpdated,
    required this.onRemoved,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _textController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.questionText);
    _pointsController = TextEditingController(text: widget.question.points.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isDark
            ? CreateAssignmentColors.darkSurface.withValues(alpha: 0.5)
            : CreateAssignmentColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(widget.isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question ${widget.index + 1}',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onRemoved,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: CreateAssignmentColors.error,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          TextField(
            controller: _textController,
            onChanged: (value) => widget.onUpdated(
              widget.question.copyWith(questionText: value),
            ),
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Enter question text...',
              hintStyle: TextStyle(
                color: CreateAssignmentColors.textTertiaryColor(widget.isDark),
              ),
              filled: true,
              fillColor: widget.isDark
                  ? CreateAssignmentColors.darkCard
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: CreateAssignmentColors.borderColor(widget.isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: CreateAssignmentColors.borderColor(widget.isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.accentColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),

          // Type & Points Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTypeDropdown(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final points = int.tryParse(value) ?? 10;
                    widget.onUpdated(widget.question.copyWith(points: points));
                  },
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: widget.isDark
                        ? CreateAssignmentColors.darkCard
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: CreateAssignmentColors.borderColor(widget.isDark),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: CreateAssignmentColors.borderColor(widget.isDark),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: widget.accentColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AI Generate & Add Hint
          Row(
            children: [
              _buildActionButton(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Generate',
                onTap: _showAIGenerateDialog,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Add Hint',
                onTap: _showHintDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? CreateAssignmentColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CreateAssignmentColors.borderColor(widget.isDark),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<QuestionType>(
          value: widget.question.type,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: CreateAssignmentColors.textSecondaryColor(widget.isDark),
          ),
          dropdownColor: widget.isDark
              ? CreateAssignmentColors.darkCard
              : Colors.white,
          items: QuestionType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type.displayName,
                style: TextStyle(
                  color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              widget.onUpdated(widget.question.copyWith(type: type));
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? CreateAssignmentColors.darkCard
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CreateAssignmentColors.borderColor(widget.isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: CreateAssignmentColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: CreateAssignmentColors.textSecondaryColor(widget.isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIGenerateDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('AI question generation coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final hintController = TextEditingController(text: widget.question.hint ?? '');
        return AlertDialog(
          backgroundColor: widget.isDark
              ? CreateAssignmentColors.darkCard
              : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Hint',
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
            ),
          ),
          content: TextField(
            controller: hintController,
            maxLines: 3,
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(widget.isDark),
            ),
            decoration: InputDecoration(
              hintText: 'Enter a helpful hint for students...',
              hintStyle: TextStyle(
                color: CreateAssignmentColors.textTertiaryColor(widget.isDark),
              ),
              filled: true,
              fillColor: widget.isDark
                  ? CreateAssignmentColors.darkSurface
                  : CreateAssignmentColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: CreateAssignmentColors.textSecondaryColor(widget.isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onUpdated(
                  widget.question.copyWith(hint: hintController.text),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CreateAssignmentColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
