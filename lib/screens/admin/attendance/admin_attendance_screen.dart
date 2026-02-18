import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../widgets/admin/dashboard/admin_drawer.dart';
import '../../../widgets/admin/attendance/attendance_barrel.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  late AnimationController _animationController;

  bool _isLoading = true;
  String? _error;
  AttendanceFilterType _selectedFilter = AttendanceFilterType.all;
  String _searchQuery = '';
  String? _selectedDepartment;
  int _selectedTabIndex = 0;

  // Mock data
  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Data Science',
    'Artificial Intelligence',
  ];

  List<CourseAttendanceData> _courses = [];
  List<StudentAttendanceInfo> _students = [];
  List<DepartmentAttendance> _departmentStats = [];
  List<WeeklyTrend> _weeklyTrends = [];

  // Stats
  int _totalStudents = 0;
  int _presentToday = 0;
  int _absentToday = 0;
  int _lateToday = 0;
  double _overallRate = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      _courses = [
        const CourseAttendanceData(
          courseId: '1',
          courseName: 'Operating Systems',
          courseCode: 'CS301',
          instructor: 'Dr. Ahmed Hassan',
          totalStudents: 45,
          presentToday: 38,
          absentToday: 5,
          lateToday: 2,
          attendanceRate: 0.89,
          department: 'Computer Science',
        ),
        const CourseAttendanceData(
          courseId: '2',
          courseName: 'Data Structures',
          courseCode: 'CS201',
          instructor: 'Dr. Sarah Johnson',
          totalStudents: 52,
          presentToday: 48,
          absentToday: 3,
          lateToday: 1,
          attendanceRate: 0.94,
          department: 'Computer Science',
        ),
        const CourseAttendanceData(
          courseId: '3',
          courseName: 'Machine Learning',
          courseCode: 'AI401',
          instructor: 'Prof. Michael Brown',
          totalStudents: 38,
          presentToday: 30,
          absentToday: 6,
          lateToday: 2,
          attendanceRate: 0.84,
          department: 'Artificial Intelligence',
        ),
        const CourseAttendanceData(
          courseId: '4',
          courseName: 'Database Systems',
          courseCode: 'CS302',
          instructor: 'Dr. Fatima Ali',
          totalStudents: 41,
          presentToday: 28,
          absentToday: 10,
          lateToday: 3,
          attendanceRate: 0.76,
          department: 'Information Technology',
        ),
        const CourseAttendanceData(
          courseId: '5',
          courseName: 'Software Engineering',
          courseCode: 'SE301',
          instructor: 'Dr. Omar Khalid',
          totalStudents: 35,
          presentToday: 33,
          absentToday: 1,
          lateToday: 1,
          attendanceRate: 0.97,
          department: 'Software Engineering',
        ),
      ];

      _students = [
        const StudentAttendanceInfo(
          id: '1',
          studentId: '22CS001',
          name: 'Ahmed Hassan',
          course: 'Operating Systems',
          status: StudentAttendanceStatus.present,
          totalClasses: 20,
          attendedClasses: 18,
          overallRate: 0.90,
        ),
        const StudentAttendanceInfo(
          id: '2',
          studentId: '22CS002',
          name: 'Sara Ibrahim',
          course: 'Data Structures',
          status: StudentAttendanceStatus.present,
          totalClasses: 20,
          attendedClasses: 20,
          overallRate: 1.0,
        ),
        const StudentAttendanceInfo(
          id: '3',
          studentId: '22CS003',
          name: 'Omar Ali',
          course: 'Machine Learning',
          status: StudentAttendanceStatus.absent,
          totalClasses: 20,
          attendedClasses: 14,
          overallRate: 0.70,
        ),
        const StudentAttendanceInfo(
          id: '4',
          studentId: '22CS004',
          name: 'Fatima Nour',
          course: 'Database Systems',
          status: StudentAttendanceStatus.late,
          totalClasses: 20,
          attendedClasses: 16,
          overallRate: 0.80,
        ),
        const StudentAttendanceInfo(
          id: '5',
          studentId: '22CS005',
          name: 'Youssef Ahmed',
          course: 'Software Engineering',
          status: StudentAttendanceStatus.present,
          totalClasses: 20,
          attendedClasses: 19,
          overallRate: 0.95,
        ),
      ];

      _departmentStats = const [
        DepartmentAttendance(name: 'Computer Science', rate: 0.91),
        DepartmentAttendance(name: 'Information Technology', rate: 0.85),
        DepartmentAttendance(name: 'Software Engineering', rate: 0.94),
        DepartmentAttendance(name: 'Data Science', rate: 0.88),
        DepartmentAttendance(name: 'Artificial Intelligence', rate: 0.82),
      ];

      _weeklyTrends = const [
        WeeklyTrend(day: 'Mon', rate: 0.92),
        WeeklyTrend(day: 'Tue', rate: 0.88),
        WeeklyTrend(day: 'Wed', rate: 0.85),
        WeeklyTrend(day: 'Thu', rate: 0.90, isToday: true),
        WeeklyTrend(day: 'Fri', rate: 0.78),
      ];

      _totalStudents = 15420;
      _presentToday = 13542;
      _absentToday = 1256;
      _lateToday = 622;
      _overallRate = 0.88;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<CourseAttendanceData> get _filteredCourses {
    var filtered = _courses;

    if (_selectedDepartment != null) {
      filtered = filtered
          .where((c) => c.department == _selectedDepartment)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.courseName.toLowerCase().contains(query) ||
                c.courseCode.toLowerCase().contains(query) ||
                c.instructor.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  List<StudentAttendanceInfo> get _filteredStudents {
    var filtered = _students;

    if (_selectedFilter != AttendanceFilterType.all) {
      filtered = filtered.where((s) {
        switch (_selectedFilter) {
          case AttendanceFilterType.present:
            return s.status == StudentAttendanceStatus.present;
          case AttendanceFilterType.absent:
            return s.status == StudentAttendanceStatus.absent;
          case AttendanceFilterType.late:
            return s.status == StudentAttendanceStatus.late;
          case AttendanceFilterType.excused:
            return s.status == StudentAttendanceStatus.excused;
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.studentId.toLowerCase().contains(query) ||
                s.course.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AdminColors.getBackgroundColor(isDark),
            // drawer: const AdminDrawer(),
            body: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(
                      gradient: AdminColors.lightBackgroundGradient,
                    ),
              child: SafeArea(
                child: _isLoading
                    ? _buildLoadingState(isDark)
                    : _error != null
                    ? _buildErrorState(isDark, l10n)
                    : _buildContent(isDark, l10n),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              color: isDark
                  ? AdminColors.darkTextSecondary
                  : AdminColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AdminColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AdminColors.darkText : AdminColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AdminColors.darkTextSecondary
                    : AdminColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildAppBar(isDark, l10n),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                AdminAttendanceStatsCard(
                  isDark: isDark,
                  totalStudents: _totalStudents,
                  presentToday: _presentToday,
                  absentToday: _absentToday,
                  lateToday: _lateToday,
                  overallRate: _overallRate,
                  onRefresh: _loadData,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              isDark: isDark,
              tabController: _tabController,
              tabs: [l10n.courses, l10n.students, l10n.analytics],
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesTab(isDark, l10n),
          _buildStudentsTab(isDark, l10n),
          _buildAnalyticsTab(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: isDark ? AdminColors.darkText : AdminColors.lightText,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        l10n.attendanceManager,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AdminColors.darkText : AdminColors.lightText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.qr_code_scanner_rounded,
            color: isDark ? AdminColors.darkText : AdminColors.lightText,
          ),
          onPressed: () => _showQRScanner(context),
          tooltip: 'QR Scanner',
        ),
        IconButton(
          icon: Icon(
            Icons.download_rounded,
            color: isDark ? AdminColors.darkText : AdminColors.lightText,
          ),
          onPressed: () => _showExportOptions(context, isDark),
          tooltip: l10n.export,
        ),
      ],
    );
  }

  Widget _buildCoursesTab(bool isDark, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AdminAttendanceFilters(
            isDark: isDark,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            selectedDepartment: _selectedDepartment,
            departments: _departments,
            onDepartmentChanged: (dept) {
              setState(() {
                _selectedDepartment = dept;
              });
            },
            onClearFilters: () {
              setState(() {
                _selectedFilter = AttendanceFilterType.all;
                _selectedDepartment = null;
                _searchQuery = '';
              });
            },
          ),
        ),
        SliverToBoxAdapter(
          child: AdminAttendanceCourseList(
            isDark: isDark,
            courses: _filteredCourses,
            onCourseTap: (course) =>
                _showCourseDetails(context, course, isDark),
            onExport: (course) => _exportCourseAttendance(course),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStudentsTab(bool isDark, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AdminAttendanceFilters(
            isDark: isDark,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            selectedDepartment: _selectedDepartment,
            departments: _departments,
            onDepartmentChanged: (dept) {
              setState(() {
                _selectedDepartment = dept;
              });
            },
            onClearFilters: () {
              setState(() {
                _selectedFilter = AttendanceFilterType.all;
                _selectedDepartment = null;
                _searchQuery = '';
              });
            },
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= _filteredStudents.length) return null;
            final student = _filteredStudents[index];
            return AdminAttendanceStudentCard(
              isDark: isDark,
              student: student,
              onTap: () => _showStudentDetails(context, student, isDark),
              onStatusChange: (status) => _updateStudentStatus(student, status),
            );
          }, childCount: _filteredStudents.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAnalyticsTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 16),
          AdminAttendanceAnalytics(
            isDark: isDark,
            departmentData: _departmentStats,
            weeklyTrends: _weeklyTrends,
          ),
          const SizedBox(height: 16),
          _buildQuickActions(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.darkCard : AdminColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AdminColors.darkCardBorder
              : AdminColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AdminColors.darkText : AdminColors.lightText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_rounded,
                  label: 'Send Alerts',
                  color: AdminColors.warning,
                  onTap: () => _sendLowAttendanceAlerts(),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email Report',
                  color: AdminColors.primary,
                  onTap: () => _sendEmailReport(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF Report',
                  color: AdminColors.error,
                  onTap: () => _generatePDFReport(),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.table_chart_rounded,
                  label: 'Excel Export',
                  color: AdminColors.success,
                  onTap: () => _generateExcelReport(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner opened'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExportOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AdminColors.error,
                ),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _generatePDFReport();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.table_chart_rounded,
                  color: AdminColors.success,
                ),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _generateExcelReport();
                },
              ),
              ListTile(
                leading: Icon(Icons.print_rounded, color: AdminColors.primary),
                title: const Text('Print Report'),
                onTap: () {
                  Navigator.pop(context);
                  _printReport();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCourseDetails(
    BuildContext context,
    CourseAttendanceData course,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AdminColors.darkDivider
                            : AdminColors.lightDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AdminColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AdminColors.darkText
                                    : AdminColors.lightText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${course.courseCode} • ${course.instructor}',
                              style: TextStyle(
                                color: isDark
                                    ? AdminColors.darkTextSecondary
                                    : AdminColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Today\'s Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AdminColors.darkText
                          : AdminColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDetailStat(
                        'Present',
                        course.presentToday.toString(),
                        AdminColors.success,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildDetailStat(
                        'Absent',
                        course.absentToday.toString(),
                        AdminColors.error,
                        isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildDetailStat(
                        'Late',
                        course.lateToday.toString(),
                        AdminColors.warning,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _exportCourseAttendance(course);
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AdminColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailStat(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AdminColors.darkTextSecondary
                    : AdminColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(
    BuildContext context,
    StudentAttendanceInfo student,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AdminColors.darkCard : AdminColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.darkDivider
                        : AdminColors.lightDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: AdminColors.primary,
                child: Text(
                  student.name
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                student.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdminColors.darkText : AdminColors.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${student.studentId} • ${student.course}',
                style: TextStyle(
                  color: isDark
                      ? AdminColors.darkTextSecondary
                      : AdminColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStudentStat(
                    'Classes',
                    '${student.attendedClasses}/${student.totalClasses}',
                    isDark,
                  ),
                  _buildStudentStat(
                    'Rate',
                    '${(student.overallRate * 100).toStringAsFixed(0)}%',
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Full Profile'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AdminColors.darkText : AdminColors.lightText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AdminColors.darkTextSecondary
                : AdminColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _updateStudentStatus(
    StudentAttendanceInfo student,
    StudentAttendanceStatus status,
  ) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = StudentAttendanceInfo(
          id: student.id,
          studentId: student.studentId,
          name: student.name,
          course: student.course,
          status: status,
          totalClasses: student.totalClasses,
          attendedClasses: student.attendedClasses,
          overallRate: student.overallRate,
          lastAttended: student.lastAttended,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.name} marked as ${status.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportCourseAttendance(CourseAttendanceData course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${course.courseName} attendance...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendLowAttendanceAlerts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending low attendance alerts...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendEmailReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing email report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generatePDFReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateExcelReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Excel report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing to print...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final TabController tabController;
  final List<String> tabs;

  _TabBarDelegate({
    required this.isDark,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AdminColors.darkBackground : AdminColors.lightBackground,
      child: TabBar(
        controller: tabController,
        labelColor: AdminColors.primary,
        unselectedLabelColor: isDark
            ? AdminColors.darkTextSecondary
            : AdminColors.lightTextSecondary,
        indicatorColor: AdminColors.primary,
        indicatorWeight: 3,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return isDark != oldDelegate.isDark;
  }
}
