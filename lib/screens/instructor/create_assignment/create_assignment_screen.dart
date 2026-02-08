import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/assignment_model.dart';
import '../../../widgets/instructor/create_assignment/create_assignment.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen>
    with TickerProviderStateMixin {
  // Assignment type
  AssignmentType _selectedType = AssignmentType.assignment;

  // Basic Details (Common)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCourse;
  String? _selectedModule;

  // Instructions (Common)
  final TextEditingController _instructionsController = TextEditingController();

  // Questions (Assignment)
  List<AssignmentQuestion> _questions = [];

  // Attachments (Common)
  List<AssignmentAttachment> _attachments = [];

  // Deadline & Settings (Common)
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _allowLateSubmissions = false;
  bool _plagiarismDetection = true;
  bool _groupWork = false;
  bool _autoGrading = false;
  DifficultyLevel _difficulty = DifficultyLevel.medium;

  // Lab-specific fields
  final TextEditingController _labObjectivesController =
      TextEditingController();
  final TextEditingController _labEquipmentController = TextEditingController();
  final TextEditingController _labSafetyController = TextEditingController();
  final TextEditingController _labProcedureController = TextEditingController();
  String? _selectedLabRoom;
  int _estimatedDuration = 120; // minutes
  bool _requiresLabCoat = false;
  bool _requiresSafetyGlasses = false;
  bool _requiresGloves = false;
  bool _requiresLabReport = true;
  final List<String> _labRooms = [
    'Lab A-101',
    'Lab A-102',
    'Lab B-201',
    'Lab C-301',
    'Virtual Lab',
  ];

  // Project-specific fields
  final TextEditingController _projectScopeController = TextEditingController();
  final TextEditingController _projectObjectivesController =
      TextEditingController();
  final TextEditingController _projectResourcesController =
      TextEditingController();
  List<ProjectMilestone> _milestones = [];
  List<ProjectDeliverable> _deliverables = [];
  int _minTeamSize = 2;
  int _maxTeamSize = 4;
  bool _allowIndividual = false;
  bool _requirePresentation = true;
  bool _requireDocumentation = true;
  bool _peerReview = false;

  // Animation controllers
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnimation;

  // Demo data
  final List<CourseOption> _courses = [
    CourseOption(
      id: '1',
      code: 'CS101',
      name: 'Operating Systems',
      modules: [
        CourseModule(id: 'm1', name: 'Week 1 - Introduction', weekNumber: 1),
        CourseModule(
          id: 'm2',
          name: 'Week 2 - Process Management',
          weekNumber: 2,
        ),
        CourseModule(
          id: 'm3',
          name: 'Week 3 - Memory Management',
          weekNumber: 3,
        ),
        CourseModule(id: 'm4', name: 'Week 4 - File Systems', weekNumber: 4),
      ],
    ),
    CourseOption(
      id: '2',
      code: 'CS202',
      name: 'Data Structures',
      modules: [
        CourseModule(id: 'm5', name: 'Week 1 - Arrays & Lists', weekNumber: 1),
        CourseModule(id: 'm6', name: 'Week 2 - Trees', weekNumber: 2),
        CourseModule(id: 'm7', name: 'Week 3 - Graphs', weekNumber: 3),
      ],
    ),
    CourseOption(
      id: '3',
      code: 'CS305',
      name: 'Database Systems',
      modules: [
        CourseModule(id: 'm8', name: 'Week 1 - SQL Basics', weekNumber: 1),
        CourseModule(id: 'm9', name: 'Week 2 - Normalization', weekNumber: 2),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOutCubic,
    );
    _headerAnimController.forward();

    // Set default due date
    _dueDate = DateTime.now().add(const Duration(days: 7));
    _dueTime = const TimeOfDay(hour: 23, minute: 59);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    // Lab controllers
    _labObjectivesController.dispose();
    _labEquipmentController.dispose();
    _labSafetyController.dispose();
    _labProcedureController.dispose();
    // Project controllers
    _projectScopeController.dispose();
    _projectObjectivesController.dispose();
    _projectResourcesController.dispose();
    super.dispose();
  }

  // Assignment methods
  void _addQuestion() {
    setState(() {
      _questions.add(
        AssignmentQuestion(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}',
          questionText: '',
          type: QuestionType.shortAnswer,
          points: 10,
        ),
      );
    });
  }

  void _updateQuestion(int index, AssignmentQuestion question) {
    setState(() {
      _questions[index] = question;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  // Project methods
  void _addMilestone() {
    setState(() {
      _milestones.add(
        ProjectMilestone(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          title: '',
          weight: 20,
        ),
      );
    });
  }

  void _updateMilestone(int index, ProjectMilestone milestone) {
    setState(() {
      _milestones[index] = milestone;
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  void _addDeliverable(String type) {
    setState(() {
      _deliverables.add(
        ProjectDeliverable(
          id: 'd_${DateTime.now().millisecondsSinceEpoch}',
          name: type,
          type: type,
        ),
      );
    });
  }

  void _removeDeliverable(int index) {
    setState(() {
      _deliverables.removeAt(index);
    });
  }

  void _chooseFiles() {
    // In real app, use file_picker package
    // For now, add a demo attachment
    setState(() {
      _attachments.add(
        AssignmentAttachment(
          id: 'a_${DateTime.now().millisecondsSinceEpoch}',
          name: 'sample_document.pdf',
          sizeBytes: 1024 * 256, // 256KB
          mimeType: 'application/pdf',
        ),
      );
    });
    _showSnackBar('File attached successfully', isError: false);
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
        _selectedCourse != null &&
        _dueDate != null;
  }

  void _saveDraft() {
    _showSnackBar('Draft saved successfully', isError: false);
  }

  void _showPreview() {
    _showPreviewDialog();
  }

  void _scheduleAssignment() {
    _showScheduleDialog();
  }

  void _assignToClass() {
    if (!_isFormValid) {
      _showSnackBar('Please fill in required fields', isError: true);
      return;
    }
    _showAssignConfirmDialog();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? CreateAssignmentColors.error
            : CreateAssignmentColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPreviewDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final l10n = AppLocalizations.of(context);
    final accentColor = _getTypeColor();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark
                ? CreateAssignmentColors.darkBackground
                : CreateAssignmentColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedType.displayName,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.preview,
                          style: TextStyle(
                            color: CreateAssignmentColors.textPrimaryColor(
                              isDark,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close,
                        color: CreateAssignmentColors.textSecondaryColor(
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: accentColor.withValues(alpha: 0.3)),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: _buildPreviewContent(isDark, l10n, accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPreviewContent(
    bool isDark,
    AppLocalizations l10n,
    Color accentColor,
  ) {
    final commonItems = [
      _buildPreviewSection(
        title: l10n.basicDetails,
        icon: Icons.description_outlined,
        isDark: isDark,
        accentColor: accentColor,
        items: [
          _buildPreviewItem(
            'Title',
            _titleController.text,
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Description',
            _descriptionController.text,
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Course',
            _getCourseNameById(_selectedCourse),
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Module',
            _getModuleNameById(_selectedModule),
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Difficulty',
            _difficulty.displayName,
            isDark,
            accentColor,
          ),
        ],
      ),
    ];

    // Type-specific sections
    switch (_selectedType) {
      case AssignmentType.assignment:
        commonItems.add(
          _buildPreviewSection(
            title: l10n.questions,
            icon: Icons.quiz_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                'Total Questions',
                '${_questions.length}',
                isDark,
                accentColor,
              ),
              if (_questions.isNotEmpty)
                ..._questions.asMap().entries.map(
                  (e) => _buildPreviewItem(
                    'Q${e.key + 1}',
                    e.value.questionText,
                    isDark,
                    accentColor,
                  ),
                ),
            ],
          ),
        );
        commonItems.add(
          _buildPreviewSection(
            title: 'Settings',
            icon: Icons.settings_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                'Auto-Grading',
                _autoGrading ? 'Enabled' : 'Disabled',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                'Plagiarism Detection',
                _plagiarismDetection ? 'Enabled' : 'Disabled',
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        break;

      case AssignmentType.lab:
        commonItems.add(
          _buildPreviewSection(
            title: l10n.labDetails,
            icon: Icons.science_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                l10n.labRoom,
                _selectedLabRoom ?? '-',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.estimatedDuration,
                '$_estimatedDuration ${l10n.hours}',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.labObjectives,
                _labObjectivesController.text,
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.labEquipment,
                _labEquipmentController.text,
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.labProcedure,
                _labProcedureController.text,
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        commonItems.add(
          _buildPreviewSection(
            title: l10n.safetyRequirements,
            icon: Icons.health_and_safety_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                l10n.labCoat,
                _requiresLabCoat ? 'Required' : 'Not Required',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.safetyGlasses,
                _requiresSafetyGlasses ? 'Required' : 'Not Required',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.gloves,
                _requiresGloves ? 'Required' : 'Not Required',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.safetyInstructions,
                _labSafetyController.text,
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.requireLabReport,
                _requiresLabReport ? 'Yes' : 'No',
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        break;

      case AssignmentType.project:
        commonItems.add(
          _buildPreviewSection(
            title: l10n.projectDetails,
            icon: Icons.folder_special_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                l10n.projectScope,
                _projectScopeController.text,
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.learningObjectives,
                _projectObjectivesController.text,
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.resources,
                _projectResourcesController.text,
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        commonItems.add(
          _buildPreviewSection(
            title: l10n.teamConfiguration,
            icon: Icons.groups_outlined,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                l10n.minTeamSize,
                '$_minTeamSize',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.maxTeamSize,
                '$_maxTeamSize',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.allowIndividualWork,
                _allowIndividual ? 'Yes' : 'No',
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        if (_milestones.isNotEmpty) {
          commonItems.add(
            _buildPreviewSection(
              title: l10n.milestones,
              icon: Icons.flag_outlined,
              isDark: isDark,
              accentColor: accentColor,
              items: _milestones
                  .asMap()
                  .entries
                  .map(
                    (e) => _buildPreviewItem(
                      '${e.key + 1}. ${e.value.title}',
                      '${e.value.weight}% weight',
                      isDark,
                      accentColor,
                    ),
                  )
                  .toList(),
            ),
          );
        }
        if (_deliverables.isNotEmpty) {
          commonItems.add(
            _buildPreviewSection(
              title: l10n.deliverables,
              icon: Icons.inventory_2_outlined,
              isDark: isDark,
              accentColor: accentColor,
              items: [
                _buildPreviewItem(
                  'Required',
                  _deliverables.map((d) => d.type).join(', '),
                  isDark,
                  accentColor,
                ),
              ],
            ),
          );
        }
        commonItems.add(
          _buildPreviewSection(
            title: l10n.additionalRequirements,
            icon: Icons.checklist_rounded,
            isDark: isDark,
            accentColor: accentColor,
            items: [
              _buildPreviewItem(
                l10n.requirePresentation,
                _requirePresentation ? 'Yes' : 'No',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.requireDocumentation,
                _requireDocumentation ? 'Yes' : 'No',
                isDark,
                accentColor,
              ),
              _buildPreviewItem(
                l10n.enablePeerReview,
                _peerReview ? 'Yes' : 'No',
                isDark,
                accentColor,
              ),
            ],
          ),
        );
        break;
    }

    // Common sections at the end
    commonItems.add(
      _buildPreviewSection(
        title: '${l10n.attachments} (${_attachments.length})',
        icon: Icons.attach_file_rounded,
        isDark: isDark,
        accentColor: accentColor,
        items: _attachments.isEmpty
            ? [
                _buildPreviewItem(
                  'Files',
                  'No attachments',
                  isDark,
                  accentColor,
                ),
              ]
            : _attachments
                  .map(
                    (a) => _buildPreviewItem(
                      a.name,
                      a.formattedSize,
                      isDark,
                      accentColor,
                    ),
                  )
                  .toList(),
      ),
    );

    commonItems.add(
      _buildPreviewSection(
        title: l10n.deadlineSettings,
        icon: Icons.schedule_rounded,
        isDark: isDark,
        accentColor: accentColor,
        items: [
          _buildPreviewItem(
            'Due Date',
            _formatDueDateTime(),
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Late Submissions',
            _allowLateSubmissions ? 'Allowed' : 'Not Allowed',
            isDark,
            accentColor,
          ),
          _buildPreviewItem(
            'Group Work',
            _groupWork ? 'Enabled' : 'Disabled',
            isDark,
            accentColor,
          ),
        ],
      ),
    );

    return commonItems;
  }

  Widget _buildPreviewSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required Color accentColor,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? CreateAssignmentColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
    String label,
    String value,
    bool isDark,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: CreateAssignmentColors.textPrimaryColor(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (_selectedType) {
      case AssignmentType.assignment:
        return CreateAssignmentColors.primary;
      case AssignmentType.lab:
        return CreateAssignmentColors.lab;
      case AssignmentType.project:
        return CreateAssignmentColors.project;
    }
  }

  void _showScheduleDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    DateTime? scheduleDate;
    TimeOfDay? scheduleTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark
              ? CreateAssignmentColors.darkCard
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Schedule Assignment',
            style: TextStyle(
              color: CreateAssignmentColors.textPrimaryColor(isDark),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: CreateAssignmentColors.primary,
                ),
                title: Text(
                  scheduleDate != null
                      ? '${scheduleDate!.day}/${scheduleDate!.month}/${scheduleDate!.year}'
                      : 'Select Date',
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(hours: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => scheduleDate = date);
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: CreateAssignmentColors.primary,
                ),
                title: Text(
                  scheduleTime != null
                      ? scheduleTime!.format(ctx)
                      : 'Select Time',
                  style: TextStyle(
                    color: CreateAssignmentColors.textPrimaryColor(isDark),
                  ),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setDialogState(() => scheduleTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: CreateAssignmentColors.textSecondaryColor(isDark),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: scheduleDate != null && scheduleTime != null
                  ? () {
                      Navigator.pop(ctx);
                      _showSnackBar(
                        'Assignment scheduled successfully',
                        isError: false,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: CreateAssignmentColors.primary,
              ),
              child: const Text(
                'Schedule',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignConfirmDialog() {
    final isDark = context.read<ThemeBloc>().state.isDark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? CreateAssignmentColors.darkCard
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.assignment_turned_in,
              color: CreateAssignmentColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Assign to Class',
              style: TextStyle(
                color: CreateAssignmentColors.textPrimaryColor(isDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to assign "${_titleController.text}" to the class? Students will be notified immediately.',
          style: TextStyle(
            color: CreateAssignmentColors.textSecondaryColor(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: CreateAssignmentColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar(
                'Assignment created and sent to students!',
                isError: false,
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) context.pop();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CreateAssignmentColors.primary,
            ),
            child: const Text('Assign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getCourseNameById(String? id) {
    if (id == null) return '';
    final course = _courses.firstWhere(
      (c) => c.id == id,
      orElse: () => CourseOption(id: '', code: '', name: '', modules: []),
    );
    return course.displayName;
  }

  String _getModuleNameById(String? id) {
    if (id == null) return '';
    for (final course in _courses) {
      for (final module in course.modules) {
        if (module.id == id) return module.name;
      }
    }
    return '';
  }

  String _formatDueDateTime() {
    if (_dueDate == null) return '';
    final dateStr = '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}';
    if (_dueTime != null) {
      return '$dateStr at ${_dueTime!.format(context)}';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: CreateAssignmentColors.background(isDark),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark, l10n),
                  Expanded(child: _buildContent(isDark, l10n)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? CreateAssignmentColors.darkCard
              : CreateAssignmentColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildBackButton(isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.createAssignmentTitle,
                        style: TextStyle(
                          color: CreateAssignmentColors.textPrimaryColor(
                            isDark,
                          ),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.createAssignmentSubtitle,
                        style: TextStyle(
                          color: CreateAssignmentColors.textSecondaryColor(
                            isDark,
                          ),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CreateAssignmentColors.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: CreateAssignmentColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AssignmentTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(bool isDark) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? CreateAssignmentColors.darkSurface
              : CreateAssignmentColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.arrow_back,
          color: CreateAssignmentColors.textPrimaryColor(isDark),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    final accentColor = _getTypeColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Basic Details Section (Common)
          CollapsibleSection(
            title: l10n.basicDetails,
            icon: Icons.description_outlined,
            initiallyExpanded: true,
            isDark: isDark,
            accentColor: accentColor,
            child: BasicDetailsSection(
              titleController: _titleController,
              descriptionController: _descriptionController,
              selectedCourseId: _selectedCourse,
              selectedModuleId: _selectedModule,
              courses: _courses,
              onCourseChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                  _selectedModule = null;
                });
              },
              onModuleChanged: (value) {
                setState(() => _selectedModule = value);
              },
              isDark: isDark,
              accentColor: accentColor,
            ),
          ),
          const SizedBox(height: 12),

          // Type-specific sections
          ..._buildTypeSpecificSections(isDark, l10n),

          // Instructions Section (Common)
          CollapsibleSection(
            title: l10n.instructions,
            icon: Icons.edit_note_rounded,
            initiallyExpanded: false,
            isDark: isDark,
            accentColor: accentColor,
            child: InstructionsSection(
              controller: _instructionsController,
              isDark: isDark,
              accentColor: accentColor,
            ),
          ),
          const SizedBox(height: 12),

          // Questions Section (only for Assignment type)
          if (_selectedType == AssignmentType.assignment) ...[
            CollapsibleSection(
              title: '${l10n.questions} (${_questions.length})',
              icon: Icons.quiz_outlined,
              initiallyExpanded: false,
              isDark: isDark,
              accentColor: accentColor,
              child: QuestionsSection(
                questions: _questions,
                onAddQuestion: _addQuestion,
                onUpdateQuestion: _updateQuestion,
                onRemoveQuestion: _removeQuestion,
                isDark: isDark,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Attachments Section (Common)
          CollapsibleSection(
            title: '${l10n.attachments} (${_attachments.length})',
            icon: Icons.attach_file_rounded,
            initiallyExpanded: false,
            isDark: isDark,
            accentColor: accentColor,
            child: AttachmentsSection(
              attachments: _attachments,
              onChooseFiles: _chooseFiles,
              onRemoveAttachment: _removeAttachment,
              isDark: isDark,
              accentColor: accentColor,
            ),
          ),
          const SizedBox(height: 12),

          // Deadline & Settings Section (Common)
          CollapsibleSection(
            title: l10n.deadlineSettings,
            icon: Icons.schedule_rounded,
            initiallyExpanded: false,
            isDark: isDark,
            accentColor: accentColor,
            child: DeadlineSettingsSection(
              dueDate: _dueDate,
              dueTime: _dueTime,
              allowLateSubmissions: _allowLateSubmissions,
              plagiarismDetection: _plagiarismDetection,
              groupWork: _groupWork,
              autoGrading: _selectedType == AssignmentType.assignment
                  ? _autoGrading
                  : false,
              difficulty: _difficulty,
              isDark: isDark,
              accentColor: accentColor,
              onDueDateChanged: (date) => setState(() => _dueDate = date),
              onDueTimeChanged: (time) => setState(() => _dueTime = time),
              onAllowLateChanged: (v) =>
                  setState(() => _allowLateSubmissions = v),
              onPlagiarismChanged: (v) =>
                  setState(() => _plagiarismDetection = v),
              onGroupWorkChanged: (v) => setState(() => _groupWork = v),
              onAutoGradingChanged: (v) => setState(() => _autoGrading = v),
              onDifficultyChanged: (d) => setState(() => _difficulty = d),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          ActionButtons(
            isDark: isDark,
            onDraft: _saveDraft,
            onPreview: _showPreview,
            onSchedule: _scheduleAssignment,
            onAssign: _assignToClass,
            isAssignEnabled: _isFormValid,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildTypeSpecificSections(bool isDark, AppLocalizations l10n) {
    switch (_selectedType) {
      case AssignmentType.lab:
        return [
          CollapsibleSection(
            title: 'Lab Details',
            accentColor: CreateAssignmentColors.lab,
            icon: Icons.science_outlined,
            initiallyExpanded: true,
            isDark: isDark,
            child: LabDetailsSection(
              objectivesController: _labObjectivesController,
              equipmentController: _labEquipmentController,
              safetyController: _labSafetyController,
              procedureController: _labProcedureController,
              selectedLabRoom: _selectedLabRoom,
              estimatedDuration: _estimatedDuration,
              requiresLabCoat: _requiresLabCoat,
              requiresSafetyGlasses: _requiresSafetyGlasses,
              requiresGloves: _requiresGloves,
              requiresLabReport: _requiresLabReport,
              labRooms: _labRooms,
              isDark: isDark,
              onLabRoomChanged: (v) => setState(() => _selectedLabRoom = v),
              onDurationChanged: (v) => setState(() => _estimatedDuration = v),
              onLabCoatChanged: (v) => setState(() => _requiresLabCoat = v),
              onSafetyGlassesChanged: (v) =>
                  setState(() => _requiresSafetyGlasses = v),
              onGlovesChanged: (v) => setState(() => _requiresGloves = v),
              onLabReportChanged: (v) => setState(() => _requiresLabReport = v),
            ),
          ),
          const SizedBox(height: 12),
        ];

      case AssignmentType.project:
        return [
          CollapsibleSection(
            title: 'Project Details',
            accentColor: CreateAssignmentColors.project,
            icon: Icons.folder_special_outlined,
            initiallyExpanded: true,
            isDark: isDark,
            child: ProjectDetailsSection(
              scopeController: _projectScopeController,
              objectivesController: _projectObjectivesController,
              resourcesController: _projectResourcesController,
              milestones: _milestones,
              deliverables: _deliverables,
              minTeamSize: _minTeamSize,
              maxTeamSize: _maxTeamSize,
              allowIndividual: _allowIndividual,
              requirePresentation: _requirePresentation,
              requireDocumentation: _requireDocumentation,
              peerReview: _peerReview,
              isDark: isDark,
              onAddMilestone: _addMilestone,
              onUpdateMilestone: _updateMilestone,
              onRemoveMilestone: _removeMilestone,
              onAddDeliverable: _addDeliverable,
              onRemoveDeliverable: _removeDeliverable,
              onMinTeamSizeChanged: (v) => setState(() => _minTeamSize = v),
              onMaxTeamSizeChanged: (v) => setState(() => _maxTeamSize = v),
              onAllowIndividualChanged: (v) =>
                  setState(() => _allowIndividual = v),
              onRequirePresentationChanged: (v) =>
                  setState(() => _requirePresentation = v),
              onRequireDocumentationChanged: (v) =>
                  setState(() => _requireDocumentation = v),
              onPeerReviewChanged: (v) => setState(() => _peerReview = v),
            ),
          ),
          const SizedBox(height: 12),
        ];

      case AssignmentType.assignment:
        return [];
    }
  }
}
