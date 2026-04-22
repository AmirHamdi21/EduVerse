import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/assignments/assignment_bloc.dart';
import '../../../../bloc/assignments/assignment_event.dart';
import '../../../../bloc/assignments/assignment_state.dart';
import '../../../../common/utils/responsive.dart';
import '../../../../models/assignments/assignment_model.dart';
import '../../../../models/core/enums/assignment_enums.dart' as api;
import 'drive_file_picker.dart';

enum _SubmissionTab { text, link, file }

class SubmissionFormSheet extends StatefulWidget {
  final AssignmentModel assignment;
  final bool isDark;

  const SubmissionFormSheet({
    super.key,
    required this.assignment,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required AssignmentModel assignment,
    required bool isDark,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SubmissionFormSheet(assignment: assignment, isDark: isDark),
      ),
    );
  }

  @override
  State<SubmissionFormSheet> createState() => _SubmissionFormSheetState();
}

class _SubmissionFormSheetState extends State<SubmissionFormSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final List<_SubmissionTab> _tabs;
  late final TabController _tabController;

  File? _localFile;
  DriveFileSelection? _driveFile;
  String? _validationError;
  bool _submitAttempted = false;

  @override
  void initState() {
    super.initState();
    _tabs = _resolveTabs(widget.assignment.submissionType);
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final lateBlocked = _isLateBlocked();
    final lateWarning = _isLateAllowedWithWarning();

    return BlocListener<AssignmentBloc, AssignmentState>(
      listenWhen: (previous, current) {
        return previous.isSubmitting != current.isSubmitting ||
            previous.submitError != current.submitError;
      },
      listener: (context, state) {
        if (!_submitAttempted || state.isSubmitting) {
          return;
        }

        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
          _submitAttempted = false;
          return;
        }

        _submitAttempted = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission sent successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop();
      },
      child: Container(
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
                      'Submit Assignment',
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              if (lateBlocked) _buildLateBlockedBanner(context),
              if (!lateBlocked && lateWarning) _buildLateWarningBanner(context),
              if (_tabs.length > 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.p16),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF3B82F6),
                    labelColor: const Color(0xFF3B82F6),
                    unselectedLabelColor: widget.isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                    tabs: _tabs
                        .map((tab) => Tab(text: _labelForTab(tab)))
                        .toList(),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(responsive.p16),
                  child: _tabs.length == 1
                      ? _buildTabContent(context, _tabs.first)
                      : TabBarView(
                          controller: _tabController,
                          children: _tabs
                              .map((tab) => _buildTabContent(context, tab))
                              .toList(),
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
              BlocBuilder<AssignmentBloc, AssignmentState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      if (state.isSubmitting)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.p16,
                          ),
                          child: LinearProgressIndicator(
                            value: state.submitProgress > 0
                                ? state.submitProgress.clamp(0, 1)
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
                            onPressed: lateBlocked || state.isSubmitting
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade500,
                            ),
                            icon: state.isSubmitting
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
                              state.isSubmitting
                                  ? 'Submitting...'
                                  : 'Submit Assignment',
                              style: TextStyle(
                                fontSize: responsive.fontSize14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, _SubmissionTab tab) {
    switch (tab) {
      case _SubmissionTab.text:
        return TextSubmissionTab(
          controller: _textController,
          isDark: widget.isDark,
        );
      case _SubmissionTab.link:
        return LinkSubmissionTab(
          controller: _linkController,
          isDark: widget.isDark,
        );
      case _SubmissionTab.file:
        return FileSubmissionTab(
          isDark: widget.isDark,
          localFile: _localFile,
          driveFile: _driveFile,
          onPickLocal: _pickLocalFile,
          onPickDrive: _pickDriveFile,
          onClearSelection: () {
            setState(() {
              _localFile = null;
              _driveFile = null;
            });
          },
          notesController: _noteController,
        );
    }
  }

  Widget _buildLateBlockedBanner(BuildContext context) {
    final responsive = context.responsive;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.p16),
      padding: EdgeInsets.all(responsive.p12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(responsive.radius12),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
          SizedBox(width: responsive.p8),
          Expanded(
            child: Text(
              'Submission deadline has passed and late submissions are not accepted.',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateWarningBanner(BuildContext context) {
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
              'Late submission is allowed. ${widget.assignment.latePenaltyPercent.toStringAsFixed(0)}% penalty may apply.',
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

  List<_SubmissionTab> _resolveTabs(api.SubmissionType submissionType) {
    switch (submissionType) {
      case api.SubmissionType.text:
        return const <_SubmissionTab>[_SubmissionTab.text];
      case api.SubmissionType.link:
        return const <_SubmissionTab>[_SubmissionTab.link];
      case api.SubmissionType.file:
        return const <_SubmissionTab>[_SubmissionTab.file];
      case api.SubmissionType.multiple:
      case api.SubmissionType.unknown:
        return const <_SubmissionTab>[
          _SubmissionTab.text,
          _SubmissionTab.link,
          _SubmissionTab.file,
        ];
    }
  }

  String _labelForTab(_SubmissionTab tab) {
    switch (tab) {
      case _SubmissionTab.text:
        return 'Text';
      case _SubmissionTab.link:
        return 'Link';
      case _SubmissionTab.file:
        return 'File';
    }
  }

  bool _isLateBlocked() {
    return widget.assignment.dueDate.isBefore(DateTime.now()) &&
        !widget.assignment.lateSubmissionAllowed;
  }

  bool _isLateAllowedWithWarning() {
    return widget.assignment.dueDate.isBefore(DateTime.now()) &&
        widget.assignment.lateSubmissionAllowed;
  }

  Future<void> _pickLocalFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) {
      return;
    }

    final platformFile = result.files.first;
    final path = platformFile.path;
    if (path == null) {
      return;
    }

    final validationError = _validateFile(platformFile);
    if (validationError != null) {
      setState(() {
        _validationError = validationError;
      });
      return;
    }

    setState(() {
      _localFile = File(path);
      _driveFile = null;
      _validationError = null;
    });
  }

  Future<void> _pickDriveFile() async {
    final selected = await DriveFilePicker.show(context, isDark: widget.isDark);

    if (selected == null) {
      return;
    }

    setState(() {
      _driveFile = selected;
      _localFile = null;
      _validationError = null;
    });
  }

  String? _validateFile(PlatformFile platformFile) {
    final maxBytes = widget.assignment.maxFileSizeMb * 1024 * 1024;
    if (widget.assignment.maxFileSizeMb > 0 && platformFile.size > maxBytes) {
      return 'File exceeds ${widget.assignment.maxFileSizeMb}MB limit';
    }

    final allowed = widget.assignment.allowedFileTypes;
    if (allowed != null && allowed.isNotEmpty) {
      final extension = (platformFile.extension ?? '').toLowerCase();
      final normalizedAllowed = allowed
          .map((item) => item.replaceAll('.', '').toLowerCase())
          .toSet();
      if (!normalizedAllowed.contains(extension)) {
        return 'File type not allowed. Allowed: ${normalizedAllowed.join(', ')}';
      }
    }

    return null;
  }

  void _submit() {
    final activeTab = _tabs.length == 1
        ? _tabs.first
        : _tabs[_tabController.index];

    setState(() {
      _validationError = null;
    });

    final assignmentId = widget.assignment.assignmentId > 0
        ? widget.assignment.assignmentId
        : int.tryParse(widget.assignment.id) ?? 0;

    if (assignmentId <= 0) {
      setState(() {
        _validationError = 'Invalid assignment id';
      });
      return;
    }

    switch (activeTab) {
      case _SubmissionTab.text:
        final text = _textController.text.trim();
        if (text.isEmpty) {
          setState(() {
            _validationError = 'Please enter your submission text';
          });
          return;
        }
        _submitAttempted = true;
        context.read<AssignmentBloc>().add(
          SubmitTextAssignment(
            assignmentId: assignmentId,
            submissionText: text,
          ),
        );
        return;
      case _SubmissionTab.link:
        final link = _linkController.text.trim();
        final uri = Uri.tryParse(link);
        if (link.isEmpty || uri == null || !uri.hasScheme) {
          setState(() {
            _validationError = 'Please enter a valid URL';
          });
          return;
        }
        _submitAttempted = true;
        context.read<AssignmentBloc>().add(
          SubmitTextAssignment(
            assignmentId: assignmentId,
            submissionLink: link,
          ),
        );
        return;
      case _SubmissionTab.file:
        if (_localFile == null && _driveFile == null) {
          setState(() {
            _validationError = 'Please choose a file from device or Drive';
          });
          return;
        }

        _submitAttempted = true;

        if (_localFile != null) {
          context.read<AssignmentBloc>().add(
            SubmitFileAssignment(
              assignmentId: assignmentId,
              file: _localFile!,
              submissionText: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );
          return;
        }

        // Backend accepts structured text/link submissions, so Drive selection
        // is submitted as a link when a local file is not provided.
        context.read<AssignmentBloc>().add(
          SubmitTextAssignment(
            assignmentId: assignmentId,
            submissionText: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            submissionLink: _driveFile!.webViewLink,
          ),
        );
        return;
    }
  }
}

class TextSubmissionTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const TextSubmissionTab({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return TextField(
      controller: controller,
      maxLines: 10,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: 'Write your answer here...',
        filled: true,
        fillColor: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.45)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class LinkSubmissionTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const LinkSubmissionTab({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.url,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: 'https://example.com/your-work',
        prefixIcon: const Icon(Icons.link_rounded),
        filled: true,
        fillColor: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.45)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.radius12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class FileSubmissionTab extends StatelessWidget {
  final bool isDark;
  final File? localFile;
  final DriveFileSelection? driveFile;
  final VoidCallback onPickLocal;
  final VoidCallback onPickDrive;
  final VoidCallback onClearSelection;
  final TextEditingController notesController;

  const FileSubmissionTab({
    super.key,
    required this.isDark,
    required this.localFile,
    required this.driveFile,
    required this.onPickLocal,
    required this.onPickDrive,
    required this.onClearSelection,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickLocal,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('From Device'),
                ),
              ),
              SizedBox(width: responsive.p8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickDrive,
                  icon: const Icon(Icons.cloud_rounded),
                  label: const Text('From Drive'),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.p12),
          if (localFile != null || driveFile != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.45)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(responsive.radius12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: Color(0xFF3B82F6),
                  ),
                  Expanded(
                    child: Text(
                      localFile != null
                          ? localFile!.path.split(Platform.pathSeparator).last
                          : driveFile!.fileName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onClearSelection,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          SizedBox(height: responsive.p12),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Optional note for instructor...',
              filled: true,
              fillColor: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.45)
                  : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.radius12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
