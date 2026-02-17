import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/courses/course_details_form.dart';
import '../../../widgets/admin/courses/course_staff_assignment.dart';
import '../../../widgets/admin/courses/course_settings.dart';
import '../../../widgets/admin/courses/course_ai_preview.dart';
import '../../../widgets/admin/courses/add_course_header.dart';
import '../../../widgets/admin/courses/add_course_progress_indicator.dart';
import '../../../widgets/admin/courses/add_course_bottom_bar.dart';

/// Admin Add Course Screen
class AdminAddCourseScreen extends StatefulWidget {
  const AdminAddCourseScreen({super.key});

  @override
  State<AdminAddCourseScreen> createState() => _AdminAddCourseScreenState();
}

class _AdminAddCourseScreenState extends State<AdminAddCourseScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Course details
  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedSemester;

  // Staff assignment
  String? _selectedInstructor;
  List<String> _selectedTAs = [];

  // Course settings
  bool _hasLabs = false;
  int _labCount = 1;
  int _maxStudents = 30;
  bool _isActive = true;

  // Syllabus
  String? _syllabusFileName;

  // UI state
  bool _isSubmitting = false;
  bool _isAnalyzing = false;
  int _currentStep = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _nameController.addListener(_onFormChanged);
    _codeController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isAnalyzing = false);
    });
  }

  bool _validateForm() {
    return _nameController.text.isNotEmpty &&
        _codeController.text.isNotEmpty &&
        _selectedDepartment != null &&
        _selectedLevel != null &&
        _selectedSemester != null;
  }

  Future<void> _submitCourse() async {
    if (!_validateForm()) {
      _showValidationError();
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
  }

  void _showValidationError() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.fillRequiredFields)),
          ],
        ),
        backgroundColor: AdminColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context);
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AdminColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AdminColors.greenGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.courseCreatedSuccess,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.courseCreatedMessage,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _resetForm();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminColors.primary,
                      side: BorderSide(color: AdminColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.createAnother),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/admin/courses');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.viewCourses),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _codeController.clear();
      _descriptionController.clear();
      _selectedDepartment = null;
      _selectedLevel = null;
      _selectedSemester = null;
      _selectedInstructor = null;
      _selectedTAs = [];
      _hasLabs = false;
      _labCount = 1;
      _maxStudents = 30;
      _isActive = true;
      _syllabusFileName = null;
      _currentStep = 0;
    });
  }

  void _uploadSyllabus() {
    setState(() => _syllabusFileName = 'course_syllabus.pdf');
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.syllabusUploaded),
          ],
        ),
        backgroundColor: AdminColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitCourse();
    }
  }

  void _handlePrevious() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  AddCourseHeader(
                    isDark: isDark,
                    onReset: _resetForm,
                  ),
                  AddCourseProgressIndicator(
                    isDark: isDark,
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                  ),
                  Expanded(child: _buildBody(isDark)),
                  AddCourseBottomBar(
                    isDark: isDark,
                    currentStep: _currentStep,
                    isSubmitting: _isSubmitting,
                    onPrevious: _handlePrevious,
                    onNext: _handleNext,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        if (isWideScreen) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildFormContent(isDark)),
              Expanded(flex: 2, child: _buildAiPreview(isDark)),
            ],
          );
        }

        return _buildFormContent(isDark, showAiPreview: true);
      },
    );
  }

  Widget _buildAiPreview(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: CourseAiPreview(
        isDark: isDark,
        courseName: _nameController.text,
        courseCode: _codeController.text,
        department: _selectedDepartment,
        level: _selectedLevel,
        semester: _selectedSemester,
        instructor: _selectedInstructor,
        tas: _selectedTAs,
        maxStudents: _maxStudents,
        hasLabs: _hasLabs,
        labCount: _labCount,
        isAnalyzing: _isAnalyzing,
      ),
    );
  }

  Widget _buildFormContent(bool isDark, {bool showAiPreview = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentStep(isDark),
          ),
          if (showAiPreview) ...[
            const SizedBox(height: 16),
            CourseAiPreview(
              isDark: isDark,
              courseName: _nameController.text,
              courseCode: _codeController.text,
              department: _selectedDepartment,
              level: _selectedLevel,
              semester: _selectedSemester,
              instructor: _selectedInstructor,
              tas: _selectedTAs,
              maxStudents: _maxStudents,
              hasLabs: _hasLabs,
              labCount: _labCount,
              isAnalyzing: _isAnalyzing,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return CourseDetailsForm(
          key: const ValueKey('details'),
          isDark: isDark,
          nameController: _nameController,
          codeController: _codeController,
          descriptionController: _descriptionController,
          selectedDepartment: _selectedDepartment,
          selectedLevel: _selectedLevel,
          selectedSemester: _selectedSemester,
          onDepartmentChanged: (v) => setState(() => _selectedDepartment = v),
          onLevelChanged: (v) => setState(() => _selectedLevel = v),
          onSemesterChanged: (v) => setState(() => _selectedSemester = v),
          onUploadSyllabus: _uploadSyllabus,
          syllabusFileName: _syllabusFileName,
        );
      case 1:
        return CourseStaffAssignment(
          key: const ValueKey('staff'),
          isDark: isDark,
          selectedInstructor: _selectedInstructor,
          selectedTAs: _selectedTAs,
          onInstructorChanged: (v) => setState(() => _selectedInstructor = v),
          onTAsChanged: (v) => setState(() => _selectedTAs = v),
        );
      case 2:
        return CourseSettings(
          key: const ValueKey('settings'),
          isDark: isDark,
          hasLabs: _hasLabs,
          labCount: _labCount,
          maxStudents: _maxStudents,
          isActive: _isActive,
          onHasLabsChanged: (v) => setState(() => _hasLabs = v),
          onLabCountChanged: (v) => setState(() => _labCount = v),
          onMaxStudentsChanged: (v) => setState(() => _maxStudents = v),
          onIsActiveChanged: (v) => setState(() => _isActive = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
