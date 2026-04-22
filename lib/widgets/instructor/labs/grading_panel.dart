import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/core/enums/assignment_enums.dart' as assignment_api;
import '../../../models/labs/lab_submission_model.dart';
import '../../../utils/late_penalty_calculator.dart';

class LabGradingPanel extends StatefulWidget {
  const LabGradingPanel({
    super.key,
    required this.submission,
    required this.maxScore,
    required this.onSave,
    this.dueDate,
    this.isSaving = false,
    this.errorMessage,
    this.readOnly = false,
  });

  final LabSubmissionModel submission;
  final double maxScore;
  final DateTime? dueDate;
  final bool isSaving;
  final String? errorMessage;
  final bool readOnly;
  final Future<void> Function(
    double finalScore,
    String? feedback,
    assignment_api.SubmissionStatus status,
    double? latePenaltyPercent,
  )
  onSave;

  @override
  State<LabGradingPanel> createState() => _LabGradingPanelState();
}

class _LabGradingPanelState extends State<LabGradingPanel> {
  late final TextEditingController _originalScoreController;
  late final TextEditingController _finalScoreController;
  late final TextEditingController _feedbackController;
  late assignment_api.SubmissionStatus _selectedStatus;

  bool _manualFinalScoreOverride = false;
  double? _latePenaltyPercent;
  int _daysLate = 0;
  String? _validationError;

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.submission.submissionStatus;
    if (_selectedStatus == assignment_api.SubmissionStatus.unknown) {
      _selectedStatus = assignment_api.SubmissionStatus.submitted;
    }

    final initialScore = widget.submission.score;
    _originalScoreController = TextEditingController(
      text: initialScore == null ? '' : _formatScore(initialScore),
    );
    _finalScoreController = TextEditingController(
      text: initialScore == null ? '' : _formatScore(initialScore),
    );
    _feedbackController = TextEditingController(
      text: widget.submission.feedback ?? '',
    );

    _recalculatePenalty();

    _originalScoreController.addListener(() {
      _manualFinalScoreOverride = false;
      _recalculatePenalty();
    });
    _finalScoreController.addListener(() {
      if (!widget.submission.isLate || widget.dueDate == null) {
        return;
      }
      _manualFinalScoreOverride = true;
    });
  }

  @override
  void dispose() {
    _originalScoreController.dispose();
    _finalScoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentName = _studentName(widget.submission);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              studentName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Submission #${widget.submission.id}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            _buildSubmissionContent(),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _originalScoreController,
                    enabled: !widget.readOnly && !widget.isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText:
                          'Original Score (0-${_formatScore(widget.maxScore)})',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: _validationError,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _finalScoreController,
                    enabled: !widget.readOnly && !widget.isSaving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Final Score',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<assignment_api.SubmissionStatus>(
              key: ValueKey<assignment_api.SubmissionStatus>(_selectedStatus),
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Submission Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const <DropdownMenuItem<assignment_api.SubmissionStatus>>[
                DropdownMenuItem(
                  value: assignment_api.SubmissionStatus.submitted,
                  child: Text('Submitted'),
                ),
                DropdownMenuItem(
                  value: assignment_api.SubmissionStatus.graded,
                  child: Text('Graded'),
                ),
                DropdownMenuItem(
                  value: assignment_api.SubmissionStatus.returned,
                  child: Text('Returned'),
                ),
                DropdownMenuItem(
                  value: assignment_api.SubmissionStatus.resubmit,
                  child: Text('Resubmit'),
                ),
              ],
              onChanged: widget.readOnly || widget.isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _selectedStatus = value);
                    },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _feedbackController,
              enabled: !widget.readOnly && !widget.isSaving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.submission.isLate && widget.dueDate != null) ...<Widget>[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Days Late: $_daysLate'),
                    Text(
                      'Late Penalty: ${_latePenaltyPercent == null ? '-' : _formatScore(_latePenaltyPercent!)}%',
                    ),
                    const Text(
                      'Final Score is editable and can be overridden manually.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.25),
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

  Widget _buildSubmissionContent() {
    final hasText = widget.submission.submissionText?.trim().isNotEmpty == true;
    final hasFile = widget.submission.driveFile != null;

    if (!hasText && !hasFile) {
      return const Text('No submission content available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Submission Content',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (hasText) ...<Widget>[
          MarkdownBody(data: widget.submission.submissionText!.trim()),
          const SizedBox(height: 8),
        ],
        if (hasFile)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: () => _showPreview(
                  widget.submission.driveFile!.iframeUrl.trim().isNotEmpty
                      ? widget.submission.driveFile!.iframeUrl
                      : widget.submission.driveFile!.webViewLink,
                  widget.submission.driveFile!.downloadUrl,
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('Preview'),
              ),
              TextButton.icon(
                onPressed: () =>
                    _openUrl(widget.submission.driveFile!.webViewLink),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open in Drive'),
              ),
              TextButton.icon(
                onPressed: () =>
                    _openUrl(widget.submission.driveFile!.downloadUrl),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download'),
              ),
            ],
          ),
      ],
    );
  }

  void _recalculatePenalty() {
    if (!widget.submission.isLate || widget.dueDate == null) {
      setState(() {
        _latePenaltyPercent = null;
      });
      return;
    }

    final original = double.tryParse(_originalScoreController.text.trim());
    if (original == null) {
      setState(() {
        _latePenaltyPercent = null;
        _daysLate = 0;
      });
      return;
    }

    final result = calculateLabLatePenalty(
      submittedAt: widget.submission.submittedAt,
      dueDate: widget.dueDate!,
      maxScore: original,
    );

    final autoFinal = (original - result.penaltyAmount).clamp(
      0,
      widget.maxScore,
    );

    setState(() {
      _latePenaltyPercent = result.latePenaltyPercent;
      _daysLate = result.daysLate;
      if (!_manualFinalScoreOverride) {
        _finalScoreController.text = _formatScore(autoFinal.toDouble());
      }
    });
  }

  Future<void> _handleSave() async {
    final originalScore = double.tryParse(_originalScoreController.text.trim());
    final finalScore = double.tryParse(_finalScoreController.text.trim());

    if (originalScore == null || finalScore == null) {
      setState(() => _validationError = 'Enter valid numeric scores');
      return;
    }

    if (originalScore < 0 || originalScore > widget.maxScore) {
      setState(
        () => _validationError =
            'Original score must be between 0 and ${_formatScore(widget.maxScore)}',
      );
      return;
    }

    if (finalScore < 0 || finalScore > widget.maxScore) {
      setState(
        () => _validationError =
            'Final score must be between 0 and ${_formatScore(widget.maxScore)}',
      );
      return;
    }

    setState(() => _validationError = null);

    await widget.onSave(
      finalScore,
      _feedbackController.text.trim().isEmpty
          ? null
          : _feedbackController.text.trim(),
      _selectedStatus,
      _latePenaltyPercent,
    );
  }

  Future<void> _showPreview(
    String previewUrl,
    String fallbackDownloadUrl,
  ) async {
    final uri = Uri.tryParse(previewUrl);
    if (uri == null) {
      await _openUrl(fallbackDownloadUrl);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 900,
            height: 620,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(uri),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _studentName(LabSubmissionModel submission) {
    final first = submission.user?.firstName.trim() ?? '';
    final last = submission.user?.lastName.trim() ?? '';
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return 'Student #${submission.userId}';
  }

  String _formatScore(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}
