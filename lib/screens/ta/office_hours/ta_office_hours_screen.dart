import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TAOfficeHoursScreen extends StatefulWidget {
  const TAOfficeHoursScreen({super.key});

  @override
  State<TAOfficeHoursScreen> createState() => _TAOfficeHoursScreenState();
}

class _TAOfficeHoursScreenState extends State<TAOfficeHoursScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock office hours data
  final List<Map<String, dynamic>> _officeHours = [
    {'day': 'Monday', 'startTime': '14:00', 'endTime': '16:00', 'location': 'Room 205', 'isOnline': false, 'isActive': true},
    {'day': 'Wednesday', 'startTime': '10:00', 'endTime': '12:00', 'location': 'Room 205', 'isOnline': false, 'isActive': true},
    {'day': 'Friday', 'startTime': '15:00', 'endTime': '17:00', 'location': 'Online - Zoom', 'isOnline': true, 'isActive': true},
  ];

  // Upcoming appointments
  final List<Map<String, dynamic>> _appointments = [
    {'studentName': 'John Smith', 'date': 'Mon, Feb 10', 'time': '2:30 PM', 'topic': 'Assignment Help', 'status': 'confirmed'},
    {'studentName': 'Emily Davis', 'date': 'Mon, Feb 10', 'time': '3:00 PM', 'topic': 'Grade Discussion', 'status': 'pending'},
    {'studentName': 'Michael Brown', 'date': 'Wed, Feb 12', 'time': '10:30 AM', 'topic': 'Lab Questions', 'status': 'confirmed'},
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
          drawer: const TADrawer(currentRoute: '/ta/office-hours'),
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
                        _buildQuickStats(isDark, l10n),
                        const SizedBox(height: 24),
                        _buildScheduleSection(isDark, l10n),
                        const SizedBox(height: 24),
                        _buildUpcomingAppointments(isDark, l10n),
                        const SizedBox(height: 24),
                        _buildAvailabilitySettings(isDark, l10n),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSlotSheet(isDark, l10n),
            backgroundColor: TAColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.taOfficeAddSlot,
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
      expandedHeight: 140,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () => _shareOfficeHours(isDark),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: () => _showSettingsSheet(isDark, l10n),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          l10n.taOfficeHoursTitle,
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
                  Icons.schedule_rounded,
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

  Widget _buildQuickStats(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${_officeHours.where((h) => h['isActive']).length}',
            l10n.taOfficeActiveSlots,
            Icons.event_available_rounded,
            TAColors.success,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${_appointments.length}',
            l10n.taOfficeUpcoming,
            Icons.people_rounded,
            TAColors.info,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${_appointments.where((a) => a['status'] == 'pending').length}',
            l10n.pending,
            Icons.pending_actions_rounded,
            TAColors.warning,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.taOfficeWeeklySchedule,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showEditScheduleSheet(isDark, l10n),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text(l10n.edit),
              style: TextButton.styleFrom(foregroundColor: TAColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._officeHours.map((slot) => _buildScheduleCard(slot, isDark)),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> slot, bool isDark) {
    final isOnline = slot['isOnline'] as bool;
    final isActive = slot['isActive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? TAColors.success.withValues(alpha: 0.3)
              : TAColors.borderColor(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isOnline ? TAColors.info : TAColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOnline ? Icons.videocam_rounded : Icons.meeting_room_rounded,
              color: isOnline ? TAColors.info : TAColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      slot['day'],
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? TAColors.success.withValues(alpha: 0.12)
                            : TAColors.textTertiaryColor(isDark).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive
                              ? TAColors.success
                              : TAColors.textTertiaryColor(isDark),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${slot['startTime']} - ${slot['endTime']}',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.link_rounded : Icons.location_on_outlined,
                      size: 14,
                      color: TAColors.textTertiaryColor(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      slot['location'],
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: TAColors.textSecondaryColor(isDark),
            ),
            onSelected: (value) => _handleSlotAction(value, slot, isDark),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(isActive ? 'Deactivate' : 'Activate'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.taOfficeUpcomingAppointments,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _showAllAppointments(isDark, l10n),
              child: Text(l10n.viewAll),
              style: TextButton.styleFrom(foregroundColor: TAColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_appointments.isEmpty)
          _buildEmptyAppointments(isDark, l10n)
        else
          ..._appointments.take(3).map((apt) => _buildAppointmentCard(apt, isDark)),
      ],
    );
  }

  Widget _buildEmptyAppointments(bool isDark, AppLocalizations l10n) {
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
              Icons.event_busy_rounded,
              size: 48,
              color: TAColors.textTertiaryColor(isDark),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.taOfficeNoAppointments,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt, bool isDark) {
    final isPending = apt['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? TAColors.warning.withValues(alpha: 0.3)
              : TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TAColors.primary, TAColors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                apt['studentName'][0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        apt['studentName'],
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending
                            ? TAColors.warning.withValues(alpha: 0.12)
                            : TAColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending ? 'Pending' : 'Confirmed',
                        style: TextStyle(
                          color: isPending ? TAColors.warning : TAColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${apt['date']} • ${apt['time']}',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 13,
                  ),
                ),
                Text(
                  apt['topic'],
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            IconButton(
              onPressed: () => _confirmAppointment(apt, isDark),
              icon: const Icon(Icons.check_circle_outline_rounded, color: TAColors.success),
            ),
            IconButton(
              onPressed: () => _declineAppointment(apt, isDark),
              icon: Icon(Icons.cancel_outlined, color: TAColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilitySettings(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TAColors.borderColor(isDark).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_rounded, color: TAColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.taOfficeQuickSettings,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            'Allow walk-ins',
            true,
            isDark,
            (value) {},
          ),
          _buildSettingRow(
            'Email reminders',
            true,
            isDark,
            (value) {},
          ),
          _buildSettingRow(
            'Auto-confirm appointments',
            false,
            isDark,
            (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    bool value,
    bool isDark,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: TAColors.primary,
          ),
        ],
      ),
    );
  }

  void _showAddSlotSheet(bool isDark, AppLocalizations l10n) {
    String selectedDay = 'Monday';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
    String location = '';
    bool isOnline = false;

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
                  l10n.taOfficeAddSlot,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // Day selector
                Text(
                  'Day',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                      .map((day) => ChoiceChip(
                            label: Text(day.substring(0, 3)),
                            selected: selectedDay == day,
                            onSelected: (selected) {
                              if (selected) setSheetState(() => selectedDay = day);
                            },
                            selectedColor: TAColors.primary.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: selectedDay == day
                                  ? TAColors.primary
                                  : TAColors.textPrimaryColor(isDark),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                        'Start Time',
                        startTime,
                        isDark,
                        (time) => setSheetState(() => startTime = time),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePicker(
                        'End Time',
                        endTime,
                        isDark,
                        (time) => setSheetState(() => endTime = time),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Online toggle
                SwitchListTile(
                  title: Text(
                    'Online Session',
                    style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                  ),
                  subtitle: Text(
                    'Enable for video call meetings',
                    style: TextStyle(
                      color: TAColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                  ),
                  value: isOnline,
                  onChanged: (value) => setSheetState(() => isOnline = value),
                  activeColor: TAColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                // Location field
                TextField(
                  onChanged: (value) => location = value,
                  decoration: InputDecoration(
                    labelText: isOnline ? 'Meeting Link' : 'Location',
                    labelStyle: TextStyle(color: TAColors.textSecondaryColor(isDark)),
                    hintText: isOnline ? 'https://zoom.us/...' : 'Room 205',
                    hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
                    prefixIcon: Icon(
                      isOnline ? Icons.link_rounded : Icons.location_on_outlined,
                      color: TAColors.textSecondaryColor(isDark),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TAColors.borderColor(isDark)),
                    ),
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
                      Navigator.pop(context);
                      setState(() {
                        _officeHours.add({
                          'day': selectedDay,
                          'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                          'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                          'location': location.isEmpty ? (isOnline ? 'Online' : 'TBD') : location,
                          'isOnline': isOnline,
                          'isActive': true,
                        });
                      });
                      _showSnackBar('Office hour slot added', isDark);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TAColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Slot',
                      style: TextStyle(
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

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    bool isDark,
    ValueChanged<TimeOfDay> onTimeChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onTimeChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TAColors.borderColor(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSlotAction(String action, Map<String, dynamic> slot, bool isDark) {
    switch (action) {
      case 'edit':
        _showEditSlotSheet(slot, isDark);
        break;
      case 'toggle':
        setState(() {
          slot['isActive'] = !slot['isActive'];
        });
        _showSnackBar(
          slot['isActive'] ? 'Slot activated' : 'Slot deactivated',
          isDark,
        );
        break;
      case 'delete':
        _showDeleteConfirmation(slot, isDark);
        break;
    }
  }

  void _showEditSlotSheet(Map<String, dynamic> slot, bool isDark) {
    _showSnackBar('Edit slot feature coming soon', isDark);
  }

  void _showDeleteConfirmation(Map<String, dynamic> slot, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Slot?',
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'Are you sure you want to delete this office hour slot?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _officeHours.remove(slot);
              });
              _showSnackBar('Slot deleted', isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmAppointment(Map<String, dynamic> apt, bool isDark) {
    setState(() {
      apt['status'] = 'confirmed';
    });
    _showSnackBar('Appointment confirmed', isDark);
  }

  void _declineAppointment(Map<String, dynamic> apt, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Decline Appointment?',
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          'Are you sure you want to decline this appointment?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _appointments.remove(apt);
              });
              _showSnackBar('Appointment declined', isDark);
            },
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAllAppointments(bool isDark, AppLocalizations l10n) {
    _showSnackBar('View all appointments coming soon', isDark);
  }

  void _showEditScheduleSheet(bool isDark, AppLocalizations l10n) {
    _showSnackBar('Edit schedule feature coming soon', isDark);
  }

  void _showSettingsSheet(bool isDark, AppLocalizations l10n) {
    _showSnackBar('Settings feature coming soon', isDark);
  }

  void _shareOfficeHours(bool isDark) {
    _showSnackBar('Share office hours coming soon', isDark);
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
