import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/courses/courses_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_bloc.dart';
import '../../features/courses/bloc/course_detail/course_detail_event.dart';
import '../../features/courses/bloc/course_detail/course_detail_state.dart';
import '../../models/admin/admin_periods_models.dart';
import '../../utils/navigation/safe_back.dart';

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
  static const List<Color> _instructorGradient = <Color>[
    Color(0xFF2B7FFF),
    Color(0xFF155DFC),
  ];
  static const List<Color> _assistantGradient = <Color>[
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
  ];

  late final CourseDetailBloc _courseDetailBloc;

  bool get _isAssistant {
    final role = (widget.staffRoleLabel ?? '').trim().toLowerCase();
    return role == 'ta' || role.contains('assistant');
  }

  List<Color> get _accentGradient =>
      _isAssistant ? _assistantGradient : _instructorGradient;

  Color get _accentColor => _accentGradient.first;
  Color get _accentColorDeep => _accentGradient.last;

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
    final scaffoldColor = isDark
        ? const Color(0xFF09101F)
        : const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: scaffoldColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const <Color>[Color(0xFF09101F), Color(0xFF111A2F)]
                : const <Color>[Color(0xFFF7FAFF), Color(0xFFEEF4FF)],
          ),
        ),
        child: BlocProvider.value(
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
                  ..showSnackBar(
                    SnackBar(content: Text(state.bookingMessage!)),
                  );
              }
            },
            builder: (context, state) {
              final profile = state.selectedProfile;
              final displayName =
                  (profile?.displayName.trim().isNotEmpty ?? false)
                  ? profile!.displayName
                  : widget.instructorName;
              final roleLabel =
                  profile?.primaryRoleLabel ??
                  widget.staffRoleLabel ??
                  'Instructor';

              return Stack(
                children: [
                  Positioned(
                    top: -120,
                    left: -60,
                    child: _BackdropGlow(
                      color: _accentColor.withValues(
                        alpha: isDark ? 0.18 : 0.22,
                      ),
                      size: 240,
                    ),
                  ),
                  Positioned(
                    top: 150,
                    right: -80,
                    child: _BackdropGlow(
                      color: _accentColorDeep.withValues(
                        alpha: isDark ? 0.12 : 0.16,
                      ),
                      size: 220,
                    ),
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Column(
                              children: [
                                _buildTopBar(isDark),
                                const SizedBox(height: 16),
                                _buildHeroCard(
                                  isDark: isDark,
                                  state: state,
                                  displayName: displayName,
                                  roleLabel: roleLabel,
                                ),
                                const SizedBox(height: 16),
                                _buildHighlightsStrip(
                                  isDark: isDark,
                                  state: state,
                                  roleLabel: roleLabel,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildOfficeHoursSection(isDark, state),
                            const SizedBox(height: 18),
                            _buildAppointmentsSection(isDark, state),
                            if (widget.sectionId != null &&
                                widget.sectionId! > 0) ...[
                              const SizedBox(height: 18),
                              _buildTeachingTeamSection(isDark, state),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF101828);
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.92);

    return Row(
      children: [
        _TopActionButton(
          icon: iosBackIcon(context),
          onTap: () => safeBack(context, '/dashboard'),
          isDark: isDark,
          backgroundColor: cardColor,
          foregroundColor: textColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.staffRoleLabel ?? 'Instructor'} Info & Booking',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore availability, choose a date, and reserve support in one place.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.72)
                      : const Color(0xFF667085),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required bool isDark,
    required CourseDetailState state,
    required String displayName,
    required String roleLabel,
  }) {
    final profile = state.selectedProfile;
    final cardShadow = Colors.black.withValues(alpha: isDark ? 0.24 : 0.08);
    final upcomingCount = state.appointments
        .where((appointment) => appointment.status.toLowerCase() != 'cancelled')
        .length;
    final heroStats = <Widget>[
      Expanded(
        child: _HeroInfoTile(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: profile?.email ?? 'Not available',
        ),
      ),
      if (profile?.officeLocation?.trim().isNotEmpty == true) ...[
        const SizedBox(width: 10),
        Expanded(
          child: _HeroInfoTile(
            icon: Icons.location_on_outlined,
            label: 'Office',
            value: profile!.officeLocation!.trim(),
          ),
        ),
      ],
      const SizedBox(width: 10),
      Expanded(
        child: _HeroInfoTile(
          icon: Icons.event_available_rounded,
          label: 'Appointments',
          value: '$upcomingCount active',
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _accentGradient,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: cardShadow,
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -24,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeroPill(
                          icon: _isAssistant
                              ? Icons.groups_rounded
                              : Icons.school_rounded,
                          label: roleLabel,
                        ),
                        _HeroPill(
                          icon: Icons.schedule_rounded,
                          label: state.isLoadingOfficeHours
                              ? 'Loading slots'
                              : '${state.officeHourSlots.length} active slots',
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoadingProfile)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileAvatar(
                    imageUrl: profile?.profilePictureUrl,
                    initials: profile?.initials ?? _buildInitials(displayName),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          profile?.bio?.trim().isNotEmpty == true
                              ? profile!.bio!.trim()
                              : 'Reserve focused help for lectures, labs, assignments, and follow-up questions.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: heroStats,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeHoursSection(bool isDark, CourseDetailState state) {
    final availableCount = state.officeHourSlots
        .where((slot) => !_isSlotFull(slot))
        .length;
    final nextAvailableSlot = state.officeHourSlots
        .cast<OfficeHourSlotModel?>()
        .firstWhere(
          (slot) => slot != null && !_isSlotFull(slot),
          orElse: () => null,
        );

    return _SectionShell(
      isDark: isDark,
      accentColor: _accentColor,
      icon: Icons.event_available_rounded,
      title: 'Office Hour Slots',
      subtitle:
          'Choose an available slot, then pick the date that works best for you.',
      badgeLabel: state.isLoadingOfficeHours
          ? 'Syncing'
          : '$availableCount available',
      child: Column(
        children: [
          if (state.isLoadingOfficeHours)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: LinearProgressIndicator(),
            ),
          if (!state.isLoadingOfficeHours &&
              state.officeHourSlots.isNotEmpty) ...[
            _SectionInsightsRow(
              isDark: isDark,
              cards: [
                _InsightCardData(
                  icon: Icons.bolt_rounded,
                  label: 'Next open',
                  value: nextAvailableSlot == null
                      ? 'Waitlist'
                      : '${nextAvailableSlot.dayOfWeek.substring(0, 3).toUpperCase()} ${nextAvailableSlot.startTime}',
                  tint: _accentColor,
                ),
                _InsightCardData(
                  icon: Icons.layers_outlined,
                  label: 'Published',
                  value: '${state.officeHourSlots.length} slots',
                  tint: _accentColorDeep,
                ),
                _InsightCardData(
                  icon: Icons.people_alt_outlined,
                  label: 'Availability',
                  value: '$availableCount open',
                  tint: const Color(0xFF12B76A),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (state.officeHourSlots.isEmpty)
            _ModernEmptyCard(
              isDark: isDark,
              accentColor: _accentColor,
              icon: Icons.event_busy_outlined,
              title: 'No active slots right now',
              message:
                  'This staff member has not published any bookable office-hour sessions yet.',
            )
          else
            ...state.officeHourSlots.map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModernSlotCard(
                  isDark: isDark,
                  accentGradient: _accentGradient,
                  slot: slot,
                  isBooking: state.isBookingAppointment,
                  onBook: () => _openBookingDialog(context, slot),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection(bool isDark, CourseDetailState state) {
    final pendingCount = state.appointments
        .where(
          (appointment) => appointment.status.trim().toLowerCase() == 'pending',
        )
        .length;
    final confirmedCount = state.appointments.where((appointment) {
      final status = appointment.status.trim().toLowerCase();
      return status == 'booked' || status == 'confirmed';
    }).length;

    return _SectionShell(
      isDark: isDark,
      accentColor: _accentColor,
      icon: Icons.forum_rounded,
      title: 'My Appointments',
      subtitle:
          'Track your latest requests, statuses, and upcoming support sessions.',
      badgeLabel: '${state.appointments.length} total',
      child: Column(
        children: [
          if (state.isLoadingAppointments && state.appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: LinearProgressIndicator(),
            ),
          if (!state.isLoadingAppointments &&
              state.appointments.isNotEmpty) ...[
            _SectionInsightsRow(
              isDark: isDark,
              cards: [
                _InsightCardData(
                  icon: Icons.event_available_outlined,
                  label: 'Confirmed',
                  value: '$confirmedCount sessions',
                  tint: const Color(0xFF12B76A),
                ),
                _InsightCardData(
                  icon: Icons.timelapse_rounded,
                  label: 'Pending',
                  value: '$pendingCount requests',
                  tint: const Color(0xFFF79009),
                ),
                _InsightCardData(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Booking flow',
                  value: 'Fast track',
                  tint: _accentColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (state.appointments.isEmpty)
            _ModernEmptyCard(
              isDark: isDark,
              accentColor: _accentColor,
              icon: Icons.calendar_month_outlined,
              title: 'No appointments booked yet',
              message:
                  'Once you reserve a slot, your booking updates will appear here.',
            )
          else
            ...state.appointments.map(
              (appointment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModernAppointmentCard(
                  appointment: appointment,
                  isDark: isDark,
                  accentColor: _accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeachingTeamSection(bool isDark, CourseDetailState state) {
    final members = <_TeamMember>[
      ...state.instructors.map(
        (item) => _TeamMember(
          name: item.fullName.trim().isNotEmpty ? item.fullName : item.email,
          role: item.role.toLowerCase() == 'primary'
              ? 'Primary instructor'
              : 'Instructor',
          icon: Icons.school_outlined,
        ),
      ),
      ...state.teachingAssistants.map(
        (item) => _TeamMember(
          name: item.fullName.trim().isNotEmpty ? item.fullName : item.email,
          role: 'Teaching assistant',
          icon: Icons.groups_rounded,
        ),
      ),
    ];

    return _SectionShell(
      isDark: isDark,
      accentColor: _accentColor,
      icon: Icons.groups_rounded,
      title: 'Teaching Team',
      subtitle:
          'See who is assigned to this section so you know where to reach out next.',
      badgeLabel: '${members.length} members',
      child: members.isEmpty
          ? _ModernEmptyCard(
              isDark: isDark,
              accentColor: _accentColor,
              icon: Icons.people_outline_rounded,
              title: 'Teaching team is still loading',
              message:
                  'Staff data has not arrived yet. Try reopening this page in a moment.',
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                final member = members[index];
                return _TeachingTeamChip(
                  isDark: isDark,
                  accentColor: _accentColor,
                  member: member,
                );
              },
            ),
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
        appointmentDate: _formatApiDate(request.date),
        topic: request.topic,
        notes: request.notes,
      ),
    );
  }

  Future<DateTime?> _pickBookingDate(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime draftDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colorScheme = ColorScheme.light(
              primary: _accentColor,
              secondary: _accentColorDeep,
              surface: Colors.white,
              onSurface: const Color(0xFF101828),
            );

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
                            gradient: LinearGradient(colors: _accentGradient),
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
                              const SizedBox(height: 8),
                              Text(
                                'Choose when you want to attend the office-hour session.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.86),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Theme(
                          data: Theme.of(sheetContext).copyWith(
                            colorScheme: colorScheme,
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: _accentColor,
                              ),
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
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 46,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final candidate = DateTime.now().add(
                                Duration(days: index + 1),
                              );
                              final isSelected =
                                  _formatApiDate(candidate) ==
                                  _formatApiDate(draftDate);

                              return ChoiceChip(
                                selected: isSelected,
                                onSelected: (_) {
                                  setSheetState(() => draftDate = candidate);
                                },
                                label: Text(
                                  DateFormat('EEE d').format(candidate),
                                ),
                                avatar: Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : _accentColor,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF101828)),
                                  fontWeight: FontWeight.w700,
                                ),
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(0xFFF5F7FB),
                                selectedColor: _accentColor,
                                side: BorderSide(
                                  color: isSelected
                                      ? _accentColor
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : const Color(0xFFD8E1EF)),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
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
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? Colors.white
                                      : const Color(0xFF344054),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : const Color(0xFFD8E1EF),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(draftDate),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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

  Future<_BookingRequest?> _openBookingComposer(
    BuildContext context, {
    required OfficeHourSlotModel slot,
    required DateTime initialDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topicController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = initialDate;

    final result = await showModalBottomSheet<_BookingRequest>(
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
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF101828),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share the topic you want to cover, and we’ll send the booking request with your selected date.',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF667085),
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                _accentColor.withValues(alpha: 0.16),
                                _accentColorDeep.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _accentColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.schedule_rounded,
                                      color: _accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
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
                                        color: _accentColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Selected date',
                                              style: TextStyle(
                                                color: Color(0xFF667085),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _formatLongDate(selectedDate),
                                              style: const TextStyle(
                                                color: Color(0xFF101828),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit_calendar_rounded,
                                        color: _accentColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Quick focus',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF344054),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                    'Exam prep',
                                    'Assignment review',
                                    'Project guidance',
                                    'Office-hour follow-up',
                                  ]
                                  .map((suggestion) {
                                    return ActionChip(
                                      onPressed: () {
                                        topicController.text = suggestion;
                                        topicController.selection =
                                            TextSelection.collapsed(
                                              offset:
                                                  topicController.text.length,
                                            );
                                        setSheetState(() {});
                                      },
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : const Color(0xFFF5F7FB),
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.10,
                                              )
                                            : const Color(0xFFDCE4F2),
                                      ),
                                      label: Text(
                                        suggestion,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF344054),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      avatar: Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 16,
                                        color: _accentColor,
                                      ),
                                    );
                                  })
                                  .toList(growable: false),
                        ),
                        const SizedBox(height: 16),
                        _BookingTextField(
                          controller: topicController,
                          isDark: isDark,
                          accentColor: _accentColor,
                          labelText: 'Topic (optional)',
                          hintText: 'What do you want to discuss?',
                        ),
                        const SizedBox(height: 12),
                        _BookingTextField(
                          controller: notesController,
                          isDark: isDark,
                          accentColor: _accentColor,
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
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? Colors.white
                                      : const Color(0xFF344054),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : const Color(0xFFD8E1EF),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop(
                                    _BookingRequest(
                                      date: selectedDate,
                                      topic: topicController.text.trim(),
                                      notes: notesController.text.trim(),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'IN';
    }
    return parts.map((part) => part.substring(0, 1)).join().toUpperCase();
  }

  bool _isSlotFull(OfficeHourSlotModel slot) {
    return slot.maxAppointments > 0 &&
        slot.currentAppointments >= slot.maxAppointments;
  }

  String _formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
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
            .split(RegExp(r'[_\s-]+'))
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }

  Widget _buildHighlightsStrip({
    required bool isDark,
    required CourseDetailState state,
    required String roleLabel,
  }) {
    final availableCount = state.officeHourSlots
        .where((slot) => !_isSlotFull(slot))
        .length;
    final teamCount =
        state.instructors.length + state.teachingAssistants.length;
    final appointmentsCount = state.appointments
        .where((appointment) => appointment.status.toLowerCase() != 'cancelled')
        .length;

    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _HighlightMetricCard(
            title: 'Open office hours',
            value: state.isLoadingOfficeHours ? '...' : '$availableCount',
            subtitle: 'ready to book',
            icon: Icons.event_available_rounded,
            accentGradient: _accentGradient,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _HighlightMetricCard(
            title: 'Active bookings',
            value: state.isLoadingAppointments ? '...' : '$appointmentsCount',
            subtitle: 'student sessions',
            icon: Icons.calendar_month_rounded,
            accentGradient: <Color>[_accentColorDeep, const Color(0xFF3CC0FF)],
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          _HighlightMetricCard(
            title: 'Support team',
            value: teamCount == 0 ? roleLabel : '$teamCount',
            subtitle: teamCount == 0 ? 'lead contact' : 'section members',
            icon: Icons.groups_rounded,
            accentGradient: <Color>[const Color(0xFF8B5CF6), _accentColor],
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color backgroundColor;
  final Color foregroundColor;

  const _TopActionButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFDCE4F2),
            ),
          ),
          child: Icon(icon, color: foregroundColor, size: 18),
        ),
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _BackdropGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
}

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;

  const _ProfileAvatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}

class _HeroInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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

class _SectionShell extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final Widget child;

  const _SectionShell({
    required this.isDark,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFDCE4F2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF667085),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionInsightsRow extends StatelessWidget {
  final bool isDark;
  final List<_InsightCardData> cards;

  const _SectionInsightsRow({required this.isDark, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 540) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SectionInsightCard(isDark: isDark, data: card),
                  ),
                )
                .toList(growable: false),
          );
        }

        return Row(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              Expanded(
                child: _SectionInsightCard(isDark: isDark, data: cards[index]),
              ),
              if (index != cards.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _InsightCardData {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  const _InsightCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });
}

class _SectionInsightCard extends StatelessWidget {
  final bool isDark;
  final _InsightCardData data;

  const _SectionInsightCard({required this.isDark, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE4ECF7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF667085),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

class _HighlightMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> accentGradient;
  final bool isDark;

  const _HighlightMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentGradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: accentGradient
              .map((color) => color.withValues(alpha: isDark ? 0.36 : 1.0))
              .toList(growable: false),
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accentGradient.first.withValues(alpha: isDark ? 0.16 : 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
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

class _ModernEmptyCard extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String message;

  const _ModernEmptyCard({
    required this.isDark,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF667085),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSlotCard extends StatelessWidget {
  final bool isDark;
  final bool isBooking;
  final OfficeHourSlotModel slot;
  final VoidCallback onBook;
  final List<Color> accentGradient;

  const _ModernSlotCard({
    required this.isDark,
    required this.isBooking,
    required this.slot,
    required this.onBook,
    required this.accentGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isFull =
        slot.maxAppointments > 0 &&
        slot.currentAppointments >= slot.maxAppointments;
    final spotsLeft = slot.maxAppointments > 0
        ? (slot.maxAppointments - slot.currentAppointments).clamp(0, 999)
        : null;
    final progress = slot.maxAppointments > 0
        ? (slot.currentAppointments / slot.maxAppointments).clamp(0.0, 1.0)
        : 0.0;
    final accent = accentGradient.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: accentGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.dayOfWeek.toUpperCase()} • ${slot.startTime} - ${slot.endTime}',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101828),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          isDark: isDark,
                          icon: Icons.location_on_outlined,
                          label: slot.location,
                        ),
                        _MetaChip(
                          isDark: isDark,
                          icon: Icons.wifi_tethering_rounded,
                          label: _formatMode(slot.mode),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isFull
                      ? const Color(0xFFFEF3F2)
                      : accent.withValues(alpha: isDark ? 0.22 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isFull ? 'Full' : '${spotsLeft ?? '--'} left',
                  style: TextStyle(
                    color: isFull ? const Color(0xFFB42318) : accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (slot.notes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              slot.notes!.trim(),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475467),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.currentAppointments}/${slot.maxAppointments} booked',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFF344054),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: (isFull || isBooking) ? null : onBook,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(isFull ? 'Full' : 'Book'),
              ),
            ],
          ),
        ],
      ),
    );
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
            .split(RegExp(r'[_\s-]+'))
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' ');
    }
  }
}

class _MetaChip extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFF8EC5FF) : const Color(0xFF667085),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernAppointmentCard extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final OfficeHourAppointmentModel appointment;

  const _ModernAppointmentCard({
    required this.isDark,
    required this.accentColor,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final status = appointment.status.trim().toLowerCase();
    final statusColor = switch (status) {
      'booked' || 'confirmed' => const Color(0xFF12B76A),
      'pending' => const Color(0xFFF79009),
      'cancelled' => const Color(0xFFF04438),
      _ => accentColor,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFDFEFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_note_rounded, color: accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.topic,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF101828),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        appointment.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      isDark: isDark,
                      icon: Icons.calendar_today_outlined,
                      label: _formatShortDate(appointment.appointmentDate),
                    ),
                    _MetaChip(
                      isDark: isDark,
                      icon: Icons.person_outline_rounded,
                      label: appointment.studentName,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(DateTime? date) {
    if (date == null) {
      return 'TBD';
    }
    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }
}

class _TeachingTeamChip extends StatelessWidget {
  final bool isDark;
  final Color accentColor;
  final _TeamMember member;

  const _TeachingTeamChip({
    required this.isDark,
    required this.accentColor,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(member.icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF101828),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF667085),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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

class _BookingTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color accentColor;
  final String labelText;
  final String hintText;
  final int minLines;
  final int maxLines;

  const _BookingTextField({
    required this.controller,
    required this.isDark,
    required this.accentColor,
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
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF101828),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF667085),
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.42)
              : const Color(0xFF98A2B3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFD8E1EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accentColor, width: 1.4),
        ),
      ),
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final IconData icon;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.icon,
  });
}

class _BookingRequest {
  final DateTime date;
  final String topic;
  final String notes;

  const _BookingRequest({
    required this.date,
    required this.topic,
    required this.notes,
  });
}
