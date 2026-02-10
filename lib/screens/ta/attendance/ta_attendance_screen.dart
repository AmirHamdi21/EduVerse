import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';

class TAAttendanceScreen extends StatefulWidget {
  const TAAttendanceScreen({super.key});

  @override
  State<TAAttendanceScreen> createState() => _TAAttendanceScreenState();
}

class _TAAttendanceScreenState extends State<TAAttendanceScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  String _selectedCourse = 'All Courses';
  String _selectedLab = 'All Labs';
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _courses = [
    {'id': '1', 'name': 'Data Structures', 'code': 'CS201'},
    {'id': '2', 'name': 'Machine Learning', 'code': 'CS401'},
    {'id': '3', 'name': 'Database Systems', 'code': 'CS301'},
  ];

  final List<Map<String, dynamic>> _labs = [
    {'id': '1', 'name': 'Lab 1 - Arrays', 'courseId': '1'},
    {'id': '2', 'name': 'Lab 2 - Linked Lists', 'courseId': '1'},
    {'id': '3', 'name': 'Lab 1 - Neural Networks', 'courseId': '2'},
    {'id': '4', 'name': 'Lab 1 - SQL Basics', 'courseId': '3'},
  ];

  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudents();
  }

  void _loadStudents() {
    _students = [
      {
        'id': '1',
        'name': 'Ahmed Hassan',
        'studentId': 'STU001',
        'status': 'present',
        'checkInTime': '09:05 AM',
        'avatar': 'AH',
      },
      {
        'id': '2',
        'name': 'Sara Mohamed',
        'studentId': 'STU002',
        'status': 'present',
        'checkInTime': '09:02 AM',
        'avatar': 'SM',
      },
      {
        'id': '3',
        'name': 'Omar Ali',
        'studentId': 'STU003',
        'status': 'absent',
        'checkInTime': null,
        'avatar': 'OA',
      },
      {
        'id': '4',
        'name': 'Fatima Nour',
        'studentId': 'STU004',
        'status': 'late',
        'checkInTime': '09:25 AM',
        'avatar': 'FN',
      },
      {
        'id': '5',
        'name': 'Youssef Kamal',
        'studentId': 'STU005',
        'status': 'present',
        'checkInTime': '08:58 AM',
        'avatar': 'YK',
      },
      {
        'id': '6',
        'name': 'Mona Ibrahim',
        'studentId': 'STU006',
        'status': 'excused',
        'checkInTime': null,
        'avatar': 'MI',
      },
      {
        'id': '7',
        'name': 'Khaled Mahmoud',
        'studentId': 'STU007',
        'status': 'present',
        'checkInTime': '09:00 AM',
        'avatar': 'KM',
      },
      {
        'id': '8',
        'name': 'Nada Ahmed',
        'studentId': 'STU008',
        'status': 'absent',
        'checkInTime': null,
        'avatar': 'NA',
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/attendance'),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark, l10n),
                _buildStatsCards(isDark, l10n),
                _buildFilters(isDark, l10n),
                _buildTabBar(isDark, l10n),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTakeAttendanceTab(isDark, l10n),
                      _buildHistoryTab(isDark, l10n),
                      _buildReportsTab(isDark, l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showQuickActionsSheet(isDark, l10n),
            backgroundColor: TAColors.primary,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: Text(
              l10n.scanQr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: TAColors.textPrimaryColor(isDark)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.attendanceManager,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: TAColors.primary),
            onPressed: () => _selectDate(isDark),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: TAColors.textSecondaryColor(isDark),
            ),
            onPressed: () => _showSearchDialog(isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark, AppLocalizations l10n) {
    final presentCount = _students
        .where((s) => s['status'] == 'present')
        .length;
    final absentCount = _students.where((s) => s['status'] == 'absent').length;
    final lateCount = _students.where((s) => s['status'] == 'late').length;
    final excusedCount = _students
        .where((s) => s['status'] == 'excused')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark,
              l10n.present,
              presentCount.toString(),
              TAColors.success,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              isDark,
              l10n.absent,
              absentCount.toString(),
              TAColors.error,
              Icons.cancel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              isDark,
              l10n.late,
              lateCount.toString(),
              TAColors.warning,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              isDark,
              l10n.excused,
              excusedCount.toString(),
              TAColors.info,
              Icons.event_busy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              isDark,
              _selectedCourse,
              ['All Courses', ..._courses.map((c) => c['name'] as String)],
              (value) => setState(() => _selectedCourse = value!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropdown(isDark, _selectedLab, [
              'All Labs',
              ..._labs.map((l) => l['name'] as String),
            ], (value) => setState(() => _selectedLab = value!)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    bool isDark,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: TAColors.textSecondaryColor(isDark),
          ),
          dropdownColor: TAColors.cardColor(isDark),
          style: TextStyle(
            color: TAColors.textPrimaryColor(isDark),
            fontSize: 13,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: TAColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        // labelPadding: const EdgeInsets.symmetric(vertical: 12),
        labelColor: Colors.white,
        unselectedLabelColor: TAColors.textSecondaryColor(isDark),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: l10n.takeAttendance),
          Tab(text: l10n.history),
          Tab(text: l10n.reports),
        ],
      ),
    );
  }

  Widget _buildTakeAttendanceTab(bool isDark, AppLocalizations l10n) {
    final filteredStudents = _students.where((s) {
      if (_searchQuery.isNotEmpty) {
        final name = (s['name'] as String).toLowerCase();
        final id = (s['studentId'] as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            id.contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    return Column(
      children: [
        _buildBulkActionsBar(isDark, l10n),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
              return _buildStudentCard(isDark, l10n, student);
            },
          ),
        ),
        // _buildSaveBar(isDark, l10n),
      ],
    );
  }

  Widget _buildBulkActionsBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_students.length} ${l10n.students}',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _markAllPresent(),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: Text(l10n.markAllPresent),
            style: TextButton.styleFrom(foregroundColor: TAColors.success),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _markAllAbsent(),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: Text(l10n.markAllAbsent),
            style: TextButton.styleFrom(foregroundColor: TAColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> student,
  ) {
    final status = student['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showStudentDetails(isDark, l10n, student),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: TAColors.primaryLight,
                  radius: 22,
                  child: Text(
                    student['avatar'],
                    style: const TextStyle(
                      color: TAColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        student['studentId'],
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                      if (student['checkInTime'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: TAColors.textTertiaryColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student['checkInTime'],
                              style: TextStyle(
                                color: TAColors.textTertiaryColor(isDark),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                _buildStatusButtons(isDark, student),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtons(bool isDark, Map<String, dynamic> student) {
    final status = student['status'] as String;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(
          isDark,
          student,
          'present',
          Icons.check,
          TAColors.success,
        ),
        const SizedBox(width: 4),
        _buildStatusButton(
          isDark,
          student,
          'absent',
          Icons.close,
          TAColors.error,
        ),
        const SizedBox(width: 4),
        _buildStatusButton(
          isDark,
          student,
          'late',
          Icons.schedule,
          TAColors.warning,
        ),
        const SizedBox(width: 4),
        _buildStatusButton(
          isDark,
          student,
          'excused',
          Icons.event_busy,
          TAColors.info,
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    bool isDark,
    Map<String, dynamic> student,
    String status,
    IconData icon,
    Color color,
  ) {
    final isActive = student['status'] == status;
    return InkWell(
      onTap: () {
        setState(() {
          student['status'] = status;
          if (status == 'present' || status == 'late') {
            student['checkInTime'] = DateFormat(
              'hh:mm a',
            ).format(DateTime.now());
          } else {
            student['checkInTime'] = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.white : color),
      ),
    );
  }

  Widget _buildSaveBar(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _resetAttendance(),
              style: OutlinedButton.styleFrom(
                foregroundColor: TAColors.textSecondaryColor(isDark),
                side: BorderSide(color: TAColors.borderColor(isDark)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.reset),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _saveAttendance(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                l10n.saveAttendance,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark, AppLocalizations l10n) {
    final historyData = [
      {
        'date': 'Feb 10, 2026',
        'lab': 'Lab 1 - Arrays',
        'present': 25,
        'absent': 3,
        'late': 2,
      },
      {
        'date': 'Feb 8, 2026',
        'lab': 'Lab 2 - Linked Lists',
        'present': 24,
        'absent': 4,
        'late': 2,
      },
      {
        'date': 'Feb 5, 2026',
        'lab': 'Lab 1 - Neural Networks',
        'present': 28,
        'absent': 1,
        'late': 1,
      },
      {
        'date': 'Feb 3, 2026',
        'lab': 'Lab 1 - SQL Basics',
        'present': 22,
        'absent': 5,
        'late': 3,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final record = historyData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TAColors.borderColor(isDark)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _viewHistoryDetails(isDark, l10n, record),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: TAColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: TAColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['lab'] as String,
                                style: TextStyle(
                                  color: TAColors.textPrimaryColor(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                record['date'] as String,
                                style: TextStyle(
                                  color: TAColors.textSecondaryColor(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: TAColors.textTertiaryColor(isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHistoryStat(
                          isDark,
                          '${record['present']}',
                          l10n.present,
                          TAColors.success,
                        ),
                        _buildHistoryStat(
                          isDark,
                          '${record['absent']}',
                          l10n.absent,
                          TAColors.error,
                        ),
                        _buildHistoryStat(
                          isDark,
                          '${record['late']}',
                          l10n.late,
                          TAColors.warning,
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
  }

  Widget _buildHistoryStat(
    bool isDark,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportCard(
            isDark,
            l10n,
            l10n.attendanceOverview,
            Icons.pie_chart,
            'Overall attendance rate: 87%',
            () => _generateReport('overview'),
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            isDark,
            l10n,
            l10n.studentReport,
            Icons.person,
            'Individual student attendance reports',
            () => _generateReport('student'),
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            isDark,
            l10n,
            l10n.courseReport,
            Icons.school,
            'Attendance by course and lab',
            () => _generateReport('course'),
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            isDark,
            l10n,
            l10n.exportData,
            Icons.download,
            'Export attendance data (CSV, PDF)',
            () => _exportData(isDark, l10n),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.quickInsights,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            isDark,
            l10n,
            Icons.trending_up,
            'Attendance improved by 5% this week',
            TAColors.success,
          ),
          _buildInsightCard(
            isDark,
            l10n,
            Icons.warning_amber,
            '3 students have low attendance (<70%)',
            TAColors.warning,
          ),
          _buildInsightCard(
            isDark,
            l10n,
            Icons.schedule,
            'Most late arrivals occur on Mondays',
            TAColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    bool isDark,
    AppLocalizations l10n,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TAColors.borderColor(isDark)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TAColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: TAColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: TAColors.textTertiaryColor(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    bool isDark,
    AppLocalizations l10n,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return TAColors.success;
      case 'absent':
        return TAColors.error;
      case 'late':
        return TAColors.warning;
      case 'excused':
        return TAColors.info;
      default:
        return TAColors.textSecondaryColor(false);
    }
  }

  void _selectDate(bool isDark) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TAColors.primary,
              surface: TAColors.cardColor(isDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _showSearchDialog(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.searchStudents,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchByNameOrId,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showQuickActionsSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.quickActions,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              isDark,
              Icons.qr_code_scanner,
              l10n.scanQr,
              'Scan student QR for quick check-in',
              () {
                Navigator.pop(context);
                _scanQR();
              },
            ),
            _buildActionTile(
              isDark,
              Icons.nfc,
              l10n.nfcCheckIn,
              'Use NFC for attendance',
              () {
                Navigator.pop(context);
                _nfcCheckIn();
              },
            ),
            _buildActionTile(
              isDark,
              Icons.link,
              l10n.generateLink,
              'Generate attendance link for students',
              () {
                Navigator.pop(context);
                _generateLink(l10n);
              },
            ),
            _buildActionTile(
              isDark,
              Icons.location_on,
              l10n.locationBased,
              'Enable geolocation check-in',
              () {
                Navigator.pop(context);
                _locationBasedAttendance();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TAColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: TAColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: TAColors.textTertiaryColor(isDark),
      ),
      onTap: onTap,
    );
  }

  void _showStudentDetails(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> student,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              backgroundColor: TAColors.primaryLight,
              radius: 40,
              child: Text(
                student['avatar'],
                style: const TextStyle(
                  color: TAColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              student['name'],
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              student['studentId'],
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailStat(
                  isDark,
                  '92%',
                  l10n.attendanceRate,
                  TAColors.success,
                ),
                _buildDetailStat(isDark, '2', l10n.absences, TAColors.error),
                _buildDetailStat(
                  isDark,
                  '3',
                  l10n.lateArrivals,
                  TAColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/ta/student-performance');
                    },
                    icon: const Icon(Icons.analytics),
                    label: Text(l10n.viewPerformance),
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
                      context.push('/ta/messages');
                    },
                    icon: const Icon(Icons.message),
                    label: Text(l10n.sendMessage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TAColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(
    bool isDark,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: TAColors.textSecondaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        student['status'] = 'present';
        student['checkInTime'] = DateFormat('hh:mm a').format(DateTime.now());
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var student in _students) {
        student['status'] = 'absent';
        student['checkInTime'] = null;
      }
    });
  }

  void _resetAttendance() {
    setState(() => _loadStudents());
  }

  void _saveAttendance(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.attendanceSaved),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _viewHistoryDetails(
    bool isDark,
    AppLocalizations l10n,
    Map<String, dynamic> record,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
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
            Text(
              record['lab'] as String,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              record['date'] as String,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailStat(
                  isDark,
                  '${record['present']}',
                  l10n.present,
                  TAColors.success,
                ),
                _buildDetailStat(
                  isDark,
                  '${record['absent']}',
                  l10n.absent,
                  TAColors.error,
                ),
                _buildDetailStat(
                  isDark,
                  '${record['late']}',
                  l10n.late,
                  TAColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TAColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(l10n.viewDetails),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _generateReport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $type report...'),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _exportData(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.exportData,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              isDark,
              Icons.table_chart,
              'CSV',
              'Spreadsheet format',
              () => Navigator.pop(context),
            ),
            _buildExportOption(
              isDark,
              Icons.picture_as_pdf,
              'PDF',
              'Document format',
              () => Navigator.pop(context),
            ),
            _buildExportOption(
              isDark,
              Icons.code,
              'JSON',
              'Data format',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TAColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: TAColors.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: TAColors.textSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  void _scanQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening QR Scanner...'),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _nfcCheckIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('NFC check-in enabled. Tap student card...'),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _generateLink(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Attendance link generated and copied!'),
        backgroundColor: TAColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _locationBasedAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location-based attendance enabled'),
        backgroundColor: TAColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
