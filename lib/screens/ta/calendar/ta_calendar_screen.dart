import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:edu_verse/bloc/ta/ta_calendar_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_calendar_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_state.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_drawer.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';

class TACalendarScreen extends StatefulWidget {
  const TACalendarScreen({super.key});

  @override
  State<TACalendarScreen> createState() => _TACalendarScreenState();
}

class _TACalendarScreenState extends State<TACalendarScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) {
        final coreApiClient = CoreApiClient(storageService: StorageService());
        final scheduleApiService = ScheduleApiService(
          coreApiClient: coreApiClient,
        );
        final officeHoursService = OfficeHoursService(
          coreApiClient: coreApiClient,
        );

        return TACalendarCubit(
          scheduleService: scheduleApiService,
          officeHoursService: officeHoursService,
        );
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState.isDark;

          return BlocConsumer<TACalendarCubit, TACalendarState>(
            listener: (context, state) {
              if (state.successMessage != null) {
                _showSnackBar(state.successMessage!, isDark);
              }
              if (state.error != null) {
                _showSnackBar(state.error!, isDark);
              }
            },
            builder: (context, calendarState) {
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: TAColors.scaffoldColor(isDark),
                drawer: const TADrawer(currentRoute: '/ta/calendar'),
                body: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    children: [
                      CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildAppBar(l10n, isDark),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildViewSelector(
                                    isDark,
                                    l10n,
                                    calendarState,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFilterChips(
                                    isDark,
                                    l10n,
                                    calendarState,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildCalendarCard(isDark, calendarState),
                                  const SizedBox(height: 24),
                                  _buildEventsForDay(
                                    isDark,
                                    l10n,
                                    calendarState,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildUpcomingEvents(
                                    isDark,
                                    l10n,
                                    calendarState,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (calendarState.isLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.08),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => _showAddEventSheet(isDark, l10n),
                  backgroundColor: TAColors.primary,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    l10n.taCalendarAddEvent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return SliverAppBar(
      expandedHeight: 110,
      floating: true,
      pinned: false,
      snap: true,
      backgroundColor: TAColors.scaffoldColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        l10n.taCalendarTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.today_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
          onPressed: _goToToday,
          tooltip: l10n.today,
        ),
        IconButton(
          icon: Icon(
            Icons.sync_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
          onPressed: () => _syncCalendar(isDark),
          tooltip: l10n.sync,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildViewSelector(
    bool isDark,
    AppLocalizations l10n,
    TACalendarState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          _buildViewTab('month', l10n.month, isDark, state),
          _buildViewTab('week', l10n.week, isDark, state),
          _buildViewTab('day', l10n.day, isDark, state),
        ],
      ),
    );
  }

  Widget _buildViewTab(
    String view,
    String label,
    bool isDark,
    TACalendarState state,
  ) {
    final isSelected = _viewTypeToString(state.viewType) == view;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<TACalendarCubit>().setView(view),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : TAColors.textSecondaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    bool isDark,
    AppLocalizations l10n,
    TACalendarState state,
  ) {
    final filters = [
      {'id': 'lab', 'label': l10n.taLabs, 'color': TAColors.info},
      {
        'id': 'grading',
        'label': l10n.pendingGrading,
        'color': TAColors.warning,
      },
      {
        'id': 'office_hours',
        'label': l10n.taOfficeHoursTitle,
        'color': TAColors.success,
      },
      {'id': 'meetings', 'label': l10n.meetings, 'color': TAColors.primary},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isActive = state.activeFilters.contains(filter['id']);
          final color = filter['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isActive,
              onSelected: (_) => context.read<TACalendarCubit>().toggleFilter(
                filter['id'] as String,
              ),
              selectedColor: color.withValues(alpha: 0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isActive ? color : TAColors.textSecondaryColor(isDark),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: TAColors.cardColor(isDark),
              side: BorderSide(
                color: isActive ? color : TAColors.borderColor(isDark),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDark, TACalendarState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(isDark, state),
          const SizedBox(height: 16),
          _buildCalendarWeekDays(isDark),
          const SizedBox(height: 8),
          _buildCalendarDays(isDark, state),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDark, TACalendarState state) {
    final monthYear = DateFormat('MMMM yyyy').format(state.focusedMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.read<TACalendarCubit>().previousMonth(),
          icon: Icon(
            Icons.chevron_left_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
        Text(
          monthYear,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => context.read<TACalendarCubit>().nextMonth(),
          icon: Icon(
            Icons.chevron_right_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarWeekDays(bool isDark) {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarDays(bool isDark, TACalendarState state) {
    final firstDayOfMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      state.focusedMonth.year,
      state.focusedMonth.month + 1,
      0,
    );

    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final dayWidgets = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month,
        day,
      );
      final isSelected = _isSameDay(date, state.selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasEvents = _getEventsForDay(date, state).isNotEmpty;

      dayWidgets.add(
        GestureDetector(
          onTap: () => context.read<TACalendarCubit>().selectDate(date),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? TAColors.primary
                  : isToday
                  ? TAColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? TAColors.primary
                        : TAColors.textPrimaryColor(isDark),
                    fontWeight: isSelected || isToday
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : TAColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(alignment: WrapAlignment.start, children: dayWidgets);
  }

  Widget _buildEventsForDay(
    bool isDark,
    AppLocalizations l10n,
    TACalendarState state,
  ) {
    final dayEvents = _getEventsForDay(state.selectedDate, state);
    final formattedDate = DateFormat('EEEE, MMMM d').format(state.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.taCalendarEventsFor} $formattedDate',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dayEvents.length > 3)
              TextButton(
                onPressed: () => _showDayEventsSheet(dayEvents, isDark, l10n),
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: TAColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (dayEvents.isEmpty)
          _buildNoEventsCard(isDark, l10n)
        else
          ...dayEvents
              .take(3)
              .map((event) => _buildEventCard(event, isDark, l10n)),
      ],
    );
  }

  Widget _buildNoEventsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 48,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.taCalendarNoEvents,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.taCalendarNoEventsDesc,
            style: TextStyle(
              color: TAColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    Map<String, dynamic> event,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final eventType = event['type'] as String? ?? 'meetings';
    final color = _getEventColor(eventType);

    return GestureDetector(
      onTap: () => _showEventDetails(event, isDark, l10n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getEventIcon(eventType), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] as String? ?? '',
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event['startTime']}${(event['endTime'] as String).isNotEmpty ? ' - ${event['endTime']}' : ''}',
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 13,
                    ),
                  ),
                  if ((event['location'] as String?) != null &&
                      (event['location'] as String).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event['location'] as String,
                        style: TextStyle(
                          color: TAColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getEventTypeLabel(eventType, l10n),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(
    bool isDark,
    AppLocalizations l10n,
    TACalendarState state,
  ) {
    final upcomingEvents = state.upcomingItems
        .map(_eventToMap)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taCalendarUpcoming,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (upcomingEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TAColors.borderColor(isDark)),
            ),
            child: Text(
              '${l10n.taCalendarNoUpcoming} ${l10n.taCalendarNoUpcomingDesc}',
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...upcomingEvents.map(
            (event) => _buildUpcomingEventTile(event, isDark, l10n),
          ),
      ],
    );
  }

  Widget _buildUpcomingEventTile(
    Map<String, dynamic> event,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final eventType = event['type'] as String? ?? 'meetings';
    final date = event['date'] as DateTime;
    final color = _getEventColor(eventType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(date),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String? ?? '',
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('EEEE').format(date)} at ${event['startTime']}',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(_getEventIcon(eventType), color: color, size: 20),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(
    DateTime date,
    TACalendarState state,
  ) {
    return state.eventsForDate(date).map(_eventToMap).toList(growable: false);
  }

  Map<String, dynamic> _eventToMap(UnifiedScheduleItem item) {
    final eventDate = _parseItemDate(item.date);
    final formattedStart = _formatDisplayTime(item.startTime);
    final formattedEnd = _formatDisplayTime(item.endTime);
    final location =
        item.classItem?.location ??
        item.eventItem?.location ??
        item.campusItem?.location;

    return <String, dynamic>{
      'id': item.id,
      'title': item.title,
      'date': eventDate,
      'startTime': formattedStart,
      'endTime': formattedEnd,
      'type': _kindToTaType(item.kind),
      'location': location ?? '',
      'description':
          item.eventItem?.description ?? item.campusItem?.description ?? '',
    };
  }

  DateTime _parseItemDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }
    return DateTime.now();
  }

  String _kindToTaType(ScheduleItemKind kind) {
    switch (kind) {
      case ScheduleItemKind.classSession:
        return 'lab';
      case ScheduleItemKind.exam:
        return 'grading';
      case ScheduleItemKind.officeHours:
        return 'office_hours';
      case ScheduleItemKind.event:
      case ScheduleItemKind.campusEvent:
      case ScheduleItemKind.unknown:
        return 'meetings';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'lab':
        return TAColors.info;
      case 'grading':
        return TAColors.warning;
      case 'office_hours':
        return TAColors.success;
      case 'meetings':
        return TAColors.primary;
      default:
        return TAColors.primary;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'lab':
        return Icons.science_rounded;
      case 'grading':
        return Icons.assignment_turned_in_rounded;
      case 'office_hours':
        return Icons.schedule_rounded;
      case 'meetings':
        return Icons.groups_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _getEventTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'lab':
        return l10n.taLabs;
      case 'grading':
        return l10n.pendingGrading;
      case 'office_hours':
        return l10n.taOfficeHoursTitle;
      case 'meetings':
        return l10n.meetings;
      default:
        return l10n.eventDetails;
    }
  }

  String _formatDisplayTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    final normalized = normalizeTime(value);
    if (normalized.isEmpty) {
      return value;
    }

    return formatTime24To12(normalized);
  }

  String _viewTypeToString(TACalendarViewType viewType) {
    switch (viewType) {
      case TACalendarViewType.week:
        return 'week';
      case TACalendarViewType.day:
        return 'day';
      case TACalendarViewType.month:
        return 'month';
    }
  }

  void _goToToday() {
    context.read<TACalendarCubit>().goToToday();
  }

  void _syncCalendar(bool isDark) {
    context.read<TACalendarCubit>().syncCalendar();
  }

  void _showAddEventSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final titleController = TextEditingController();
        final locationController = TextEditingController();
        String selectedType = 'meetings';
        TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
        TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TAColors.borderColor(isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.addEvent,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.title,
                      filled: true,
                      fillColor: TAColors.scaffoldColor(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: l10n.location,
                      filled: true,
                      fillColor: TAColors.scaffoldColor(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeChip(
                          'lab',
                          l10n.taLabs,
                          selectedType,
                          (value) => setModalState(() => selectedType = value),
                          isDark,
                        ),
                        _buildTypeChip(
                          'grading',
                          l10n.pendingGrading,
                          selectedType,
                          (value) => setModalState(() => selectedType = value),
                          isDark,
                        ),
                        _buildTypeChip(
                          'office_hours',
                          l10n.taOfficeHoursTitle,
                          selectedType,
                          (value) => setModalState(() => selectedType = value),
                          isDark,
                        ),
                        _buildTypeChip(
                          'meetings',
                          l10n.meetings,
                          selectedType,
                          (value) => setModalState(() => selectedType = value),
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.startTime,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                            ),
                          ),
                          subtitle: Text(
                            startTime.format(context),
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setModalState(() => startTime = picked);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.endTime,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                            ),
                          ),
                          subtitle: Text(
                            endTime.format(context),
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setModalState(() => endTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: TAColors.borderColor(isDark),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            final location = locationController.text.trim();

                            if (title.isEmpty) {
                              return;
                            }

                            Navigator.pop(context);
                            context.read<TACalendarCubit>().addEvent(
                              title: title,
                              type: selectedType,
                              date: context
                                  .read<TACalendarCubit>()
                                  .state
                                  .selectedDate,
                              startTime: startTime.format(context),
                              endTime: endTime.format(context),
                              location: location.isEmpty ? null : location,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TAColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            l10n.addEvent,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(
    String value,
    String label,
    String selected,
    ValueChanged<String> onSelected,
    bool isDark,
  ) {
    final isSelected = selected == value;
    final color = _getEventColor(value);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: color.withValues(alpha: 0.2),
        backgroundColor: TAColors.scaffoldColor(isDark),
        labelStyle: TextStyle(
          color: isSelected ? color : TAColors.textSecondaryColor(isDark),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? color : TAColors.borderColor(isDark),
        ),
      ),
    );
  }

  void _showEventDetails(
    Map<String, dynamic> event,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final canDelete =
        _kindToTaType(ScheduleItemKind.event) == (event['type'] as String?) ||
        (event['type'] as String?) == 'meetings';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                event['title'] as String? ?? '',
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.access_time_rounded,
                '${event['startTime']}${(event['endTime'] as String).isNotEmpty ? ' - ${event['endTime']}' : ''}',
                isDark,
              ),
              _buildDetailRow(
                Icons.location_on_rounded,
                (event['location'] as String?)?.isNotEmpty == true
                    ? event['location'] as String
                    : l10n.location,
                isDark,
              ),
              _buildDetailRow(
                Icons.category_rounded,
                _getEventTypeLabel(
                  event['type'] as String? ?? 'meetings',
                  l10n,
                ),
                isDark,
              ),
              if ((event['description'] as String?)?.isNotEmpty == true)
                _buildDetailRow(
                  Icons.notes_rounded,
                  event['description'] as String,
                  isDark,
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: TAColors.borderColor(isDark)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.close,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canDelete
                          ? () {
                              Navigator.pop(context);
                              context.read<TACalendarCubit>().deleteEvent(
                                event['id'] as String,
                              );
                            }
                          : null,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canDelete
                            ? TAColors.danger
                            : TAColors.borderColor(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: TAColors.textSecondaryColor(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayEventsSheet(
    List<Map<String, dynamic>> events,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TAColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.eventDetails,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(events[index], isDark, l10n);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, bool isDark) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: TAColors.primary,
      ),
    );
  }
}
