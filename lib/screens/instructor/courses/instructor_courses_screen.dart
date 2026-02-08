import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/instructor_course_model.dart';

class InstructorCoursesScreen extends StatefulWidget {
  const InstructorCoursesScreen({super.key});

  @override
  State<InstructorCoursesScreen> createState() => _InstructorCoursesScreenState();
}

class _InstructorCoursesScreenState extends State<InstructorCoursesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  List<InstructorCourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _courses = _getDemoCourses();
        _isLoading = false;
      });
    }
  }

  List<InstructorCourseModel> _getDemoCourses() {
    return [
      InstructorCourseModel(
        id: '1',
        name: 'Operating Systems',
        code: 'CS101',
        description: 'Introduction to OS concepts',
        totalStudents: 45,
        newItems: 3,
        activeQuizzes: 2,
        colorValue: 0xFF155CFB,
        isActive: true,
        semester: 'Fall 2025',
        assignments: [
          AssignmentModel(id: '1', title: 'Process Scheduling', dueDate: DateTime.now().add(const Duration(days: 3)), submissionsCount: 28, gradedCount: 15),
        ],
        materials: [],
        announcements: [],
      ),
      InstructorCourseModel(
        id: '2',
        name: 'Data Structures',
        code: 'CS202',
        description: 'Fundamental data structures',
        totalStudents: 38,
        newItems: 1,
        activeQuizzes: 1,
        colorValue: 0xFF10B981,
        isActive: true,
        semester: 'Fall 2025',
        assignments: [],
        materials: [],
        announcements: [],
      ),
      InstructorCourseModel(
        id: '3',
        name: 'Database Systems',
        code: 'CS305',
        description: 'Database design and SQL',
        totalStudents: 52,
        newItems: 2,
        activeQuizzes: 3,
        colorValue: 0xFFF59E0B,
        isActive: true,
        semester: 'Fall 2025',
        assignments: [],
        materials: [],
        announcements: [],
      ),
      InstructorCourseModel(
        id: '4',
        name: 'Machine Learning',
        code: 'CS401',
        description: 'Introduction to ML algorithms',
        totalStudents: 30,
        newItems: 0,
        activeQuizzes: 0,
        colorValue: 0xFF3B82F6,
        isActive: false,
        semester: 'Spring 2025',
        assignments: [],
        materials: [],
        announcements: [],
      ),
    ];
  }

  List<InstructorCourseModel> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && course.isActive) ||
          (_selectedFilter == 'archived' && !course.isActive);
      return matchesSearch && matchesFilter;
    }).toList();
  }

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
              l10n.myCourses,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                onPressed: () => _showCreateCourseDialog(context, isDark, l10n),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and filter bar
              Container(
                padding: const EdgeInsets.all(16),
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                child: Column(
                  children: [
                    // Search
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: l10n.searchCourses,
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    Row(
                      children: [
                        _buildFilterChip(isDark, l10n.all, 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(isDark, l10n.activeLabel, 'active'),
                        const SizedBox(width: 8),
                        _buildFilterChip(isDark, l10n.archived, 'archived'),
                      ],
                    ),
                  ],
                ),
              ),
              // Course list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF155CFB)))
                    : _filteredCourses.isEmpty
                        ? _buildEmptyState(isDark, l10n)
                        : RefreshIndicator(
                            onRefresh: _loadCourses,
                            color: const Color(0xFF155CFB),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                return _CourseCard(
                                  course: _filteredCourses[index],
                                  isDark: isDark,
                                  onTap: () => context.push('/instructor/course-management', extra: _filteredCourses[index]),
                                  onEdit: () => _showCreateCourseDialog(context, isDark, l10n, course: _filteredCourses[index]),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(bool isDark, String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF155CFB)
              : (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF155CFB)
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noCoursesFound,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingFilters,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context, bool isDark, AppLocalizations l10n, {InstructorCourseModel? course}) {
    final nameController = TextEditingController(text: course?.name ?? '');
    final codeController = TextEditingController(text: course?.code ?? '');
    final descController = TextEditingController(text: course?.description ?? '');
    final isEditing = course != null;

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
                isEditing ? l10n.editCourse : l10n.createCourse,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(isDark, nameController, l10n.courseName),
              const SizedBox(height: 16),
              _buildTextField(isDark, codeController, l10n.courseCode),
              const SizedBox(height: 16),
              _buildTextField(isDark, descController, l10n.description, maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Course updated' : l10n.courseCreated),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                    _loadCourses();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155CFB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEditing ? l10n.save : l10n.createCourse),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(bool isDark, TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final InstructorCourseModel course;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _CourseCard({
    required this.course,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(course.colorValue), Color(course.colorValue).withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          course.code.substring(0, 2).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${course.code} • ${course.semester}',
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
                        color: course.isActive
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.isActive ? l10n.activeLabel : l10n.archived,
                        style: TextStyle(
                          color: course.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStat(isDark, Icons.people_outline_rounded, '${course.totalStudents}', l10n.students),
                    const SizedBox(width: 24),
                    _buildStat(isDark, Icons.assignment_late_outlined, '${course.assignments.where((a) => !a.isGraded).length}', l10n.pending),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(l10n.edit),
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
                        onPressed: onTap,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(l10n.openCourse),
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
          ),
        ),
      ),
    );
  }

  Widget _buildStat(bool isDark, IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
