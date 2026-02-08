import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class GradingCenterScreen extends StatefulWidget {
  const GradingCenterScreen({super.key});

  @override
  State<GradingCenterScreen> createState() => _GradingCenterScreenState();
}

class _GradingCenterScreenState extends State<GradingCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCourse = 'All';
  bool _isLoading = true;
  List<_Submission> _submissions = [];

  final List<String> _courses = ['All', 'CS101 - OS', 'CS202 - Data Structures', 'CS305 - Database'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSubmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _submissions = _getDemoSubmissions();
        _isLoading = false;
      });
    }
  }

  List<_Submission> _getDemoSubmissions() {
    return [
      _Submission(id: '1', studentName: 'Ahmed Mohamed', studentEmail: 'ahmed@uni.edu', assignmentTitle: 'Process Scheduling', courseName: 'CS101 - OS', submittedAt: DateTime.now().subtract(const Duration(hours: 2)), status: 'pending', grade: null, maxGrade: 100),
      _Submission(id: '2', studentName: 'Sara Ahmed', studentEmail: 'sara@uni.edu', assignmentTitle: 'Binary Trees', courseName: 'CS202 - Data Structures', submittedAt: DateTime.now().subtract(const Duration(hours: 5)), status: 'pending', grade: null, maxGrade: 100),
      _Submission(id: '3', studentName: 'Omar Hassan', studentEmail: 'omar@uni.edu', assignmentTitle: 'SQL Queries', courseName: 'CS305 - Database', submittedAt: DateTime.now().subtract(const Duration(days: 1)), status: 'graded', grade: 85, maxGrade: 100),
      _Submission(id: '4', studentName: 'Fatima Ali', studentEmail: 'fatima@uni.edu', assignmentTitle: 'Memory Management', courseName: 'CS101 - OS', submittedAt: DateTime.now().subtract(const Duration(days: 2)), status: 'late', grade: null, maxGrade: 100, lateDays: 1),
      _Submission(id: '5', studentName: 'Youssef Khaled', studentEmail: 'youssef@uni.edu', assignmentTitle: 'Hash Tables', courseName: 'CS202 - Data Structures', submittedAt: DateTime.now().subtract(const Duration(days: 1)), status: 'graded', grade: 92, maxGrade: 100),
      _Submission(id: '6', studentName: 'Nour Ibrahim', studentEmail: 'nour@uni.edu', assignmentTitle: 'ER Diagrams', courseName: 'CS305 - Database', submittedAt: DateTime.now().subtract(const Duration(days: 3)), status: 'late', grade: null, maxGrade: 100, lateDays: 2),
    ];
  }

  List<_Submission> _getFilteredSubmissions(String filter) {
    return _submissions.where((s) {
      final matchesSearch = s.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.assignmentTitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCourse = _selectedCourse == 'All' || s.courseName == _selectedCourse;
      final matchesFilter = filter == 'all' ||
          (filter == 'pending' && s.status == 'pending') ||
          (filter == 'graded' && s.status == 'graded') ||
          (filter == 'late' && s.status == 'late');
      return matchesSearch && matchesCourse && matchesFilter;
    }).toList();
  }

  int get _pendingCount => _submissions.where((s) => s.status == 'pending').length;
  int get _gradedCount => _submissions.where((s) => s.status == 'graded').length;
  int get _lateCount => _submissions.where((s) => s.status == 'late').length;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              onPressed: () => context.pop(),
            ),
            title: Text(
              l10n.gradingCenter,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildStatChip(isDark, l10n.pending, _pendingCount, const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _buildStatChip(isDark, l10n.graded, _gradedCount, const Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        _buildStatChip(isDark, l10n.late, _lateCount, const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF155CFB),
                    unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF155CFB),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: [
                      Tab(text: l10n.all),
                      Tab(text: l10n.pending),
                      Tab(text: l10n.graded),
                      Tab(text: l10n.late),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              // Search and filter
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: l10n.searchStudents,
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourse,
                          dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                          items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCourse = v ?? 'All'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Submissions list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF155CFB)))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSubmissionsList(isDark, l10n, 'all'),
                          _buildSubmissionsList(isDark, l10n, 'pending'),
                          _buildSubmissionsList(isDark, l10n, 'graded'),
                          _buildSubmissionsList(isDark, l10n, 'late'),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(bool isDark, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsList(bool isDark, AppLocalizations l10n, String filter) {
    final submissions = _getFilteredSubmissions(filter);

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filter == 'pending' ? Icons.assignment_outlined :
              filter == 'graded' ? Icons.check_circle_outline :
              filter == 'late' ? Icons.schedule : Icons.inbox_outlined,
              size: 56,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              filter == 'pending' ? l10n.noPendingSubmissions :
              filter == 'graded' ? l10n.noGradedSubmissions :
              filter == 'late' ? l10n.noLateSubmissions : l10n.noSubmissionsFound,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      color: const Color(0xFF155CFB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          return _SubmissionCard(
            submission: submissions[index],
            isDark: isDark,
            onGrade: () => _showGradeDialog(context, isDark, l10n, submissions[index]),
          );
        },
      ),
    );
  }

  void _showGradeDialog(BuildContext context, bool isDark, AppLocalizations l10n, _Submission submission) {
    final gradeController = TextEditingController(text: submission.grade?.toString() ?? '');
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
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
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.gradeSubmission,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                submission.studentName,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              Text(
                submission.assignmentTitle,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              // Grade input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: gradeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.grade,
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '/ ${submission.maxGrade}',
                      style: TextStyle(fontSize: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick grade buttons
              Wrap(
                spacing: 8,
                children: [90, 80, 70, 60].map((grade) {
                  return ActionChip(
                    label: Text('$grade%'),
                    onPressed: () => gradeController.text = grade.toString(),
                    backgroundColor: isDark ? const Color(0xFF16213E) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Feedback
              TextField(
                controller: feedbackController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: l10n.feedback,
                  hintText: l10n.enterFeedback,
                  labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final grade = int.tryParse(gradeController.text);
                    if (grade != null && grade >= 0 && grade <= submission.maxGrade) {
                      setState(() {
                        submission.grade = grade;
                        submission.status = 'graded';
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.gradeSubmitted),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155CFB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.submitGrade),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Submission {
  final String id;
  final String studentName;
  final String studentEmail;
  final String assignmentTitle;
  final String courseName;
  final DateTime submittedAt;
  String status;
  int? grade;
  final int maxGrade;
  final int? lateDays;

  _Submission({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.assignmentTitle,
    required this.courseName,
    required this.submittedAt,
    required this.status,
    this.grade,
    required this.maxGrade,
    this.lateDays,
  });
}

class _SubmissionCard extends StatelessWidget {
  final _Submission submission;
  final bool isDark;
  final VoidCallback onGrade;

  const _SubmissionCard({
    required this.submission,
    required this.isDark,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = submission.status == 'pending'
        ? const Color(0xFFF59E0B)
        : submission.status == 'graded'
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);

    final statusLabel = submission.status == 'pending'
        ? l10n.pending
        : submission.status == 'graded'
            ? l10n.graded
            : l10n.late;

    final timeAgo = _getTimeAgo(submission.submittedAt, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF155CFB).withValues(alpha: 0.1),
                child: Text(
                  submission.studentName[0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFF155CFB), fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      submission.assignmentTitle,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.class_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                submission.courseName,
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
          if (submission.status == 'graded') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.grade}: ${submission.grade}/${submission.maxGrade}',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          if (submission.lateDays != null && submission.lateDays! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${submission.lateDays} ${submission.lateDays == 1 ? l10n.day : l10n.days} ${l10n.late.toLowerCase()}',
                  style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(l10n.viewDetails),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                    side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onGrade,
                  icon: Icon(submission.status == 'graded' ? Icons.edit : Icons.grading, size: 16),
                  label: Text(submission.status == 'graded' ? l10n.editGrade : l10n.grade),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155CFB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? l10n.day : l10n.days} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }
}
