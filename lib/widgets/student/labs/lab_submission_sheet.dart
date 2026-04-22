import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../common/utils/responsive.dart';
import '../../../../models/labs/lab_model.dart';

class LabSubmissionSheet extends StatefulWidget {
  final LabModel lab;
  final bool isDark;
  final bool isSubmitting;
  final double submitProgress;
  final Future<bool> Function(String text) onSubmitText;
  final Future<bool> Function(String filePath, String? submissionText)
  onSubmitFile;

  const LabSubmissionSheet({
    super.key,
    required this.lab,
    required this.isDark,
    required this.isSubmitting,
    required this.submitProgress,
    required this.onSubmitText,
    required this.onSubmitFile,
  });

  @override
  State<LabSubmissionSheet> createState() => _LabSubmissionSheetState();
}

class _LabSubmissionSheetState extends State<LabSubmissionSheet> {
  static const int _maxUploadBytes = 50 * 1024 * 1024;
  static const Set<String> _allowedExtensions = <String>{
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'txt',
    'md',
    'zip',
  };

  final TextEditingController _textController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _validationError;

  bool get _canSubmit {
    final hasText = _textController.text.trim().isNotEmpty;
    final hasFile = _selectedFile?.path != null;
    return hasText || hasFile;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: responsive.p12),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: Row(
                children: [
                  Text(
                    'Submit Work',
                    style: TextStyle(
                      fontSize: responsive.fontSize18,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (widget.lab.isPastDue) _buildLateWarning(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                child: Column(
                  children: [
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Text Submission',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: responsive.p8,
                            right: responsive.p8,
                            bottom: responsive.p12,
                          ),
                          child: TextFormField(
                            controller: _textController,
                            maxLines: 6,
                            enabled: !widget.isSubmitting,
                            onChanged: (_) {
                              if (_validationError != null) {
                                setState(() {
                                  _validationError = null;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Write your submission notes here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.radius12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      initiallyExpanded: false,
                      title: Text(
                        'File Upload',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: responsive.p8,
                            right: responsive.p8,
                            bottom: responsive.p12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                onPressed: widget.isSubmitting
                                    ? null
                                    : _pickFile,
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Choose File'),
                              ),
                              if (_selectedFile != null) ...[
                                SizedBox(height: responsive.p8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(responsive.p10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(
                                      responsive.radius10,
                                    ),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF3B82F6,
                                      ).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file_rounded,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      SizedBox(width: responsive.p8),
                                      Expanded(
                                        child: Text(
                                          '${_selectedFile!.name} (${_formatFileSize(_selectedFile!.size)})',
                                          style: TextStyle(
                                            fontSize: responsive.fontSize12,
                                            fontWeight: FontWeight.w600,
                                            color: widget.isDark
                                                ? Colors.white
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: widget.isSubmitting
                                            ? null
                                            : () {
                                                setState(() {
                                                  _selectedFile = null;
                                                });
                                              },
                                        icon: const Icon(Icons.close_rounded),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: responsive.p8),
                              Text(
                                'Supported: pdf, doc, docx, ppt, pptx, xls, xlsx, txt, md, zip (max 50MB)',
                                style: TextStyle(
                                  fontSize: responsive.fontSize11,
                                  color: widget.isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_validationError != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                child: Text(
                  _validationError!,
                  style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: responsive.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (widget.isSubmitting)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.p16,
                  responsive.p8,
                  responsive.p16,
                  0,
                ),
                child: LinearProgressIndicator(
                  value: widget.submitProgress > 0
                      ? widget.submitProgress.clamp(0, 1)
                      : null,
                  minHeight: 6,
                  backgroundColor: widget.isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(responsive.p16),
              child: SizedBox(
                width: double.infinity,
                height: responsive.p48,
                child: ElevatedButton.icon(
                  onPressed: (!_canSubmit || widget.isSubmitting)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade500,
                  ),
                  icon: widget.isSubmitting
                      ? SizedBox(
                          width: responsive.p16,
                          height: responsive.p16,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    widget.isSubmitting ? 'Submitting...' : 'Submit',
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLateWarning(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: responsive.p8),
          Expanded(
            child: Text(
              'This lab is past the due date. Your submission will be marked as late.',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final validationError = _validateFile(file);
    if (validationError != null) {
      setState(() {
        _validationError = validationError;
      });
      return;
    }

    setState(() {
      _selectedFile = file;
      _validationError = null;
    });
  }

  String? _validateFile(PlatformFile file) {
    if (file.path == null) {
      return 'Unable to read selected file path.';
    }

    if (file.size > _maxUploadBytes) {
      return 'File is too large. Maximum size is 50MB.';
    }

    final extension = file.extension?.toLowerCase();
    if (extension == null || !_allowedExtensions.contains(extension)) {
      return 'Unsupported file type. Please upload a supported document format.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() {
        _validationError =
            'Please add text and/or choose a file before submitting.';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    bool success;
    final text = _textController.text.trim();

    if (_selectedFile?.path != null) {
      success = await widget.onSubmitFile(
        _selectedFile!.path!,
        text.isEmpty ? null : text,
      );
    } else {
      success = await widget.onSubmitText(text);
    }

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission sent successfully'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Submission failed. Please try again.'),
        backgroundColor: const Color(0xFFEF4444),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _submit,
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }

    const units = <String>['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[unitIndex]}';
  }
}
