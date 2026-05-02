import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/courses/courses_bloc.dart';
import '../../../features/courses/bloc/material_viewer/material_viewer_bloc.dart';
import '../../../models/admin/admin_periods_models.dart';
import '../../../models/core/enrollment_model.dart';
import '../../../models/materials/course_material_model.dart';
import '../../../models/materials/material_bundle_model.dart';
import '../../../widgets/student/course_details/course_tab_content.dart';
import '../../../widgets/student/course_details/document_preview_widget.dart';
import '../../../widgets/student/course_details/video_player_widget.dart';
import '../../../widgets/student/course_details/week_accordion.dart';
import '../../../widgets/student/courses/course_model.dart';
import '../../../widgets/student/progress/progress_indicator.dart';
import '../bloc/course_detail/course_detail_bloc.dart';
import '../bloc/course_detail/course_detail_event.dart';
import '../bloc/course_detail/course_detail_state.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseEnrollmentModel enrollment;
  final int initialTabIndex;

  const CourseDetailScreen({
    super.key,
    required this.enrollment,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final coursesBloc = context.read<CoursesBloc>();
    final courseId =
        enrollment.course?.courseId ?? int.tryParse(enrollment.courseId);
    final legacyCourse = _legacyCourse();

    return BlocProvider(
      create: (_) =>
          CourseDetailBloc(
              courseService: coursesBloc.courseService,
              materialService: coursesBloc.materialService,
              assignmentService: coursesBloc.assignmentService,
              labService: coursesBloc.labService,
              enrollmentService: coursesBloc.enrollmentService,
              communicationService: coursesBloc.communicationService,
              publicProfileService: coursesBloc.publicProfileService,
              officeHoursService: coursesBloc.officeHoursService,
            )
            ..add(
              LoadCourseDetail(
                courseId: courseId,
                sectionId: enrollment.sectionId,
                prerequisites: enrollment.prerequisites,
                initialTabIndex: initialTabIndex,
              ),
            )
            ..add(const LoadMyAppointments()),
      child: DefaultTabController(
        length: 4,
        initialIndex: initialTabIndex,
        child: Scaffold(
          appBar: AppBar(
            title: Text(enrollment.course?.courseName ?? 'Course Details'),
            bottom: const TabBar(
              tabs: <Tab>[
                Tab(text: 'Structure'),
                Tab(text: 'Materials'),
                Tab(text: 'Staff & Booking'),
                Tab(text: 'Progress'),
              ],
            ),
          ),
          body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
            builder: (context, state) {
              return TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: CourseTabContent(
                      selectedIndex: 0,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      course: legacyCourse,
                    ),
                  ),
                  _MaterialsTab(
                    state: state,
                    courseId: courseId,
                    coursesBloc: coursesBloc,
                  ),
                  _StaffBookingTab(state: state),
                  _ProgressTab(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  CourseModel _legacyCourse() {
    return CourseModel(
      courseId: enrollment.course?.courseId,
      title: enrollment.course?.courseName ?? 'Course',
      instructor: enrollment.course?.departmentName ?? 'Instructor',
      progress: 0.0,
      nextEvent: '',
      eventDate: '',
      iconBackgroundColor: const Color(0xFF155DFC),
      courseIcon: Icons.school_outlined,
    );
  }
}

class _MaterialsTab extends StatefulWidget {
  final CourseDetailState state;
  final dynamic courseId;
  final CoursesBloc coursesBloc;

  const _MaterialsTab({
    required this.state,
    required this.courseId,
    required this.coursesBloc,
  });

  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  Map<int, List<CourseMaterialModel>> _groupByWeek(
    List<CourseMaterialModel> materials,
  ) {
    final grouped = <int, List<CourseMaterialModel>>{};
    for (final material in materials) {
      grouped
          .putIfAbsent(material.weekNumber ?? 0, () => <CourseMaterialModel>[])
          .add(material);
    }
    return grouped;
  }

  Future<void> _openMaterial(CourseMaterialModel material) async {
    final type = material.materialType.toLowerCase();

    if (type == 'video' || type == 'lecture') {
      await _showMaterialBottomSheet(
        material,
        (courseId) => VideoPlayerWidget(courseId: courseId, material: material),
      );
      return;
    }

    if (type == 'document' || type == 'slide') {
      await _showMaterialBottomSheet(
        material,
        (courseId) =>
            DocumentPreviewWidget(courseId: courseId, material: material),
      );
      return;
    }

    await _openExternalMaterial(material);
  }

  Future<void> _showMaterialBottomSheet(
    CourseMaterialModel material,
    Widget Function(dynamic courseId) contentBuilder,
  ) async {
    final resolvedCourseId = widget.courseId ?? material.courseId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider(
          create: (_) => MaterialViewerBloc(
            materialService: widget.coursesBloc.materialService,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFFFFFFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SingleChildScrollView(
                child: contentBuilder(resolvedCourseId),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openExternalMaterial(CourseMaterialModel material) async {
    final url = material.externalUrl;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No preview link available for this material.'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This material link is invalid.')),
      );
      return;
    }

    // External URL materials are shown directly without bottom sheet
    final type = material.materialType.toLowerCase();
    if (type == 'video' || type == 'lecture') {
      await _showMaterialBottomSheet(
        material,
        (courseId) => VideoPlayerWidget(courseId: courseId, material: material),
      );
    } else if (type == 'document' || type == 'slide') {
      await _showMaterialBottomSheet(
        material,
        (courseId) =>
            DocumentPreviewWidget(courseId: courseId, material: material),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.state.isLoadingMaterials && widget.state.materials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.state.materials.isEmpty) {
      return const Center(child: Text('No materials available'));
    }

    final grouped = _groupByWeek(widget.state.materials);
    final weeks = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekNumber = weeks[index];
        final materials = grouped[weekNumber] ?? const <CourseMaterialModel>[];
        final bundles = MaterialBundleModel.detectBundles(
          materials,
        ).values.toList();

        return WeekAccordion(
          weekNumber: weekNumber,
          materials: materials,
          bundles: bundles,
          isDark: isDark,
          initiallyExpanded: index == 0,
          onMaterialTap: (material) => _openMaterial(material),
        );
      },
    );
  }
}

class _StaffBookingTab extends StatelessWidget {
  final CourseDetailState state;

  const _StaffBookingTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.isLoadingStaff &&
        state.instructors.isEmpty &&
        state.teachingAssistants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.bookingMessage != null && state.bookingMessage!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.bookingMessage!,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (state.error != null && state.error!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              state.error!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        _SectionHeader(
          title: 'Latest Announcements',
          subtitle: 'Course updates from your teaching team',
        ),
        const SizedBox(height: 8),
        if (state.isLoadingAnnouncements && state.announcements.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (state.announcements.isEmpty)
          _EmptyHint(
            message: 'No announcements yet for this course.',
            isDark: isDark,
          )
        else
          ...state.announcements.take(3).map((announcement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(
                    announcement.content,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 8),
        _SectionHeader(
          title: 'Instructors',
          subtitle: 'Open profile and office hours for booking',
        ),
        const SizedBox(height: 8),
        if (state.instructors.isEmpty)
          _EmptyHint(
            message: 'No instructors found for this section.',
            isDark: isDark,
          )
        else
          ...state.instructors.map((instructor) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ListTile(
                title: Text(instructor.fullName),
                subtitle: Text(
                  instructor.email.isEmpty
                      ? instructor.role
                      : '${instructor.role} • ${instructor.email}',
                ),
                trailing: TextButton(
                  onPressed: () {
                    context.read<CourseDetailBloc>().add(
                      LoadInstructorProfile(userId: instructor.userId),
                    );
                  },
                  child: const Text('View Profile'),
                ),
              ),
            );
          }),

        const SizedBox(height: 8),
        _SectionHeader(
          title: 'Teaching Assistants',
          subtitle: 'Support staff assigned to your section',
        ),
        const SizedBox(height: 8),
        if (state.teachingAssistants.isEmpty)
          _EmptyHint(message: 'No TAs assigned yet.', isDark: isDark)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.teachingAssistants
                .map(
                  (ta) => Chip(
                    label: Text(
                      ta.fullName.trim().isEmpty ? ta.email : ta.fullName,
                    ),
                    avatar: const Icon(Icons.groups_rounded, size: 16),
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: 12),
        if (state.isLoadingProfile)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(),
          ),
        if (state.selectedProfile != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.selectedProfile!.fullName,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(state.selectedProfile!.email),
                if (state.selectedProfile!.officeLocation != null) ...[
                  const SizedBox(height: 4),
                  Text('Office: ${state.selectedProfile!.officeLocation!}'),
                ],
                if (state.selectedProfile!.bio != null) ...[
                  const SizedBox(height: 6),
                  Text(state.selectedProfile!.bio!),
                ],
              ],
            ),
          ),

        _SectionHeader(
          title: 'Office Hour Slots',
          subtitle: 'Book a slot with the selected instructor',
        ),
        const SizedBox(height: 8),
        if (state.isLoadingOfficeHours)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (state.officeHourSlots.isEmpty)
          _EmptyHint(
            message: 'Select an instructor to see available slots.',
            isDark: isDark,
          )
        else
          ...state.officeHourSlots.map((slot) {
            final isFull =
                slot.maxAppointments > 0 &&
                slot.currentAppointments >= slot.maxAppointments;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ListTile(
                title: Text(
                  '${slot.dayOfWeek.toUpperCase()} • ${slot.startTime} - ${slot.endTime}',
                ),
                subtitle: Text(
                  '${slot.location} • ${slot.mode} • ${slot.currentAppointments}/${slot.maxAppointments}',
                ),
                trailing: FilledButton(
                  onPressed: (isFull || state.isBookingAppointment)
                      ? null
                      : () => _openBookingDialog(context, slot),
                  child: const Text('Book'),
                ),
              ),
            );
          }),

        const SizedBox(height: 8),
        _SectionHeader(
          title: 'My Appointments',
          subtitle: 'Your booked and pending office-hour sessions',
        ),
        const SizedBox(height: 8),
        if (state.isLoadingAppointments && state.appointments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (state.appointments.isEmpty)
          _EmptyHint(message: 'No appointments booked yet.', isDark: isDark)
        else
          ...state.appointments.map((appointment) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ListTile(
                title: Text(appointment.topic),
                subtitle: Text(
                  '${_formatDate(appointment.appointmentDate)} • ${appointment.status}',
                ),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _openBookingDialog(
    BuildContext context,
    OfficeHourSlotModel slot,
  ) async {
    final selectedDate = await _pickBookingDate(
      context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (selectedDate == null || !context.mounted) {
      return;
    }

    final request = await _openBookingComposer(
      context,
      slot: slot,
      initialDate: selectedDate,
    );

    if (request == null || !context.mounted) {
      return;
    }

    context.read<CourseDetailBloc>().add(
      BookOfficeHourAppointment(
        slotId: slot.slotId,
        instructorId: slot.instructorId,
        appointmentDate: _formatDate(request.date),
        topic: request.topic,
        notes: request.notes,
      ),
    );
  }

  Future<DateTime?> _pickBookingDate(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    const accentDeep = Color(0xFF155DFC);
    DateTime draftDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF101828) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0xFFD8E1EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[accentColor, accentDeep],
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select date',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('EEE, MMM d').format(draftDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: accentColor,
                            ),
                          ),
                          child: CalendarDatePicker(
                            initialDate: draftDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 180),
                            ),
                            onDateChanged: (value) {
                              setSheetState(() => draftDate = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => Navigator.of(
                                  sheetContext,
                                ).pop(draftDate),
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                ),
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<_StaffBookingRequest?> _openBookingComposer(
    BuildContext context, {
    required OfficeHourSlotModel slot,
    required DateTime initialDate,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;
    const accentDeep = Color(0xFF155DFC);
    final topicController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = initialDate;

    final result = await showModalBottomSheet<_StaffBookingRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF101828) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.16)
                                  : const Color(0xFFD8E1EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF101828),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                accentColor.withValues(alpha: 0.16),
                                accentDeep.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${slot.dayOfWeek.toUpperCase()} • ${slot.startTime} - ${slot.endTime}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF101828),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${slot.location} • ${_formatMode(slot.mode)}',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF475467),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final picked = await _pickBookingDate(
                                    sheetContext,
                                    initialDate: selectedDate,
                                  );
                                  if (picked != null) {
                                    setSheetState(() => selectedDate = picked);
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Ink(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.76),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _formatLongDate(selectedDate),
                                          style: const TextStyle(
                                            color: Color(0xFF101828),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit_calendar_rounded,
                                        color: accentColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StaffBookingTextField(
                          controller: topicController,
                          labelText: 'Topic (optional)',
                          hintText: 'What do you want to discuss?',
                        ),
                        const SizedBox(height: 12),
                        _StaffBookingTextField(
                          controller: notesController,
                          labelText: 'Notes (optional)',
                          hintText:
                              'Add context, questions, or goals for the meeting.',
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop(
                                    _StaffBookingRequest(
                                      date: selectedDate,
                                      topic: topicController.text.trim(),
                                      notes: notesController.text.trim(),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                ),
                                child: const Text('Book'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'TBD';
    }
    final normalized = date.toLocal();
    return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  String _formatLongDate(DateTime? date) {
    if (date == null) {
      return 'TBD';
    }
    return DateFormat('EEE, MMM d, yyyy').format(date.toLocal());
  }

  String _formatMode(String mode) {
    final normalized = mode.trim().toLowerCase();
    switch (normalized) {
      case 'in_person':
      case 'in person':
        return 'In person';
      case 'online':
        return 'Online';
      case 'hybrid':
        return 'Hybrid';
      default:
        return normalized
            .split(RegExp(r'[_\\s-]+'))
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(subtitle, style: textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  final bool isDark;

  const _EmptyHint({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _StaffBookingRequest {
  final DateTime date;
  final String topic;
  final String notes;

  const _StaffBookingRequest({
    required this.date,
    required this.topic,
    required this.notes,
  });
}

class _StaffBookingTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int minLines;
  final int maxLines;

  const _StaffBookingTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final CourseDetailState state;

  const _ProgressTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.materials.length;
    final viewed = state.materials.where((m) => m.hasBeenViewed).length;

    if (total == 0) {
      return const Center(child: Text('No materials available yet.'));
    }

    final Map<int, int> totalByWeek = <int, int>{};
    final Map<int, int> viewedByWeek = <int, int>{};

    for (final material in state.materials) {
      final week = material.weekNumber ?? 0;
      totalByWeek[week] = (totalByWeek[week] ?? 0) + 1;
      if (material.hasBeenViewed) {
        viewedByWeek[week] = (viewedByWeek[week] ?? 0) + 1;
      }
    }

    final weeks = totalByWeek.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CourseProgressIndicator(totalMaterials: total, viewedMaterials: viewed),
        const SizedBox(height: 20),
        Text(
          'Weekly Breakdown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...weeks.map((week) {
          final weekTotal = totalByWeek[week] ?? 0;
          final weekViewed = viewedByWeek[week] ?? 0;
          final weekProgress = weekTotal == 0 ? 0.0 : weekViewed / weekTotal;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week > 0 ? 'Week $week' : 'Unscheduled',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('Viewed $weekViewed of $weekTotal'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: weekProgress),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
