import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../models/instructor/teaching_course_model.dart';
import '../../models/labs/lab_model.dart';
import '../../widgets/instructor/labs/lab_create_form.dart';
import '../../widgets/instructor/shared/instructor_colors.dart';
import '../../widgets/ta/shared/ta_colors.dart';

class LabEditorScreen extends StatefulWidget {
  const LabEditorScreen({
    super.key,
    required this.courses,
    required this.onSave,
    this.existingLab,
    this.role = LabComposerRole.instructor,
  });

  final List<TeachingCourseModel> courses;
  final Future<String?> Function(Map<String, dynamic> payload) onSave;
  final LabModel? existingLab;
  final LabComposerRole role;

  @override
  State<LabEditorScreen> createState() => _LabEditorScreenState();
}

class _LabEditorScreenState extends State<LabEditorScreen> {
  bool _submitting = false;

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
        courses: widget.courses,
        existingLab: widget.existingLab,
        submitting: _submitting,
        role: widget.role,
        onSubmit: (payload) async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          setState(() => _submitting = true);
          final message = await widget.onSave(payload);
          if (!mounted) {
            return;
          }

          setState(() => _submitting = false);

          if (message != null && message.trim().isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          navigator.pop<Map<String, dynamic>>(payload);
        },
      ),
    );
  }
}
