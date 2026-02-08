import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/attendance_model.dart';
import '../../../widgets/instructor/attendance/attendance_barrel.dart';

class AttendanceManagerScreen extends StatefulWidget {
  const AttendanceManagerScreen({super.key});

  @override
  State<AttendanceManagerScreen> createState() =>
      _AttendanceManagerScreenState();
}

class _AttendanceManagerScreenState extends State<AttendanceManagerScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isLoading = true;
  String? _error;
  String _selectedCourse = 'CS101 - Operating System';
  String _selectedWeek = 'Week 4 - Lecture';
  AttendanceFilterType _selectedFilter = AttendanceFilterType.all;
  String _searchQuery = '';

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  // Mock data
  List<StudentAttendance> _students = [];
  List<String> _courses = [];
  List<String> _weeks = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock courses
      _courses = [
        'CS101 - Operating System',
        'CS102 - Data Structures',
        'CS201 - Algorithms',
        'CS301 - Database Systems',
      ];

      // Mock weeks
      _weeks = [
        'Week 1 - Lecture',
        'Week 2 - Lecture',
        'Week 3 - Lecture',
        'Week 4 - Lecture',
        'Week 5 - Lab',
        'Week 6 - Lecture',
      ];

      // Mock students
      _students = [
        StudentAttendance(
          id: '1',
          studentId: '22CS001',
          studentName: 'Ahmed Hassan',
          status: AttendanceStatus.present,
          totalClasses: 8,
          attendedClasses: 6,
          overallAttendanceRate: 0.75,
          lastAttended: DateTime.now().subtract(const Duration(days: 1)),
        ),
        StudentAttendance(
          id: '2',
          studentId: '22CS002',
          studentName: 'Sara Ibrahim',
          status: AttendanceStatus.present,
          totalClasses: 8,
          attendedClasses: 8,
          overallAttendanceRate: 1.0,
          lastAttended: DateTime.now(),
        ),
        StudentAttendance(
          id: '3',
          studentId: '22CS003',
          studentName: 'Mohamed Ali',
          status: AttendanceStatus.present,
          totalClasses: 8,
          attendedClasses: 7,
          overallAttendanceRate: 0.875,
          lastAttended: DateTime.now().subtract(const Duration(days: 2)),
        ),
        StudentAttendance(
          id: '4',
          studentId: '22CS004',
          studentName: 'Fatima Mahmoud',
          status: AttendanceStatus.late,
          totalClasses: 8,
          attendedClasses: 5,
          overallAttendanceRate: 0.625,
          lastAttended: DateTime.now().subtract(const Duration(days: 3)),
        ),
        StudentAttendance(
          id: '5',
          studentId: '22CS005',
          studentName: 'Omar Khalid',
          status: AttendanceStatus.present,
          totalClasses: 8,
          attendedClasses: 4,
          overallAttendanceRate: 0.5,
          lastAttended: DateTime.now().subtract(const Duration(days: 5)),
          note: 'Frequently late to class',
        ),
        StudentAttendance(
          id: '6',
          studentId: '22CS006',
          studentName: 'Layla Ahmed',
          status: AttendanceStatus.unmarked,
          totalClasses: 8,
          attendedClasses: 6,
          overallAttendanceRate: 0.75,
          lastAttended: DateTime.now().subtract(const Duration(days: 7)),
        ),
        StudentAttendance(
          id: '7',
          studentId: '22CS007',
          studentName: 'Youssef Mohamed',
          status: AttendanceStatus.unmarked,
          totalClasses: 8,
          attendedClasses: 3,
          overallAttendanceRate: 0.375,
          lastAttended: DateTime.now().subtract(const Duration(days: 10)),
          note: 'Medical leave',
        ),
      ];

      setState(() => _isLoading = false);
      _animController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<StudentAttendance> get _filteredStudents {
    var filtered = _students;

    // Apply status filter
    if (_selectedFilter != AttendanceFilterType.all) {
      AttendanceStatus? targetStatus;
      switch (_selectedFilter) {
        case AttendanceFilterType.present:
          targetStatus = AttendanceStatus.present;
          break;
        case AttendanceFilterType.absent:
          targetStatus = AttendanceStatus.absent;
          break;
        case AttendanceFilterType.unmarked:
          targetStatus = AttendanceStatus.unmarked;
          break;
        default:
          break;
      }
      if (targetStatus != null) {
        filtered = filtered.where((s) => s.status == targetStatus).toList();
      }
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.studentName.toLowerCase().contains(query) ||
                s.studentId.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  int get _presentCount =>
      _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount =>
      _students.where((s) => s.status == AttendanceStatus.late).length;
  int get _unmarkedCount =>
      _students.where((s) => s.status == AttendanceStatus.unmarked).length;
  int get _markedCount => _students.length - _unmarkedCount;

  void _updateStudentStatus(String studentId, AttendanceStatus newStatus) {
    setState(() {
      final index = _students.indexWhere((s) => s.studentId == studentId);
      if (index != -1) {
        _students[index] = _students[index].copyWith(status: newStatus);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _markAllPresent() {
    setState(() {
      _students = _students
          .map((s) => s.copyWith(status: AttendanceStatus.present))
          .toList();
    });
    _showSnackBar('All students marked as present');
  }

  void _markAllAbsent() {
    setState(() {
      _students = _students
          .map((s) => s.copyWith(status: AttendanceStatus.absent))
          .toList();
    });
    _showSnackBar('All students marked as absent');
  }

  void _clearAll() {
    setState(() {
      _students = _students
          .map((s) => s.copyWith(status: AttendanceStatus.unmarked))
          .toList();
    });
    _showSnackBar('All attendance cleared');
  }

  void _showQRScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Scanner feature coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AttendanceColors.primary,
      ),
    );
  }

  void _saveAttendance() {
    if (_unmarkedCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unmarked Students'),
          content: Text(
            '$_unmarkedCount students still unmarked. Save anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performSave();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AttendanceColors.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      _performSave();
    }
  }

  void _performSave() {
    _showSnackBar('Attendance saved successfully');
  }

  void _exportAttendance() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = context.read<ThemeBloc>().state.isDark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AttendanceColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AttendanceColors.darkBorder
                      : AttendanceColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Export Attendance',
                style: TextStyle(
                  color: AttendanceColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildExportOption(
                ctx,
                Icons.picture_as_pdf_rounded,
                'Export as PDF',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                ctx,
                Icons.table_chart_rounded,
                'Export as Excel',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                ctx,
                Icons.share_rounded,
                'Share Report',
                isDark,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext ctx,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _showSnackBar('$label feature coming soon');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AttendanceColors.darkSurface
              : AttendanceColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AttendanceColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AttendanceColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AttendanceColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: AttendanceColors.textPrimaryColor(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AttendanceColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _notifyStudents() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeBloc>().state.isDark;
        return AlertDialog(
          backgroundColor: isDark ? AttendanceColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: AttendanceColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Notify Students',
                style: TextStyle(
                  color: AttendanceColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotifyOption(
                ctx,
                'Notify absent students',
                Icons.person_off_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildNotifyOption(
                ctx,
                'Notify low attendance',
                Icons.warning_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildNotifyOption(
                ctx,
                'Send to all students',
                Icons.group_rounded,
                isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AttendanceColors.textSecondaryColor(isDark),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotifyOption(
    BuildContext ctx,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _showSnackBar('Notification sent');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AttendanceColors.darkSurface
              : AttendanceColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AttendanceColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AttendanceColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AttendanceColors.textPrimaryColor(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetail(StudentAttendance student) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StudentDetailSheet(
        student: student,
        isDark: isDark,
        onNoteSaved: (note) {
          setState(() {
            final index = _students.indexWhere(
              (s) => s.studentId == student.studentId,
            );
            if (index != -1) {
              _students[index] = _students[index].copyWith(note: note);
            }
          });
        },
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark
              ? AttendanceColors.darkBackground
              : AttendanceColors.lightBackground,
          body: SafeArea(
            child: _isLoading
                ? AttendanceLoadingState(isDark: isDark, message: l10n.loading)
                : _error != null
                ? AttendanceErrorState(
                    isDark: isDark,
                    title: l10n.error,
                    message: _error,
                    onRetry: _loadData,
                  )
                : _buildContent(isDark, l10n),
          ),
          floatingActionButton: _isLoading || _error != null
              ? null
              : _buildBottomActionButtons(isDark, l10n),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildBottomActionButtons(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _exportAttendance,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: Text(l10n.exportAttendance),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AttendanceColors.darkSurface
                    : Colors.white,
                foregroundColor: AttendanceColors.textPrimaryColor(isDark),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AttendanceColors.borderColor(isDark)),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _notifyStudents,
              icon: const Icon(Icons.notifications_rounded, size: 18),
              label: Text(l10n.notifyStudents),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AttendanceColors.darkSurface
                    : Colors.white,
                foregroundColor: AttendanceColors.textPrimaryColor(isDark),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AttendanceColors.borderColor(isDark)),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(l10n.saveAttendance),
              style: ElevatedButton.styleFrom(
                backgroundColor: AttendanceColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        // App Bar
        _buildSliverAppBar(isDark, l10n),

        // Course & Week Selectors
        SliverToBoxAdapter(child: _buildSelectors(isDark, l10n)),

        // AI Alert (if any low attendance)
        if (_students.any((s) => s.overallAttendanceRate < 0.6))
          SliverToBoxAdapter(child: _buildAIAlert(isDark, l10n)),

        // Stats Cards
        SliverToBoxAdapter(child: _buildStatsSection(isDark, l10n)),

        // Quick Actions
        SliverToBoxAdapter(child: _buildQuickActions(isDark, l10n)),

        // Filters & Search
        SliverToBoxAdapter(child: _buildFiltersAndSearch(isDark, l10n)),

        // Student List
        _filteredStudents.isEmpty
            ? SliverFillRemaining(
                child: AttendanceEmptyState(
                  isDark: isDark,
                  title: l10n.noStudentsFound,
                  subtitle: l10n.noStudentsFoundSubtitle,
                  icon: Icons.search_off_rounded,
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final student = _filteredStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StudentAttendanceCard(
                        student: student,
                        isDark: isDark,
                        onStatusChanged: (status) =>
                            _updateStudentStatus(student.studentId, status),
                        onTap: () => _showStudentDetail(student),
                      ),
                    );
                  }, childCount: _filteredStudents.length),
                ),
              ),

        // Bottom spacing
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: isDark
          ? AttendanceColors.darkBackground
          : AttendanceColors.lightBackground,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AttendanceColors.textPrimaryColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: Icon(
            Icons.refresh_rounded,
            color: AttendanceColors.textSecondaryColor(isDark),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.attendanceManager,
              style: TextStyle(
                color: AttendanceColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.trackStudentAttendance,
              style: TextStyle(
                color: AttendanceColors.textSecondaryColor(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              isDark: isDark,
              value: _selectedCourse,
              items: _courses,
              icon: Icons.school_rounded,
              onChanged: (val) => setState(() => _selectedCourse = val!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              isDark: isDark,
              value: _selectedWeek,
              items: _weeks,
              icon: Icons.calendar_today_rounded,
              onChanged: (val) => setState(() => _selectedWeek = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required bool isDark,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AttendanceColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AttendanceColors.borderColor(isDark)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AttendanceColors.textSecondaryColor(isDark),
          ),
          dropdownColor: isDark ? AttendanceColors.darkCard : Colors.white,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AttendanceColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AttendanceColors.textPrimaryColor(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAIAlert(bool isDark, AppLocalizations l10n) {
    final lowAttendanceCount = _students
        .where((s) => s.overallAttendanceRate < 0.6)
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: AttendanceAIAlert(
        isDark: isDark,
        studentsAtRisk: lowAttendanceCount,
        onTap: () => setState(() => _selectedFilter = AttendanceFilterType.all),
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AttendanceStatsCard(
        isDark: isDark,
        presentCount: _presentCount,
        absentCount: _absentCount,
        lateCount: _lateCount,
        markedCount: _markedCount,
        totalStudents: _students.length,
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AttendanceQuickActions(
        isDark: isDark,
        onAllPresent: _markAllPresent,
        onAllAbsent: _markAllAbsent,
        onClearAll: _clearAll,
        onQRScan: _showQRScanner,
      ),
    );
  }

  Widget _buildFiltersAndSearch(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AttendanceFilterChips(
            isDark: isDark,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) =>
                setState(() => _selectedFilter = filter),
            counts: {
              AttendanceFilterType.all: _students.length,
              AttendanceFilterType.unmarked: _unmarkedCount,
              AttendanceFilterType.present: _presentCount,
              AttendanceFilterType.absent: _absentCount,
            },
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AttendanceSearchBar(
            controller: _searchController,
            isDark: isDark,
            hintText: l10n.searchStudents,
            onChanged: (val) => setState(() => _searchQuery = val),
            onClear: () => setState(() => _searchQuery = ''),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
