import 'package:edu_verse/bloc/language/language_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_calendar_cubit.dart';
import 'package:edu_verse/bloc/ta/ta_calendar_state.dart';
import 'package:edu_verse/bloc/theme/theme_bloc.dart';
import 'package:edu_verse/bloc/theme/theme_event.dart';
import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/models/schedule/schedule_models.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/office_hours_service.dart';
import 'package:edu_verse/services/api/schedule_api_service.dart';
import 'package:edu_verse/services/storage_service.dart';
import 'package:edu_verse/widgets/shared/loading/calendar_screen_skeleton.dart';
import 'package:edu_verse/widgets/ta/dashboard/ta_drawer.dart';
import 'package:edu_verse/widgets/ta/shared/ta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TACalendarScreen extends StatefulWidget {
  const TACalendarScreen({super.key});

  @override
  State<TACalendarScreen> createState() => _TACalendarScreenState();
}

class InstructorColors {
  InstructorColors._();

  static const Color primary = TAColors.primary;
  static const Color primaryLight = TAColors.primaryLight;
  static const Color success = TAColors.success;
  static const Color error = TAColors.error;
  static const Color accent = TAColors.accent;
  static const Color teal = TAColors.teal;
  static const Color info = TAColors.info;
  static const Color warning = TAColors.warning;

  static const LinearGradient headerGradient = TAColors.headerGradient;
  static const LinearGradient darkHeaderGradient = TAColors.darkHeaderGradient;

  static Color background(bool isDark) => TAColors.background(isDark);
  static Color cardColor(bool isDark) => TAColors.cardColor(isDark);
  static Color surfaceColor(bool isDark) => TAColors.surfaceColor(isDark);
  static Color borderColor(bool isDark) => TAColors.borderColor(isDark);
  static Color textPrimaryColor(bool isDark) =>
      TAColors.textPrimaryColor(isDark);
  static Color textSecondaryColor(bool isDark) =>
      TAColors.textSecondaryColor(isDark);
  static Color textTertiaryColor(bool isDark) =>
      TAColors.textTertiaryColor(isDark);
}

class _TACalendarScreenState extends State<TACalendarScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TACalendarCubit _calendarCubit;

  @override
  void initState() {
    super.initState();

    final coreApiClient = CoreApiClient(storageService: StorageService());
    final scheduleApiService = ScheduleApiService(coreApiClient: coreApiClient);
    final officeHoursService = OfficeHoursService(coreApiClient: coreApiClient);
    _calendarCubit = TACalendarCubit(
      scheduleService: scheduleApiService,
      officeHoursService: officeHoursService,
    );
  }

  @override
  void dispose() {
    _calendarCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return BlocProvider.value(
      value: _calendarCubit,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const TADrawer(currentRoute: '/ta/calendar'),
        backgroundColor: InstructorColors.background(isDark),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEventSheet(isDark, l10n),
          backgroundColor: InstructorColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            l10n.taCalendarAddEvent,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocConsumer<TACalendarCubit, TACalendarState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              _showSnackBar(state.successMessage!, isDark);
            }
            if (state.error != null) {
              _showSnackBar(state.error!, isDark);
            }
          },
          builder: (context, state) {
            final hasCachedData = state.unifiedItems.isNotEmpty;
            final showInitialSkeleton = state.isLoading && !hasCachedData;

            return Stack(
              children: [
                _buildBackgroundDecorations(isDark),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(l10n, isDark),
                      Expanded(
                        child: showInitialSkeleton
                            ? CalendarScreenSkeleton(
                                isDark: isDark,
                                showHeroHeader: false,
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  112,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeroCard(
                                      context,
                                      state,
                                      l10n,
                                      isDark,
                                    ),
                                    const SizedBox(height: 14),
                                    if (state.isLoading && hasCachedData)
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: LinearProgressIndicator(
                                          minHeight: 3,
                                        ),
                                      ),
                                    _buildControlMenus(
                                      context,
                                      state,
                                      l10n,
                                      isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildViewSelector(
                                      context,
                                      state,
                                      l10n,
                                      isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildCurrentViewCard(
                                      context,
                                      state,
                                      l10n,
                                      isDark,
                                    ),
                                    if (state.viewType ==
                                        TACalendarViewType.month) ...[
                                      const SizedBox(height: 16),
                                      _buildSelectedDaySection(
                                        context,
                                        state,
                                        l10n,
                                        isDark,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    _buildUpcomingSection(
                                      context,
                                      state,
                                      l10n,
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _buildUtilityButton(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            isDark: isDark,
            child: Icon(
              Icons.menu_rounded,
              size: 18,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
          ),
          const Spacer(),
          _buildUtilityButton(
            onTap: _calendarCubit.syncCalendar,
            isDark: isDark,
            child: Icon(
              Icons.sync_rounded,
              size: 18,
              color: InstructorColors.textPrimaryColor(isDark),
            ),
          ),
          const SizedBox(width: 10),
          BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return _buildUtilityButton(
                onTap: () {
                  final newLocale = locale.languageCode == 'en' ? 'ar' : 'en';
                  context.read<LanguageCubit>().changeLanguage(newLocale);
                },
                isDark: isDark,
                child: Text(
                  locale.languageCode == 'en' ? 'ع' : 'En',
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildUtilityButton(
            onTap: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
            isDark: isDark,
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: InstructorColors.textPrimaryColor(isDark),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityButton({
    required VoidCallback onTap,
    required bool isDark,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(
              isDark,
            ).withValues(alpha: isDark ? 0.9 : 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          right: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  InstructorColors.primary.withValues(
                    alpha: isDark ? 0.24 : 0.17,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  InstructorColors.accent.withValues(
                    alpha: isDark ? 0.14 : 0.1,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  InstructorColors.teal.withValues(alpha: isDark ? 0.13 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthLabel = DateFormat(
      'MMMM yyyy',
      locale,
    ).format(state.focusedMonth);
    final filteredEvents = _filteredEvents(state);
    final totalEvents = filteredEvents.length;
    final focusEvents = _eventsForDate(state.selectedDate, state).length;
    final officeHours = filteredEvents
        .where((event) => event.type == 'office_hours')
        .length;
    final grading = filteredEvents
        .where((event) => event.type == 'grading')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? InstructorColors.darkHeaderGradient
            : InstructorColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: InstructorColors.primary.withValues(
              alpha: isDark ? 0.25 : 0.2,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.calendar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      l10n.instructorCalendarHeroSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: [
              _buildHeroStat(
                title: l10n.calendarRangeEvents,
                value: '$totalEvents',
                color: Colors.white,
              ),
              _buildHeroStat(
                title: l10n.calendarFocusDay,
                value: '$focusEvents',
                color: const Color(0xFFFDE68A),
              ),
              _buildHeroStat(
                title: l10n.taOfficeHoursTitle,
                value: '$officeHours',
                color: const Color(0xFFBBF7D0),
              ),
              _buildHeroStat(
                title: l10n.pendingGrading,
                value: '$grading',
                color: const Color(0xFFD8B4FE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 10.8,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlMenus(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final teachingCount = _activeSubsetCount(state, const {
      'lab',
      'office_hours',
    });
    final supportCount = _activeSubsetCount(state, const {
      'grading',
      'meetings',
    });

    return Row(
      children: [
        Expanded(
          child: _buildMenuButton(
            icon: Icons.tune_rounded,
            title: l10n.calendarEventTypes,
            subtitle: teachingCount == 2
                ? l10n.all
                : '$teachingCount ${l10n.events}',
            color: InstructorColors.primary,
            isDark: isDark,
            onTapDown: (details) =>
                _showTeachingMenu(context, details.globalPosition, isDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMenuButton(
            icon: Icons.layers_rounded,
            title: l10n.calendarManageFilters,
            subtitle: supportCount == 2
                ? l10n.all
                : '$supportCount ${l10n.events}',
            color: InstructorColors.accent,
            isDark: isDark,
            onTapDown: (details) =>
                _showSupportMenu(context, details.globalPosition, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required GestureTapDownCallback onTapDown,
  }) {
    return GestureDetector(
      onTapDown: onTapDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: InstructorColors.textSecondaryColor(isDark),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: InstructorColors.textSecondaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final views = <(TACalendarViewType, String, IconData)>[
      (TACalendarViewType.month, l10n.month, Icons.grid_view_rounded),
      (TACalendarViewType.week, l10n.week, Icons.calendar_view_week_rounded),
      (TACalendarViewType.day, l10n.day, Icons.view_day_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Row(
        children: views.map((view) {
          final isSelected = state.viewType == view.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<TACalendarCubit>().setViewType(view.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            InstructorColors.primary,
                            InstructorColors.primaryLight,
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      view.$3,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : InstructorColors.textSecondaryColor(isDark),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      view.$2,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : InstructorColors.textSecondaryColor(isDark),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentViewCard(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    switch (state.viewType) {
      case TACalendarViewType.month:
        return _buildMonthViewCard(context, state, l10n, isDark);
      case TACalendarViewType.week:
        return _buildWeekViewCard(context, state, l10n, isDark);
      case TACalendarViewType.day:
        return _buildDayViewCard(context, state, l10n, isDark);
    }
  }

  Widget _buildMonthViewCard(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthTitle = DateFormat(
      'MMMM yyyy',
      locale,
    ).format(state.focusedMonth);
    final days = _buildMonthDays(state.focusedMonth);
    final selectedCount = _eventsForDate(state.selectedDate, state).length;
    final weekdayBase = DateTime(2024, 1, 7);

    return _buildSurfaceCard(
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              _buildNavIconButton(
                icon: Icons.chevron_left_rounded,
                isDark: isDark,
                onTap: _calendarCubit.previousMonth,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthTitle,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$selectedCount ${l10n.events}',
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompactActionChip(
                label: l10n.today,
                icon: Icons.today_rounded,
                isDark: isDark,
                onTap: _calendarCubit.goToToday,
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: _calendarCubit.nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(7, (index) {
              final label = DateFormat.E(
                locale,
              ).format(weekdayBase.add(Duration(days: index)));
              return Expanded(
                child: Center(
                  child: Text(
                    _compactWeekdayLabel(label),
                    style: TextStyle(
                      color: InstructorColors.textTertiaryColor(isDark),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth =
                  date.month == state.focusedMonth.month &&
                  date.year == state.focusedMonth.year;
              final isSelected = _isSameDay(date, state.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final events = _sortEvents(_eventsForDate(date, state));

              return GestureDetector(
                onTap: () => _calendarCubit.selectDate(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              InstructorColors.primary,
                              InstructorColors.primaryLight,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isToday
                        ? InstructorColors.primary.withValues(alpha: 0.08)
                        : InstructorColors.surfaceColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : isToday
                          ? InstructorColors.primary.withValues(alpha: 0.35)
                          : isCurrentMonth
                          ? InstructorColors.borderColor(isDark)
                          : InstructorColors.borderColor(
                              isDark,
                            ).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : !isCurrentMonth
                              ? InstructorColors.textTertiaryColor(isDark)
                              : isToday
                              ? InstructorColors.primary
                              : InstructorColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (events.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : _getEventColor(
                                    events.first.type,
                                  ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${events.length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : _getEventColor(events.first.type),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekViewCard(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekDates = _weekDates(state.selectedDate);
    final rangeLabel =
        '${DateFormat('MMM d', locale).format(weekDates.first)} - ${DateFormat('MMM d', locale).format(weekDates.last)}';

    return _buildSurfaceCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildNavIconButton(
                icon: Icons.chevron_left_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.subtract(
                    const Duration(days: 7),
                  );
                  _calendarCubit.selectDate(newDate);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rangeLabel,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.calendarDayAgenda,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompactActionChip(
                label: l10n.today,
                icon: Icons.history_toggle_off_rounded,
                isDark: isDark,
                onTap: _calendarCubit.goToToday,
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.add(
                    const Duration(days: 7),
                  );
                  _calendarCubit.selectDate(newDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: weekDates.map((date) {
              final isSelected = _isSameDay(date, state.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final events = _sortEvents(_eventsForDate(date, state));
              final label = DateFormat.E(locale).format(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => _calendarCubit.selectDate(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                InstructorColors.primary,
                                InstructorColors.info,
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isToday
                          ? InstructorColors.primary.withValues(alpha: 0.08)
                          : InstructorColors.surfaceColor(isDark),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : isToday
                            ? InstructorColors.primary.withValues(alpha: 0.35)
                            : InstructorColors.borderColor(isDark),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _compactWeekdayLabel(label),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.82)
                                : InstructorColors.textSecondaryColor(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? InstructorColors.primary
                                : InstructorColors.textPrimaryColor(isDark),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${events.length}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.86)
                                : InstructorColors.textTertiaryColor(isDark),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _buildQuickAgendaList(
            events: _sortEvents(_eventsForDate(state.selectedDate, state)),
            l10n: l10n,
            isDark: isDark,
            emptyLabel: l10n.calendarNothingPlanned,
          ),
        ],
      ),
    );
  }

  Widget _buildDayViewCard(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat(
      'EEEE, MMMM d',
      locale,
    ).format(state.selectedDate);
    final dayEvents = _sortEvents(_eventsForDate(state.selectedDate, state));

    return _buildSurfaceCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildNavIconButton(
                icon: Icons.chevron_left_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.subtract(
                    const Duration(days: 1),
                  );
                  _calendarCubit.selectDate(newDate);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: InstructorColors.textPrimaryColor(isDark),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dayEvents.length} ${l10n.events}',
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompactActionChip(
                label: l10n.today,
                icon: Icons.today_rounded,
                isDark: isDark,
                onTap: _calendarCubit.goToToday,
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.add(
                    const Duration(days: 1),
                  );
                  _calendarCubit.selectDate(newDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildQuickAgendaList(
            events: dayEvents,
            l10n: l10n,
            isDark: isDark,
            emptyLabel: l10n.calendarNothingPlanned,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAgendaList({
    required List<_TaCalendarEventData> events,
    required AppLocalizations l10n,
    required bool isDark,
    required String emptyLabel,
  }) {
    if (events.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.event_busy_rounded,
        title: emptyLabel,
        subtitle: l10n.noEventsDescription,
        isDark: isDark,
      );
    }

    return Column(
      children: events
          .take(4)
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildEventTile(
                event: event,
                isDark: isDark,
                l10n: l10n,
                showRelativeDate: false,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSelectedDaySection(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final events = _sortEvents(_eventsForDate(state.selectedDate, state));
    final dateLabel = DateFormat(
      'EEEE, MMM d',
      locale,
    ).format(state.selectedDate);

    return _buildSectionCard(
      isDark: isDark,
      header: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calendarSelectedDay,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: InstructorColors.textSecondaryColor(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (events.length > 3)
            TextButton(
              onPressed: () => _showDayEventsSheet(events, isDark, l10n),
              child: Text(
                l10n.details,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: InstructorColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${events.length} ${l10n.events}',
                style: const TextStyle(
                  color: InstructorColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: events.isEmpty
          ? _buildEmptyCard(
              icon: Icons.event_note_rounded,
              title: l10n.taCalendarNoEvents,
              subtitle: l10n.noEventsDescription,
              isDark: isDark,
            )
          : Column(
              children: events
                  .take(3)
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildEventTile(
                        event: event,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context,
    TACalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final upcomingEvents = _sortEvents(_upcomingEvents(state)).take(5).toList();

    return _buildSectionCard(
      isDark: isDark,
      header: Row(
        children: [
          Expanded(
            child: Text(
              l10n.taCalendarUpcoming,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: InstructorColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${upcomingEvents.length} ${l10n.events}',
              style: const TextStyle(
                color: InstructorColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: upcomingEvents.isEmpty
          ? _buildEmptyCard(
              icon: Icons.upcoming_rounded,
              title: l10n.noUpcomingEvents,
              subtitle: l10n.noEventsDescription,
              isDark: isDark,
            )
          : Column(
              children: upcomingEvents
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _buildEventTile(
                        event: event,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required Widget header,
    required Widget body,
  }) {
    return _buildSurfaceCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, body],
      ),
    );
  }

  Widget _buildSurfaceCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InstructorColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: InstructorColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile({
    required _TaCalendarEventData event,
    required bool isDark,
    required AppLocalizations l10n,
    bool showRelativeDate = true,
  }) {
    final eventColor = _getEventColor(event.type);
    final relativeLabel = _relativeDateLabel(l10n, event.date);
    final timeLabel = _formatEventTime(l10n, event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEventDetails(event, isDark, l10n),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: InstructorColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: eventColor.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: eventColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getEventIcon(event.type), color: eventColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (showRelativeDate)
                          Container(
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: eventColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              relativeLabel,
                              style: TextStyle(
                                color: eventColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMetaPill(
                          icon: Icons.schedule_rounded,
                          label: timeLabel,
                          isDark: isDark,
                        ),
                        if (event.location.isNotEmpty)
                          _buildMetaPill(
                            icon: Icons.location_on_outlined,
                            label: event.location,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: InstructorColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: InstructorColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionChip({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: InstructorColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: InstructorColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: InstructorColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: InstructorColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: InstructorColors.borderColor(isDark)),
          ),
          child: Icon(icon, color: InstructorColors.textPrimaryColor(isDark)),
        ),
      ),
    );
  }

  void _showTeachingMenu(
    BuildContext context,
    Offset globalPosition,
    bool isDark,
  ) {
    final cubit = context.read<TACalendarCubit>();
    final l10n = AppLocalizations.of(context);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<void>(
      context: context,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromLTRB(
        globalPosition.dx - 8,
        globalPosition.dy + 8,
        overlay.size.width - globalPosition.dx,
        overlay.size.height - globalPosition.dy,
      ),
      items: [
        _buildMenuOption(
          label: l10n.taLabs,
          icon: Icons.science_rounded,
          color: InstructorColors.info,
          isActive: cubit.state.activeFilters.contains('lab'),
          onTap: () => cubit.toggleFilter('lab'),
        ),
        _buildMenuOption(
          label: l10n.taOfficeHoursTitle,
          icon: Icons.schedule_rounded,
          color: InstructorColors.success,
          isActive: cubit.state.activeFilters.contains('office_hours'),
          onTap: () => cubit.toggleFilter('office_hours'),
        ),
      ],
    );
  }

  void _showSupportMenu(
    BuildContext context,
    Offset globalPosition,
    bool isDark,
  ) {
    final cubit = context.read<TACalendarCubit>();
    final l10n = AppLocalizations.of(context);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<void>(
      context: context,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromLTRB(
        globalPosition.dx - 8,
        globalPosition.dy + 8,
        overlay.size.width - globalPosition.dx,
        overlay.size.height - globalPosition.dy,
      ),
      items: [
        _buildMenuOption(
          label: l10n.pendingGrading,
          icon: Icons.assignment_turned_in_rounded,
          color: InstructorColors.warning,
          isActive: cubit.state.activeFilters.contains('grading'),
          onTap: () => cubit.toggleFilter('grading'),
        ),
        _buildMenuOption(
          label: l10n.meetings,
          icon: Icons.groups_rounded,
          color: InstructorColors.primary,
          isActive: cubit.state.activeFilters.contains('meetings'),
          onTap: () => cubit.toggleFilter('meetings'),
        ),
      ],
    );
  }

  PopupMenuItem<void> _buildMenuOption({
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem<void>(
      height: 46,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: isActive ? color : Colors.grey,
          ),
        ],
      ),
    );
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
                color: InstructorColors.cardColor(isDark),
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
                        color: InstructorColors.borderColor(isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.addEvent,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
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
                      fillColor: InstructorColors.surfaceColor(isDark),
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
                      fillColor: InstructorColors.surfaceColor(isDark),
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
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            startTime.format(context),
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
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
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            endTime.format(context),
                            style: TextStyle(
                              color: InstructorColors.textPrimaryColor(isDark),
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
                              color: InstructorColors.borderColor(isDark),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: InstructorColors.textSecondaryColor(
                                isDark,
                              ),
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
                            _calendarCubit.addEvent(
                              title: title,
                              type: selectedType,
                              date: _calendarCubit.state.selectedDate,
                              startTime: startTime.format(context),
                              endTime: endTime.format(context),
                              location: location.isEmpty ? null : location,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InstructorColors.primary,
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
        backgroundColor: InstructorColors.surfaceColor(isDark),
        labelStyle: TextStyle(
          color: isSelected
              ? color
              : InstructorColors.textSecondaryColor(isDark),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? color : InstructorColors.borderColor(isDark),
        ),
      ),
    );
  }

  void _showEventDetails(
    _TaCalendarEventData event,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final canDelete =
        event.kind == ScheduleItemKind.event || event.id.startsWith('event-');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: InstructorColors.cardColor(isDark),
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
                    color: InstructorColors.borderColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                event.title,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.access_time_rounded,
                _formatEventTime(l10n, event),
                isDark,
              ),
              _buildDetailRow(
                Icons.location_on_rounded,
                event.location.isNotEmpty ? event.location : l10n.location,
                isDark,
              ),
              _buildDetailRow(
                Icons.category_rounded,
                _getEventTypeLabel(event.type, l10n),
                isDark,
              ),
              if (event.description.isNotEmpty)
                _buildDetailRow(Icons.notes_rounded, event.description, isDark),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: InstructorColors.borderColor(isDark),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        l10n.close,
                        style: TextStyle(
                          color: InstructorColors.textSecondaryColor(isDark),
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
                              _calendarCubit.deleteEvent(event.id);
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
                            ? InstructorColors.error
                            : InstructorColors.borderColor(isDark),
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
          Icon(
            icon,
            size: 18,
            color: InstructorColors.textSecondaryColor(isDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: InstructorColors.textPrimaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayEventsSheet(
    List<_TaCalendarEventData> events,
    bool isDark,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaDateEventsSheet(
        events: events,
        isDark: isDark,
        l10n: l10n,
        onEventTap: (event) {
          Navigator.pop(context);
          _showEventDetails(event, isDark, l10n);
        },
      ),
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
        backgroundColor: isDark
            ? InstructorColors.primaryLight
            : InstructorColors.primary,
      ),
    );
  }

  List<_TaCalendarEventData> _filteredEvents(TACalendarState state) {
    return state.filteredItems.map(_eventFromItem).toList(growable: false);
  }

  List<_TaCalendarEventData> _eventsForDate(
    DateTime date,
    TACalendarState state,
  ) {
    return state
        .eventsForDate(date)
        .map(_eventFromItem)
        .toList(growable: false);
  }

  List<_TaCalendarEventData> _upcomingEvents(TACalendarState state) {
    return state.upcomingItems.map(_eventFromItem).toList(growable: false);
  }

  _TaCalendarEventData _eventFromItem(UnifiedScheduleItem item) {
    final eventDate = _parseItemDate(item.date);
    final formattedStart = _formatDisplayTime(item.startTime);
    final formattedEnd = _formatDisplayTime(item.endTime);
    final location =
        item.location ??
        item.eventItem?.location ??
        item.campusEventItem?.location;

    return _TaCalendarEventData(
      id: item.id,
      kind: item.kind,
      title: item.title,
      date: eventDate,
      startTime: formattedStart,
      endTime: formattedEnd,
      type: _kindToTaType(item.kind),
      location: location ?? '',
      description:
          item.eventItem?.description ??
          item.campusEventItem?.description ??
          '',
    );
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

  int _activeSubsetCount(TACalendarState state, Set<String> ids) {
    return state.activeFilters.where(ids.contains).length;
  }

  List<DateTime> _buildMonthDays(DateTime focusedMonth) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final firstVisibleDay = firstDayOfMonth.subtract(
      Duration(days: firstWeekday),
    );
    return List.generate(
      42,
      (index) => DateTime(
        firstVisibleDay.year,
        firstVisibleDay.month,
        firstVisibleDay.day + index,
      ),
    );
  }

  List<DateTime> _weekDates(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  List<_TaCalendarEventData> _sortEvents(List<_TaCalendarEventData> events) {
    final sorted = List<_TaCalendarEventData>.from(events);
    sorted.sort((a, b) {
      final byDate = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
      ).compareTo(DateTime(b.date.year, b.date.month, b.date.day));
      if (byDate != 0) {
        return byDate;
      }
      return _timeValue(a.startTime).compareTo(_timeValue(b.startTime));
    });
    return sorted;
  }

  int _timeValue(String value) {
    if (value.trim().isEmpty) {
      return 24 * 60;
    }

    final raw = value.trim();
    final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (hhmm != null) {
      final hour = int.tryParse(hhmm.group(1) ?? '') ?? 0;
      final minute = int.tryParse(hhmm.group(2) ?? '') ?? 0;
      return (hour * 60) + minute;
    }

    final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(raw);
    if (amPm != null) {
      var hour = int.tryParse(amPm.group(1) ?? '') ?? 0;
      final minute = int.tryParse(amPm.group(2) ?? '') ?? 0;
      final meridiem = (amPm.group(3) ?? '').toUpperCase();
      hour %= 12;
      if (meridiem == 'PM') {
        hour += 12;
      }
      return (hour * 60) + minute;
    }

    return 24 * 60;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'lab':
        return InstructorColors.info;
      case 'grading':
        return InstructorColors.warning;
      case 'office_hours':
        return InstructorColors.success;
      case 'meetings':
        return InstructorColors.primary;
      default:
        return InstructorColors.primary;
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
        return l10n.details;
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

  String _formatEventTime(AppLocalizations l10n, _TaCalendarEventData event) {
    if (event.startTime.trim().isEmpty) {
      return l10n.calendarAllDay;
    }
    if (event.endTime.trim().isEmpty) {
      return event.startTime;
    }
    return '${event.startTime} - ${event.endTime}';
  }

  String _relativeDateLabel(AppLocalizations l10n, DateTime date) {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(now).inDays;

    if (difference == 0) {
      return l10n.today;
    }
    if (difference == 1) {
      return l10n.tomorrow;
    }
    if (difference > 1 && difference < 7) {
      return '${l10n.inDays} $difference ${l10n.days}';
    }

    return DateFormat('MMM d').format(date);
  }

  String _compactWeekdayLabel(String value) {
    final cleaned = value.replaceAll('.', '').trim();
    if (cleaned.length <= 3) {
      return cleaned;
    }
    return cleaned.substring(0, 3);
  }
}

class _TaCalendarEventData {
  final String id;
  final ScheduleItemKind kind;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String type;
  final String location;
  final String description;

  const _TaCalendarEventData({
    required this.id,
    required this.kind,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.location,
    required this.description,
  });
}

class _TaDateEventsSheet extends StatelessWidget {
  final List<_TaCalendarEventData> events;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<_TaCalendarEventData> onEventTap;

  const _TaDateEventsSheet({
    required this.events,
    required this.isDark,
    required this.l10n,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = events.isEmpty ? DateTime.now() : events.first.date;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2939) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM d, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${events.length} ${l10n.events}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ...events.map((event) => _buildEventItem(event)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(_TaCalendarEventData event) {
    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _getEventColor(event.type),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (event.startTime.isNotEmpty)
                    Text(
                      event.endTime.isEmpty
                          ? event.startTime
                          : '${event.startTime} - ${event.endTime}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'lab':
        return InstructorColors.info;
      case 'grading':
        return InstructorColors.warning;
      case 'office_hours':
        return InstructorColors.success;
      case 'meetings':
        return InstructorColors.primary;
      default:
        return InstructorColors.primary;
    }
  }
}
