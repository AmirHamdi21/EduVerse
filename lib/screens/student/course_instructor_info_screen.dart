import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/courses/courses_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../models/admin/admin_periods_models.dart';

class CourseInstructorInfoScreen extends StatefulWidget {
  final int instructorId;
  final String instructorName;
  final int? courseId;
  final int? sectionId;
  final String? staffRoleLabel;

  const CourseInstructorInfoScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
    this.courseId,
    this.sectionId,
    this.staffRoleLabel,
  });

  @override
  State<CourseInstructorInfoScreen> createState() =>
      _CourseInstructorInfoScreenState();
}

class _CourseInstructorInfoScreenState
    extends State<CourseInstructorInfoScreen> {
  late final CourseDetailBloc _courseDetailBloc;

  @override
  void initState() {
    super.initState();

    final coursesBloc = context.read<CoursesBloc>();
    _courseDetailBloc =
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
          ..add(LoadInstructorProfile(userId: widget.instructorId))
          ..add(const LoadMyAppointments());

    final sectionId = widget.sectionId;
    if (sectionId != null && sectionId > 0) {
      _courseDetailBloc.add(LoadSectionStaff(sectionId: sectionId));
    }
  }

  @override
  void dispose() {
    _courseDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF5F7FA),
      body: BlocProvider.value(
        value: _courseDetailBloc,
        child: BlocConsumer<CourseDetailBloc, CourseDetailState>(
          listenWhen: (previous, current) =>
              previous.error != current.error ||
              previous.bookingMessage != current.bookingMessage,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            if (state.error != null && state.error!.isNotEmpty) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.error!)));
            } else if (state.bookingMessage != null &&
                state.bookingMessage!.isNotEmpty) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.bookingMessage!)));
            }
          },
          builder: (context, state) {
            final profile = state.selectedProfile;
            final title = (profile?.fullName.trim().isNotEmpty ?? false)
                ? profile!.fullName
                : widget.instructorName;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF1E293B), Color(0xFF0B1120)]
                            : const [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${widget.staffRoleLabel ?? 'Instructor'} Info & Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.24),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.20,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profile?.role ??
                                              widget.staffRoleLabel ??
                                              'Course Instructor',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (profile != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.email,
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (profile.officeLocation != null &&
                                        profile.officeLocation!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Office: ${profile.officeLocation!}',
                                        style: const TextStyle(
                                          color: Color(0xFF475569),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    if (profile.bio != null &&
                                        profile.bio!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        profile.bio!,
                                        style: const TextStyle(
                                          color: Color(0xFF1E293B),
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ] else if (state.isLoadingProfile) ...[
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SectionTitle(
                        title: 'Office Hour Slots',
                        subtitle:
                            'Choose an available slot and book it instantly',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      if (state.isLoadingOfficeHours)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      if (state.officeHourSlots.isEmpty)
                        _EmptyCard(
                          text:
                              'No active office-hour slots available right now.',
                          isDark: isDark,
                        )
                      else
                        ...state.officeHourSlots.map(
                          (slot) => _SlotCard(
                            isDark: isDark,
                            slot: slot,
                            isBooking: state.isBookingAppointment,
                            onBook: () => _openBookingDialog(context, slot),
                          ),
                        ),
                      const SizedBox(height: 18),
                      _SectionTitle(
                        title: 'My Appointments',
                        subtitle: 'Latest bookings and status updates',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      if (state.isLoadingAppointments &&
                          state.appointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      if (state.appointments.isEmpty)
                        _EmptyCard(
                          text: 'No appointments booked yet.',
                          isDark: isDark,
                        )
                      else
                        ...state.appointments.map(
                          (appointment) => _AppointmentCard(
                            appointment: appointment,
                            isDark: isDark,
                          ),
                        ),
                      if (widget.sectionId != null &&
                          widget.sectionId! > 0) ...[
                        const SizedBox(height: 18),
                        _SectionTitle(
                          title: 'Teaching Team',
                          subtitle:
                              'Instructors and assistants assigned to this section',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        if (state.instructors.isEmpty &&
                            state.teachingAssistants.isEmpty)
                          _EmptyCard(
                            text: 'Section staff is still loading.',
                            isDark: isDark,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...state.instructors.map(
                                (item) => Chip(
                                  avatar: const Icon(
                                    Icons.school_outlined,
                                    size: 16,
                                  ),
                                  label: Text(item.fullName),
                                ),
                              ),
                              ...state.teachingAssistants.map(
                                (item) => Chip(
                                  avatar: const Icon(
                                    Icons.groups_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    item.fullName.trim().isNotEmpty
                                        ? item.fullName
                                        : item.email,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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

    final shouldBook =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
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
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
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

    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final bool isDark;

  const _EmptyCard({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF475569),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final bool isDark;
  final bool isBooking;
  final OfficeHourSlotModel slot;
  final VoidCallback onBook;

  const _SlotCard({
    required this.isDark,
    required this.isBooking,
    required this.slot,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final isFull =
        slot.maxAppointments > 0 &&
        slot.currentAppointments >= slot.maxAppointments;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${slot.dayOfWeek.toUpperCase()} • ${slot.startTime} - ${slot.endTime}',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${slot.location} • ${slot.mode} • ${slot.currentAppointments}/${slot.maxAppointments}',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: (isFull || isBooking) ? null : onBook,
              icon: const Icon(Icons.event_available_outlined),
              label: Text(isFull ? 'Full' : 'Book'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final bool isDark;
  final OfficeHourAppointmentModel appointment;

  const _AppointmentCard({required this.isDark, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final date = appointment.appointmentDate;
    final formatted = date == null
        ? 'TBD'
        : '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF155DFC).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: Color(0xFF155DFC),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.topic,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formatted • ${appointment.status}',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
