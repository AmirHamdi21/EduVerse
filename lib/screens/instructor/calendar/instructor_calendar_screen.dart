import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/instructor/instructor_calendar_cubit.dart';
import '../../../bloc/instructor/instructor_calendar_state.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/office_hours_service.dart';
import '../../../services/api/schedule_api_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/calendar/instructor_add_event_sheet.dart';
import '../../../widgets/instructor/calendar/instructor_event_details_sheet.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';
import '../../../widgets/shared/loading/calendar_screen_skeleton.dart';

class InstructorCalendarScreen extends StatelessWidget {
  const InstructorCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final coreApiClient = CoreApiClient(storageService: StorageService());
        final scheduleApiService = ScheduleApiService(
          coreApiClient: coreApiClient,
        );
        final officeHoursService = OfficeHoursService(
          coreApiClient: coreApiClient,
        );

        return InstructorCalendarCubit(
          scheduleService: scheduleApiService,
          officeHoursService: officeHoursService,
        );
      },
      child: const _InstructorCalendarView(),
    );
  }
}

class _InstructorCalendarView extends StatelessWidget {
  const _InstructorCalendarView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: InstructorColors.background(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventSheet(context),
        backgroundColor: InstructorColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          l10n.addEvent,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<InstructorCalendarCubit, InstructorCalendarState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: InstructorColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: InstructorColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final hasCachedData =
              state.unifiedItems.isNotEmpty || state.events.isNotEmpty;
          final showInitialSkeleton = state.isLoading && !hasCachedData;

          return Stack(
            children: [
              _buildBackgroundDecorations(isDark),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context, l10n, isDark),
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
                                  _buildHeroCard(context, state, l10n, isDark),
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
                                      CalendarViewType.month) ...[
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
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _buildUtilityButton(
            onTap: () => safeBack(context, '/instructor/dashboard'),
            isDark: isDark,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iosBackIcon(context),
                  size: 16,
                  color: InstructorColors.textPrimaryColor(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.back,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
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
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthLabel = DateFormat(
      'MMMM yyyy',
      locale,
    ).format(state.focusedMonth);
    final totalEvents = state.filteredEvents.length;
    final focusEvents = state.getEventsForDate(state.selectedDate).length;
    final officeHours = state.filteredEvents
        .where((event) => event.type == InstructorEventType.officeHours)
        .length;
    final campusEvents = state.filteredEvents
        .where((event) => event.kind?.name == 'campusEvent')
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
            childAspectRatio: 1.20,
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
                title: l10n.officeHours,
                value: '$officeHours',
                color: const Color(0xFFBBF7D0),
              ),
              _buildHeroStat(
                title: l10n.calendarCampusEvents,
                value: '$campusEvents',
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
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final filterSummary = _activeFilterCount(state) == 7
        ? l10n.calendarAllEventTypes
        : '${_activeFilterCount(state)} ${l10n.events}';
    final campusSummary = state.campusSource == 'my'
        ? l10n.calendarMyCampusEvents
        : l10n.calendarAllCampusEvents;

    return Row(
      children: [
        Expanded(
          child: _buildMenuButton(
            icon: Icons.tune_rounded,
            title: l10n.calendarEventTypes,
            subtitle: filterSummary,
            color: InstructorColors.primary,
            isDark: isDark,
            onTap: (buttonContext) => _showFilterMenu(buttonContext, isDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMenuButton(
            icon: Icons.public_rounded,
            title: l10n.calendarCampusSource,
            subtitle: campusSummary,
            color: InstructorColors.accent,
            isDark: isDark,
            onTap: (buttonContext) =>
                _showCampusSourceMenu(buttonContext, isDark),
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
    required ValueChanged<BuildContext> onTap,
  }) {
    return Builder(
      builder: (buttonContext) => GestureDetector(
        onTap: () => onTap(buttonContext),
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
      ),
    );
  }

  Widget _buildViewSelector(
    BuildContext context,
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final views = <(CalendarViewType, String, IconData)>[
      (CalendarViewType.month, l10n.month, Icons.grid_view_rounded),
      (CalendarViewType.week, l10n.week, Icons.calendar_view_week_rounded),
      (CalendarViewType.day, l10n.day, Icons.view_day_rounded),
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
              onTap: () =>
                  context.read<InstructorCalendarCubit>().setViewType(view.$1),
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
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    switch (state.viewType) {
      case CalendarViewType.month:
        return _buildMonthViewCard(context, state, l10n, isDark);
      case CalendarViewType.week:
        return _buildWeekViewCard(context, state, l10n, isDark);
      case CalendarViewType.day:
        return _buildDayViewCard(context, state, l10n, isDark);
    }
  }

  Widget _buildMonthViewCard(
    BuildContext context,
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthTitle = DateFormat(
      'MMMM yyyy',
      locale,
    ).format(state.focusedMonth);
    final days = _buildMonthDays(state.focusedMonth);
    final selectedCount = state.getEventsForDate(state.selectedDate).length;
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
                onTap: () =>
                    context.read<InstructorCalendarCubit>().previousMonth(),
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
                onTap: () =>
                    context.read<InstructorCalendarCubit>().goToToday(),
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () =>
                    context.read<InstructorCalendarCubit>().nextMonth(),
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
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth =
                  date.month == state.focusedMonth.month &&
                  date.year == state.focusedMonth.year;
              final isSelected = _isSameDay(date, state.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final events = state.getEventsForDate(date);

              return GestureDetector(
                onTap: () =>
                    context.read<InstructorCalendarCubit>().selectDate(date),
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
                          : InstructorColors.borderColor(
                              isDark,
                            ).withValues(alpha: isCurrentMonth ? 1 : 0.35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : !isCurrentMonth
                              ? InstructorColors.textTertiaryColor(
                                  isDark,
                                ).withValues(alpha: 0.55)
                              : isToday
                              ? InstructorColors.primary
                              : InstructorColors.textPrimaryColor(isDark),
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      if (events.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.18)
                                : _getEventColor(
                                    events.first.type,
                                  ).withValues(alpha: 0.14),
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
    InstructorCalendarState state,
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
                  context.read<InstructorCalendarCubit>().selectDate(newDate);
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
                onTap: () =>
                    context.read<InstructorCalendarCubit>().goToToday(),
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.add(
                    const Duration(days: 7),
                  );
                  context.read<InstructorCalendarCubit>().selectDate(newDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: weekDates.map((date) {
              final isSelected = _isSameDay(date, state.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final events = _sortEvents(state.getEventsForDate(date));
              final label = DateFormat.E(locale).format(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<InstructorCalendarCubit>().selectDate(date),
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
            context,
            events: _sortEvents(state.selectedDateEvents),
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
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat(
      'EEEE, MMMM d',
      locale,
    ).format(state.selectedDate);
    final dayEvents = _sortEvents(state.selectedDateEvents);

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
                  context.read<InstructorCalendarCubit>().selectDate(newDate);
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
                onTap: () =>
                    context.read<InstructorCalendarCubit>().goToToday(),
              ),
              const SizedBox(width: 10),
              _buildNavIconButton(
                icon: Icons.chevron_right_rounded,
                isDark: isDark,
                onTap: () {
                  final newDate = state.selectedDate.add(
                    const Duration(days: 1),
                  );
                  context.read<InstructorCalendarCubit>().selectDate(newDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildQuickAgendaList(
            context,
            events: dayEvents,
            l10n: l10n,
            isDark: isDark,
            emptyLabel: l10n.calendarNothingPlanned,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAgendaList(
    BuildContext context, {
    required List<InstructorCalendarEvent> events,
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
                context,
                event: event,
                isDark: isDark,
                showRelativeDate: false,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSelectedDaySection(
    BuildContext context,
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final events = _sortEvents(state.selectedDateEvents);
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
              onPressed: () =>
                  _showDateEvents(context, state.selectedDate, state, isDark),
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
              title: l10n.calendarNoSelectedDayEvents,
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
                        context,
                        event: event,
                        isDark: isDark,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context,
    InstructorCalendarState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final upcomingEvents = _sortEvents(state.upcomingEvents).take(5).toList();

    return _buildSectionCard(
      isDark: isDark,
      header: Row(
        children: [
          Expanded(
            child: Text(
              l10n.upcomingEvents,
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
                        context,
                        event: event,
                        isDark: isDark,
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

  Widget _buildEventTile(
    BuildContext context, {
    required InstructorCalendarEvent event,
    required bool isDark,
    bool showRelativeDate = true,
  }) {
    final eventColor = _getEventColor(event.type);
    final relativeLabel = _relativeDateLabel(context, event.date);
    final timeLabel = _formatEventTime(context, event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEventDetails(context, event),
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
                        if (event.course != null && event.course!.isNotEmpty)
                          _buildMetaPill(
                            icon: Icons.menu_book_rounded,
                            label: event.course!,
                            isDark: isDark,
                          ),
                        if (event.location != null &&
                            event.location!.isNotEmpty)
                          _buildMetaPill(
                            icon: Icons.location_on_outlined,
                            label: event.location!,
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

  RelativeRect _menuPositionForButton(BuildContext buttonContext) {
    final overlay =
        Overlay.of(buttonContext).context.findRenderObject()! as RenderBox;
    final button = buttonContext.findRenderObject()! as RenderBox;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final top = bottomRight.dy + 8;
    return RelativeRect.fromLTRB(
      topLeft.dx,
      top,
      overlay.size.width - bottomRight.dx,
      overlay.size.height - top,
    );
  }

  void _showFilterMenu(BuildContext context, bool isDark) {
    final cubit = context.read<InstructorCalendarCubit>();
    final l10n = AppLocalizations.of(context);

    showMenu<void>(
      context: context,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: _menuPositionForButton(context),
      items: [
        _buildMenuOption(
          label: l10n.lectures,
          icon: Icons.school_rounded,
          color: InstructorColors.primary,
          isActive: cubit.state.filter.lectures,
          onTap: () => cubit.toggleFilterType(InstructorEventType.lecture),
        ),
        _buildMenuOption(
          label: l10n.labs,
          icon: Icons.science_rounded,
          color: InstructorColors.accent,
          isActive: cubit.state.filter.labs,
          onTap: () => cubit.toggleFilterType(InstructorEventType.lab),
        ),
        _buildMenuOption(
          label: l10n.officeHours,
          icon: Icons.schedule_rounded,
          color: InstructorColors.success,
          isActive: cubit.state.filter.officeHours,
          onTap: () => cubit.toggleFilterType(InstructorEventType.officeHours),
        ),
        _buildMenuOption(
          label: l10n.meetings,
          icon: Icons.groups_rounded,
          color: InstructorColors.warning,
          isActive: cubit.state.filter.meetings,
          onTap: () => cubit.toggleFilterType(InstructorEventType.meeting),
        ),
        _buildMenuOption(
          label: l10n.calendarDeadlineLabel,
          icon: Icons.flag_rounded,
          color: InstructorColors.error,
          isActive: cubit.state.filter.deadlines,
          onTap: () => cubit.toggleFilterType(InstructorEventType.deadline),
        ),
        _buildMenuOption(
          label: l10n.calendarGradingLabel,
          icon: Icons.grading_rounded,
          color: InstructorColors.info,
          isActive: cubit.state.filter.grading,
          onTap: () => cubit.toggleFilterType(InstructorEventType.grading),
        ),
        _buildMenuOption(
          label: l10n.exam,
          icon: Icons.quiz_rounded,
          color: InstructorColors.pink,
          isActive: cubit.state.filter.exams,
          onTap: () => cubit.toggleFilterType(InstructorEventType.exam),
        ),
        PopupMenuItem<void>(
          height: 44,
          onTap: cubit.resetFilters,
          child: Text(
            l10n.all,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _showCampusSourceMenu(BuildContext context, bool isDark) {
    final cubit = context.read<InstructorCalendarCubit>();
    final l10n = AppLocalizations.of(context);

    showMenu<void>(
      context: context,
      color: InstructorColors.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: _menuPositionForButton(context),
      items: [
        _buildMenuOption(
          label: l10n.calendarAllCampusEvents,
          icon: Icons.public_rounded,
          color: InstructorColors.primary,
          isActive: cubit.state.campusSource == 'all',
          onTap: () => cubit.setCampusSource('all'),
        ),
        _buildMenuOption(
          label: l10n.calendarMyCampusEvents,
          icon: Icons.person_rounded,
          color: InstructorColors.accent,
          isActive: cubit.state.campusSource == 'my',
          onTap: () => cubit.setCampusSource('my'),
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

  void _showAddEventSheet(BuildContext context) {
    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) =>
                InstructorAddEventSheet(initialDate: cubit.state.selectedDate),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, InstructorCalendarEvent event) {
    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: InstructorEventDetailsSheet(event: event),
      ),
    );
  }

  void _showDateEvents(
    BuildContext context,
    DateTime date,
    InstructorCalendarState state,
    bool isDark,
  ) {
    final events = state.getEventsForDate(date);
    if (events.isEmpty) {
      _showAddEventSheet(context);
      return;
    }

    final cubit = context.read<InstructorCalendarCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: _DateEventsSheet(
          date: date,
          events: events,
          isDark: isDark,
          onEventTap: (event) {
            Navigator.pop(bottomSheetContext);
            _showEventDetails(context, event);
          },
        ),
      ),
    );
  }

  int _activeFilterCount(InstructorCalendarState state) {
    var count = 0;
    if (state.filter.lectures) count++;
    if (state.filter.labs) count++;
    if (state.filter.officeHours) count++;
    if (state.filter.meetings) count++;
    if (state.filter.deadlines) count++;
    if (state.filter.grading) count++;
    if (state.filter.exams) count++;
    return count;
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

  List<InstructorCalendarEvent> _sortEvents(
    List<InstructorCalendarEvent> events,
  ) {
    final sorted = List<InstructorCalendarEvent>.from(events);
    sorted.sort((a, b) {
      final byDate = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
      ).compareTo(DateTime(b.date.year, b.date.month, b.date.day));
      if (byDate != 0) {
        return byDate;
      }

      return _timeValue(a.time).compareTo(_timeValue(b.time));
    });
    return sorted;
  }

  int _timeValue(String? value) {
    if (value == null || value.trim().isEmpty) {
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

  String _formatEventTime(BuildContext context, InstructorCalendarEvent event) {
    final l10n = AppLocalizations.of(context);
    if (event.time == null || event.time!.trim().isEmpty) {
      return l10n.calendarAllDay;
    }
    if (event.endTime == null || event.endTime!.trim().isEmpty) {
      return event.time!;
    }
    return '${event.time!} - ${event.endTime!}';
  }

  String _relativeDateLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
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

  Color _getEventColor(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return InstructorColors.primary;
      case InstructorEventType.lab:
        return InstructorColors.accent;
      case InstructorEventType.officeHours:
        return InstructorColors.success;
      case InstructorEventType.meeting:
        return InstructorColors.warning;
      case InstructorEventType.deadline:
        return InstructorColors.error;
      case InstructorEventType.grading:
        return InstructorColors.info;
      case InstructorEventType.exam:
        return InstructorColors.pink;
    }
  }

  IconData _getEventIcon(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return Icons.school_rounded;
      case InstructorEventType.lab:
        return Icons.science_rounded;
      case InstructorEventType.officeHours:
        return Icons.schedule_rounded;
      case InstructorEventType.meeting:
        return Icons.groups_rounded;
      case InstructorEventType.deadline:
        return Icons.flag_rounded;
      case InstructorEventType.grading:
        return Icons.grading_rounded;
      case InstructorEventType.exam:
        return Icons.quiz_rounded;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _compactWeekdayLabel(String value) {
    final cleaned = value.replaceAll('.', '').trim();
    if (cleaned.length <= 3) {
      return cleaned;
    }
    return cleaned.substring(0, 3);
  }
}

class _DateEventsSheet extends StatelessWidget {
  final DateTime date;
  final List<InstructorCalendarEvent> events;
  final bool isDark;
  final Function(InstructorCalendarEvent) onEventTap;

  const _DateEventsSheet({
    required this.date,
    required this.events,
    required this.isDark,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = AppLocalizations.of(context);

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
                  DateFormat('MMMM d, yyyy', locale).format(date),
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

  Widget _buildEventItem(InstructorCalendarEvent event) {
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
                  if (event.time != null)
                    Text(
                      '${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
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

  Color _getEventColor(InstructorEventType type) {
    switch (type) {
      case InstructorEventType.lecture:
        return InstructorColors.primary;
      case InstructorEventType.lab:
        return InstructorColors.accent;
      case InstructorEventType.officeHours:
        return InstructorColors.success;
      case InstructorEventType.meeting:
        return InstructorColors.warning;
      case InstructorEventType.deadline:
        return InstructorColors.error;
      case InstructorEventType.grading:
        return InstructorColors.info;
      case InstructorEventType.exam:
        return InstructorColors.pink;
    }
  }
}
