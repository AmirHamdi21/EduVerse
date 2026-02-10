import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

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

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  String _selectedView = 'month'; // month, week, day
  Set<String> _activeFilters = {'lab', 'grading', 'office_hours', 'meetings'};

  // Mock events data
  final List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'title': 'Lab Session - CS201',
      'date': DateTime.now(),
      'startTime': '10:00 AM',
      'endTime': '12:00 PM',
      'type': 'lab',
      'location': 'Lab Room 302',
      'description': 'Introduction to Data Structures lab',
    },
    {
      'id': '2',
      'title': 'Grade Submissions Due',
      'date': DateTime.now().add(const Duration(days: 1)),
      'startTime': '11:59 PM',
      'endTime': '',
      'type': 'grading',
      'description': 'Assignment 3 grading deadline',
    },
    {
      'id': '3',
      'title': 'Office Hours',
      'date': DateTime.now().add(const Duration(days: 2)),
      'startTime': '2:00 PM',
      'endTime': '4:00 PM',
      'type': 'office_hours',
      'location': 'Room 205',
    },
    {
      'id': '4',
      'title': 'TA Meeting with Prof. Johnson',
      'date': DateTime.now().add(const Duration(days: 3)),
      'startTime': '3:00 PM',
      'endTime': '4:00 PM',
      'type': 'meetings',
      'location': 'Conference Room A',
    },
    {
      'id': '5',
      'title': 'Lab Session - CS301',
      'date': DateTime.now().add(const Duration(days: 4)),
      'startTime': '2:00 PM',
      'endTime': '4:00 PM',
      'type': 'lab',
      'location': 'Lab Room 301',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/calendar'),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(l10n, isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildViewSelector(isDark, l10n),
                        const SizedBox(height: 16),
                        _buildFilterChips(isDark, l10n),
                        const SizedBox(height: 20),
                        _buildCalendarCard(isDark),
                        const SizedBox(height: 24),
                        _buildEventsForDay(isDark, l10n),
                        const SizedBox(height: 24),
                        _buildUpcomingEvents(isDark, l10n),
                        const SizedBox(height: 32),
                      ],
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return SliverAppBar(
      backgroundColor: TAColors.primary,
      expandedHeight: 120,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.today_rounded, color: Colors.white),
          onPressed: () => _goToToday(),
        ),
        IconButton(
          icon: const Icon(Icons.sync_rounded, color: Colors.white),
          onPressed: () => _syncCalendar(isDark),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.calendar,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TAColors.primary,
                TAColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -20,
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewSelector(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildViewTab('month', l10n.month, isDark),
          _buildViewTab('week', l10n.week, isDark),
          _buildViewTab('day', l10n.day, isDark),
        ],
      ),
    );
  }

  Widget _buildViewTab(String view, String label, bool isDark) {
    final isSelected = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = view),
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
                color: isSelected ? Colors.white : TAColors.textSecondaryColor(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, AppLocalizations l10n) {
    final filters = [
      {'id': 'lab', 'label': l10n.taLabs, 'color': TAColors.info},
      {'id': 'grading', 'label': l10n.pendingGrading, 'color': TAColors.warning},
      {'id': 'office_hours', 'label': l10n.taOfficeHoursTitle, 'color': TAColors.success},
      {'id': 'meetings', 'label': l10n.meetings, 'color': TAColors.primary},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isActive = _activeFilters.contains(filter['id']);
          final color = filter['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isActive,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _activeFilters.add(filter['id'] as String);
                  } else {
                    _activeFilters.remove(filter['id']);
                  }
                });
              },
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

  Widget _buildCalendarCard(bool isDark) {
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
          _buildCalendarHeader(isDark),
          const SizedBox(height: 16),
          _buildCalendarWeekDays(isDark),
          const SizedBox(height: 8),
          _buildCalendarDays(isDark),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDark) {
    final monthYear = DateFormat('MMMM yyyy').format(_focusedMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
            });
          },
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
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
            });
          },
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
      children: weekDays.map((day) => SizedBox(
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
      )).toList(),
    );
  }

  Widget _buildCalendarDays(bool isDark) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];
    
    // Empty slots before first day
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Days of month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final hasEvents = _getEventsForDay(date).isNotEmpty;

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? TAColors.primary
                  : isToday
                      ? TAColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: TAColors.primary, width: 1.5)
                  : null,
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
                  ),
                ),
                if (hasEvents && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: TAColors.primary,
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

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: dayWidgets,
    );
  }

  Widget _buildEventsForDay(bool isDark, AppLocalizations l10n) {
    final dayEvents = _getEventsForDay(_selectedDate);
    final formattedDate = DateFormat('EEEE, MMMM d').format(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${dayEvents.length} ${dayEvents.length == 1 ? 'event' : 'events'}',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (dayEvents.isNotEmpty)
              TextButton.icon(
                onPressed: () => _showDayEventsSheet(isDark, l10n),
                icon: const Icon(Icons.open_in_full_rounded, size: 18),
                label: Text(l10n.viewAll),
                style: TextButton.styleFrom(foregroundColor: TAColors.primary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (dayEvents.isEmpty)
          _buildNoEventsCard(isDark, l10n)
        else
          ...dayEvents.map((event) => _buildEventCard(event, isDark)),
      ],
    );
  }

  Widget _buildNoEventsCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: TAColors.textTertiaryColor(isDark),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.taCalendarNoEvents,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showAddEventSheet(isDark, l10n),
              child: Text(l10n.taCalendarAddEvent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isDark) {
    final type = event['type'] as String;
    final color = _getEventColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDetails(event, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getEventIcon(type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: TAColors.textTertiaryColor(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event['endTime'].isNotEmpty
                                ? '${event['startTime']} - ${event['endTime']}'
                                : event['startTime'],
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (event['location'] != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: TAColors.textTertiaryColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event['location'],
                              style: TextStyle(
                                color: TAColors.textTertiaryColor(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: TAColors.textTertiaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(bool isDark, AppLocalizations l10n) {
    final upcomingEvents = _events
        .where((e) => (e['date'] as DateTime).isAfter(DateTime.now()))
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taCalendarUpcoming,
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...upcomingEvents.map((event) => _buildUpcomingEventTile(event, isDark)),
      ],
    );
  }

  Widget _buildUpcomingEventTile(Map<String, dynamic> event, bool isDark) {
    final date = event['date'] as DateTime;
    final type = event['type'] as String;
    final color = _getEventColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('d').format(date),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  event['startTime'],
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
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
              _getEventTypeLabel(type),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getEventsForDay(DateTime date) {
    return _events.where((event) {
      final eventDate = event['date'] as DateTime;
      final eventType = event['type'] as String;
      return _isSameDay(eventDate, date) && _activeFilters.contains(eventType);
    }).toList();
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
        return TAColors.textSecondaryColor(false);
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'lab':
        return Icons.science_rounded;
      case 'grading':
        return Icons.grading_rounded;
      case 'office_hours':
        return Icons.schedule_rounded;
      case 'meetings':
        return Icons.groups_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _getEventTypeLabel(String type) {
    switch (type) {
      case 'lab':
        return 'Lab';
      case 'grading':
        return 'Grading';
      case 'office_hours':
        return 'Office Hours';
      case 'meetings':
        return 'Meeting';
      default:
        return 'Event';
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedMonth = DateTime.now();
    });
  }

  void _syncCalendar(bool isDark) {
    _showSnackBar('Calendar synced', isDark);
  }

  void _showAddEventSheet(bool isDark, AppLocalizations l10n) {
    String title = '';
    String selectedType = 'lab';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    String location = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: TAColors.scaffoldColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
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
                  l10n.taCalendarAddEvent,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => title = value,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TAColors.primary),
                    ),
                  ),
                  style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Event Type',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTypeChip('lab', 'Lab', selectedType, isDark, (type) {
                      setSheetState(() => selectedType = type);
                    }),
                    _buildTypeChip('grading', 'Grading', selectedType, isDark, (type) {
                      setSheetState(() => selectedType = type);
                    }),
                    _buildTypeChip('office_hours', 'Office Hours', selectedType, isDark, (type) {
                      setSheetState(() => selectedType = type);
                    }),
                    _buildTypeChip('meetings', 'Meeting', selectedType, isDark, (type) {
                      setSheetState(() => selectedType = type);
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => location = value,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: TAColors.textSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: TAColors.primary),
                    ),
                  ),
                  style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (title.isNotEmpty) {
                        Navigator.pop(context);
                        setState(() {
                          _events.add({
                            'id': DateTime.now().toString(),
                            'title': title,
                            'date': _selectedDate,
                            'startTime': startTime.format(context),
                            'endTime': endTime.format(context),
                            'type': selectedType,
                            'location': location,
                          });
                        });
                        _showSnackBar('Event added', isDark);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TAColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.taCalendarAddEvent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String type,
    String label,
    String selectedType,
    bool isDark,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = type == selectedType;
    final color = _getEventColor(type);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(type),
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : TAColors.textPrimaryColor(isDark),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event, bool isDark) {
    final type = event['type'] as String;
    final color = _getEventColor(type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.scaffoldColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getEventIcon(type), color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    event['title'],
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.access_time_rounded, 
              '${event['startTime']}${event['endTime'].isNotEmpty ? ' - ${event['endTime']}' : ''}', 
              isDark),
            if (event['location'] != null)
              _buildDetailRow(Icons.location_on_outlined, event['location'], isDark),
            if (event['description'] != null)
              _buildDetailRow(Icons.description_outlined, event['description'], isDark),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackBar('Edit feature coming soon', isDark);
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TAColors.primary,
                      side: const BorderSide(color: TAColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _events.remove(event);
                      });
                      _showSnackBar('Event deleted', isDark);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TAColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: TAColors.textSecondaryColor(isDark)),
          const SizedBox(width: 12),
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

  void _showDayEventsSheet(bool isDark, AppLocalizations l10n) {
    _showSnackBar('Day events view coming soon', isDark);
  }

  void _showSnackBar(String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TAColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
