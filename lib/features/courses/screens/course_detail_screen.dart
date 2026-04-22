import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (selectedDate == null || !context.mounted) {
      return;
    }

    final topicController = TextEditingController();
    final notesController = TextEditingController();

    final bool shouldBook =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Book Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Date: ${_formatDate(selectedDate)}'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic (optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    minLines: 2,
                    maxLines: 4,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Book'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldBook || !context.mounted) {
      return;
    }

    final apiDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    context.read<CourseDetailBloc>().add(
      BookOfficeHourAppointment(
        slotId: slot.slotId,
        instructorId: slot.instructorId,
        appointmentDate: apiDate,
        topic: topicController.text.trim(),
        notes: notesController.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'TBD';
    }
    final normalized = date.toLocal();
    return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
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
