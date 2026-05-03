import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/instructor/teaching_course_model.dart';
import '../../models/labs/lab_model.dart';
import '../../services/api/lab_service.dart';
import '../../widgets/instructor/labs/lab_create_form.dart';
import '../../widgets/instructor/labs/lab_editor_instruction_file_uploader.dart';
import '../../widgets/instructor/shared/instructor_colors.dart';
import '../../widgets/ta/shared/ta_colors.dart';

class LabEditorSaveResult {
  const LabEditorSaveResult({
    this.lab,
    this.errorMessage,
  });

  final LabModel? lab;
  final String? errorMessage;

  bool get isSuccess => lab != null && (errorMessage == null || errorMessage!.trim().isEmpty);
}

class LabEditorScreen extends StatefulWidget {
  const LabEditorScreen({
    super.key,
    required this.courses,
    required this.labService,
    required this.onSave,
    this.existingLab,
    this.role = LabComposerRole.instructor,
  });

  final List<TeachingCourseModel> courses;
  final LabService labService;
  final Future<LabEditorSaveResult> Function(Map<String, dynamic> payload) onSave;
  final LabModel? existingLab;
  final LabComposerRole role;

  @override
  State<LabEditorScreen> createState() => _LabEditorScreenState();
}

class _LabEditorScreenState extends State<LabEditorScreen> {
  final GlobalKey<LabCreateFormState> _formKey = GlobalKey<LabCreateFormState>();
  bool _submitting = false;
  LabModel? _savedLab;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isTA = widget.role == LabComposerRole.ta;

    return Scaffold(
      backgroundColor: isTA
          ? TAColors.scaffoldColor(isDark)
          : InstructorColors.background(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.existingLab == null
              ? l10n.labEditorCreateScreenTitle
              : l10n.labEditorEditScreenTitle,
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: l10n.cancel,
          ),
        ],
      ),
      body: LabCreateForm(
        key: _formKey,
        courses: widget.courses,
        labService: widget.labService,
        existingLab: widget.existingLab,
        activeLab: _savedLab,
        submitting: _submitting,
        role: widget.role,
        onSubmit: (payload) async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          setState(() => _submitting = true);
          final result = await widget.onSave(payload);
          if (!mounted) {
            return;
          }

          final message = result.errorMessage;
          final savedLab = result.lab;

          if (message != null && message.trim().isNotEmpty) {
            setState(() => _submitting = false);
            messenger.showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (savedLab == null) {
            setState(() => _submitting = false);
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.failed),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          setState(() {
            _savedLab = savedLab;
          });

          final formState = _formKey.currentState;
          final savedLabId = savedLab.labId ?? int.tryParse(savedLab.id) ?? 0;
          final uploadResult = formState == null
              ? const PendingLabInstructionUploadResult()
              : await formState.uploadPendingInstructionFiles(savedLabId);

          if (!mounted) {
            return;
          }

          setState(() => _submitting = false);

          if (uploadResult.failureCount > 0) {
            final failedPreview = uploadResult.failedFileNames.take(2).join(', ');
            final suffix = failedPreview.isEmpty ? '' : ': $failedPreview';
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  l10n.labEditorInstructionUploadPartialFailure(
                    uploadResult.failureCount,
                    suffix,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (uploadResult.successCount > 0) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  l10n.labEditorInstructionUploadSuccess(uploadResult.successCount),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          navigator.pop<LabModel>(savedLab);
        },
      ),
    );
  }
}
