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

    return PopScope(
      canPop: !widget.isSubmitting,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.radius24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: EdgeInsets.only(top: responsive.p12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    responsive.p16,
                    responsive.p12,
                    responsive.p16,
                    responsive.p16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroHeader(context, responsive),
                      if (widget.lab.isPastDue) ...[
                        SizedBox(height: responsive.p14),
                        _buildLateWarning(context),
                      ],
                      SizedBox(height: responsive.p16),
                      _buildSummaryStrip(context, responsive),
                      SizedBox(height: responsive.p16),
                      _buildWorkspaceSurface(context, responsive),
                    ],
                  ),
                ),
              ),
              _buildBottomActionBar(context, responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ResponsiveUtil responsive) {
    final courseCode = widget.lab.course?.code ?? 'LAB';
    final labLabel = widget.lab.labNumber == null
        ? 'Lab'
        : 'Lab ${widget.lab.labNumber}';
    final dueLabel = widget.lab.isPastDue ? 'Past due' : 'Ready to submit';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              top: -34,
              right: -12,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -46,
              left: -22,
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.p18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: responsive.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Work',
                              style: TextStyle(
                                fontSize: responsive.fontSize20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: responsive.p4),
                            Text(
                              'Package your answer, upload your file, and send a clean lab submission in one place.',
                              style: TextStyle(
                                fontSize: responsive.fontSize13,
                                height: 1.38,
                                color: Colors.white.withValues(alpha: 0.86),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.p14),
                  Wrap(
                    spacing: responsive.p8,
                    runSpacing: responsive.p8,
                    children: [
                      _buildHeroChip(
                        icon: Icons.menu_book_rounded,
                        label: courseCode,
                      ),
                      _buildHeroChip(
                        icon: Icons.science_outlined,
                        label: labLabel,
                      ),
                      _buildHeroChip(
                        icon: Icons.schedule_rounded,
                        label: dueLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(BuildContext context, ResponsiveUtil responsive) {
    final supportedTypes = _normalizedAllowedExtensions();
    final cards = <({IconData icon, String title, String value, Color color})>[
      (
        icon: Icons.edit_note_rounded,
        title: 'Submission',
        value: _canSubmit ? 'Ready' : 'Add text or file',
        color: const Color(0xFF2563EB),
      ),
      (
        icon: Icons.attach_file_rounded,
        title: 'Formats',
        value: supportedTypes.isEmpty ? 'All file types' : '${supportedTypes.length} types',
        color: const Color(0xFF8B5CF6),
      ),
      (
        icon: Icons.flag_rounded,
        title: 'Late policy',
        value: widget.lab.isPastDue ? 'Marked late' : 'On time',
        color: widget.lab.isPastDue
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;
        final spacing = responsive.p10;
        final itemWidth = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: EdgeInsets.all(responsive.p14),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD9E2F0).withValues(alpha: 0.78),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: card.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(card.icon, size: 20, color: card.color),
                    ),
                    SizedBox(width: responsive.p10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                              fontSize: responsive.fontSize12,
                              fontWeight: FontWeight.w700,
                              color: widget.isDark
                                  ? Colors.grey.shade400
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: responsive.p2),
                          Text(
                            card.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: responsive.fontSize13,
                              fontWeight: FontWeight.w800,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _buildWorkspaceSurface(BuildContext context, ResponsiveUtil responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD9E2F0).withValues(alpha: 0.74),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.08 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            icon: Icons.edit_note_rounded,
            title: 'Text Submission',
            subtitle: 'Add context, notes, or a written answer for this lab.',
          ),
          SizedBox(height: responsive.p14),
          TextFormField(
            controller: _textController,
            maxLines: 7,
            enabled: !widget.isSubmitting,
            onChanged: (_) {
              if (_validationError != null) {
                setState(() {
                  _validationError = null;
                });
              } else {
                setState(() {});
              }
            },
            style: TextStyle(
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Write your submission notes here...',
              filled: true,
              fillColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFFD9E2F0).withValues(alpha: 0.72),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: const Color(0xFFD9E2F0).withValues(alpha: 0.72),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
          SizedBox(height: responsive.p18),
          _buildSectionHeader(
            context,
            icon: Icons.attach_file_rounded,
            title: 'File Upload',
            subtitle: 'Attach a deliverable from your device when you are ready.',
          ),
          SizedBox(height: responsive.p14),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.p16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2563EB).withValues(alpha: 0.08),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
                SizedBox(height: responsive.p12),
                Text(
                  'Upload zone',
                  style: TextStyle(
                    fontSize: responsive.fontSize16,
                    fontWeight: FontWeight.w800,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: responsive.p4),
                Text(
                  'Choose one file now, then review the filename before sending.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.fontSize12,
                    height: 1.45,
                    color: widget.isDark
                        ? Colors.grey.shade300
                        : const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: responsive.p14),
                OutlinedButton.icon(
                  onPressed: widget.isSubmitting ? null : _pickFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: BorderSide(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.p18,
                      vertical: responsive.p12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Choose File'),
                ),
                SizedBox(height: responsive.p12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _buildSupportedFilesText(),
                    style: TextStyle(
                      fontSize: responsive.fontSize11,
                      color: widget.isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedFile != null) ...[
            SizedBox(height: responsive.p14),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.p14),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(width: responsive.p10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: responsive.fontSize13,
                            fontWeight: FontWeight.w800,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: responsive.p2),
                        Text(
                          '${_formatFileSize(_selectedFile!.size)} • Ready to send',
                          style: TextStyle(
                            fontSize: responsive.fontSize11,
                            color: widget.isDark
                                ? Colors.grey.shade400
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final responsive = context.responsive;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        ),
        SizedBox(width: responsive.p10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize16,
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: responsive.p2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize12,
                  color: widget.isDark
                      ? Colors.grey.shade400
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, ResponsiveUtil responsive) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.p16,
        responsive.p10,
        responsive.p16,
        responsive.p16,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD9E2F0).withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_validationError != null)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p10),
              child: Text(
                _validationError!,
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: responsive.fontSize12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (widget.isSubmitting)
            Padding(
              padding: EdgeInsets.only(bottom: responsive.p10),
              child: LinearProgressIndicator(
                value: widget.submitProgress > 0
                    ? widget.submitProgress.clamp(0, 1)
                    : null,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: widget.isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
                color: const Color(0xFF2563EB),
              ),
            ),
          Container(
            padding: EdgeInsets.all(responsive.p12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD9E2F0).withValues(alpha: 0.72),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _canSubmit ? 'Submission is ready' : 'Add text or a file',
                        style: TextStyle(
                          fontSize: responsive.fontSize14,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: responsive.p2),
                      Text(
                        widget.isSubmitting
                            ? 'Uploading your latest lab work...'
                            : 'Submit when your answer and attachments look complete.',
                        style: TextStyle(
                          fontSize: responsive.fontSize12,
                          color: widget.isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: responsive.p12),
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: (!_canSubmit || widget.isSubmitting)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade500,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.p18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateWarning(BuildContext context) {
    final responsive = context.responsive;

    return Container(
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

    final maxFileSizeMb = widget.lab.maxFileSizeMb;
    if (maxFileSizeMb != null && maxFileSizeMb > 0) {
      final maxUploadBytes = (maxFileSizeMb * 1024 * 1024).round();
      if (file.size > maxUploadBytes) {
        return 'File is too large. Maximum size is ${_formatMaxFileSize(maxFileSizeMb)}.';
      }
    }

    final extension = file.extension?.toLowerCase();
    final allowedExtensions = _normalizedAllowedExtensions();
    if (allowedExtensions.isNotEmpty &&
        (extension == null || !allowedExtensions.contains(extension))) {
      return 'Unsupported file type. Allowed: ${allowedExtensions.join(', ')}.';
    }

    return null;
  }

  Set<String> _normalizedAllowedExtensions() {
    final raw = widget.lab.allowedFileTypes?.trim();
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }

    return raw
        .split(',')
        .map((item) => item.trim().replaceAll('.', '').toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  String _buildSupportedFilesText() {
    final allowedExtensions = _normalizedAllowedExtensions();
    final maxFileSizeMb = widget.lab.maxFileSizeMb;

    final fileTypeText = allowedExtensions.isEmpty
        ? 'All file types'
        : allowedExtensions.join(', ');
    final sizeText = maxFileSizeMb == null || maxFileSizeMb <= 0
        ? 'no size limit specified'
        : 'max ${_formatMaxFileSize(maxFileSizeMb)}';

    return 'Supported: $fileTypeText ($sizeText)';
  }

  String _formatMaxFileSize(double value) {
    final rounded = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '${rounded}MB';
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
