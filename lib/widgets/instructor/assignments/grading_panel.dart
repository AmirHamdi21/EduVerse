import 'package:flutter/material.dart';

import '../../../utils/late_penalty_calculator.dart';
import '../grading/grading_theme_colors.dart';

class GradingPanel extends StatefulWidget {
  const GradingPanel({
    super.key,
    required this.maxScore,
    this.initialScore,
    this.initialFeedback,
    this.latePenaltyPercent = 0,
    this.daysLate = 0,
    this.isSaving = false,
    this.errorMessage,
    this.readOnly = false,
    required this.onSave,
  });

  final double maxScore;
  final double? initialScore;
  final String? initialFeedback;
  final double latePenaltyPercent;
  final int daysLate;
  final bool isSaving;
  final String? errorMessage;
  final bool readOnly;
  final Future<void> Function(double score, String? feedback) onSave;

  @override
  State<GradingPanel> createState() => _GradingPanelState();
}

class _GradingPanelState extends State<GradingPanel> {
  late final TextEditingController _scoreController;
  late final TextEditingController _feedbackController;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.initialScore == null
          ? ''
          : _formatScore(widget.initialScore!),
    );
    _feedbackController = TextEditingController(
      text: widget.initialFeedback ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant GradingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialScore != widget.initialScore &&
        !_scoreController.text.contains('.')) {
      _scoreController.text = widget.initialScore == null
          ? ''
          : _formatScore(widget.initialScore!);
    }
    if (oldWidget.initialFeedback != widget.initialFeedback &&
        _feedbackController.text.isEmpty) {
      _feedbackController.text = widget.initialFeedback ?? '';
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedScore = double.tryParse(_scoreController.text.trim()) ?? 0;
    final hasPenalty = widget.daysLate > 0 && widget.latePenaltyPercent > 0;
    final finalScore = hasPenalty
        ? calculateFinalScore(
            originalScore: parsedScore,
            latePenaltyPercent: widget.latePenaltyPercent,
            daysLate: widget.daysLate,
          )
        : parsedScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Grading Panel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _scoreController,
                    enabled: !widget.readOnly && !widget.isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Score (0-${_formatScore(widget.maxScore)})',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: _validationError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _stepButton(-0.5),
                const SizedBox(width: 6),
                _stepButton(0.5),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feedbackController,
              enabled: !widget.readOnly && !widget.isSaving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            if (hasPenalty) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GradingColors.pendingLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GradingColors.pending.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Original Score: ${_formatScore(parsedScore)}'),
                    Text(
                      'Late Penalty: ${_formatScore(widget.latePenaltyPercent)}% × ${widget.daysLate} day(s)',
                    ),
                    Text(
                      'Final Score: ${_formatScore(finalScore)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.readOnly || widget.isSaving
                    ? null
                    : _handleSave,
                icon: widget.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  widget.readOnly
                      ? 'Read Only'
                      : widget.isSaving
                      ? 'Saving...'
                      : 'Save Grade',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepButton(double step) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: widget.readOnly || widget.isSaving
            ? null
            : () {
                final current =
                    double.tryParse(_scoreController.text.trim()) ?? 0;
                final next = (current + step)
                    .clamp(0, widget.maxScore)
                    .toDouble();
                _scoreController.text = _formatScore(next);
                setState(() => _validationError = null);
              },
        icon: Icon(step < 0 ? Icons.remove : Icons.add),
      ),
    );
  }

  Future<void> _handleSave() async {
    final scoreText = _scoreController.text.trim();
    final score = double.tryParse(scoreText);

    if (score == null) {
      setState(() => _validationError = 'Enter a valid score');
      return;
    }

    if (score < 0 || score > widget.maxScore) {
      setState(
        () => _validationError =
            'Score must be between 0 and ${_formatScore(widget.maxScore)}',
      );
      return;
    }

    setState(() => _validationError = null);
    await widget.onSave(
      score,
      _feedbackController.text.trim().isEmpty
          ? null
          : _feedbackController.text.trim(),
    );
  }

  static String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}
