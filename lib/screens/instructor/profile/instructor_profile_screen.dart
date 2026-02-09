import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/instructor/shared/instructor_colors.dart';

/// Instructor Profile Screen
class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key});

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  // Mock instructor data
  final Map<String, dynamic> _instructor = {
    'name': 'Dr. Sarah Mitchell',
    'email': 'sarah.mitchell@university.edu',
    'phone': '+1 (555) 123-4567',
    'department': 'Computer Science',
    'title': 'Associate Professor',
    'office': 'Building A, Room 302',
    'officeHours': 'Mon & Wed, 2-4 PM',
    'specialization': 'Artificial Intelligence, Machine Learning',
    'bio':
        'Dr. Sarah Mitchell is an Associate Professor of Computer Science with over 15 years of experience in teaching and research. Her research interests include AI, ML, and data science.',
    'joinDate': 'August 2018',
    'stats': {'courses': 4, 'students': 156, 'assignments': 28, 'rating': 4.8},
    'education': [
      {'degree': 'Ph.D. Computer Science', 'school': 'MIT', 'year': '2010'},
      {
        'degree': 'M.S. Computer Science',
        'school': 'Stanford University',
        'year': '2006',
      },
      {
        'degree': 'B.S. Computer Science',
        'school': 'UC Berkeley',
        'year': '2004',
      },
    ],
    'courses': [
      {
        'code': 'CS 101',
        'name': 'Introduction to Computer Science',
        'students': 45,
      },
      {'code': 'CS 201', 'name': 'Data Structures', 'students': 38},
      {'code': 'CS 301', 'name': 'Algorithms', 'students': 42},
      {'code': 'CS 401', 'name': 'Machine Learning', 'students': 31},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: InstructorColors.background(isDark),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(isDark, l10n),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(isDark, l10n),
                    _buildStatsSection(isDark, l10n),
                    _buildInfoSection(isDark, l10n),
                    _buildEducationSection(isDark, l10n),
                    _buildCoursesSection(isDark, l10n),
                    _buildActionsSection(isDark, l10n),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: InstructorColors.primary,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showEditProfileSheet(isDark, l10n),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/instructor/settings'),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                InstructorColors.primary,
                InstructorColors.primaryLight,
                const Color(0xFF0EA5E9),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      transform: Matrix4.translationValues(0, -50, 0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: InstructorColors.primary,
              border: Border.all(
                color: InstructorColors.cardColor(isDark),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: InstructorColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _instructor['name'],
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _instructor['title'],
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 16,
                color: InstructorColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _instructor['department'],
                style: TextStyle(
                  color: InstructorColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRatingBadge(isDark),
              const SizedBox(width: 12),
              _buildJoinedBadge(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: InstructorColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 16,
            color: InstructorColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            '${_instructor['stats']['rating']}',
            style: const TextStyle(
              color: InstructorColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: InstructorColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: InstructorColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: InstructorColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Since ${_instructor['joinDate']}',
            style: const TextStyle(
              color: InstructorColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, AppLocalizations l10n) {
    final stats = _instructor['stats'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.school_outlined,
            stats['courses'].toString(),
            l10n.courses,
            InstructorColors.primary,
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            Icons.people_outlined,
            stats['students'].toString(),
            l10n.students,
            InstructorColors.success,
            isDark,
          ),
          _buildStatDivider(isDark),
          _buildStatItem(
            Icons.assignment_outlined,
            stats['assignments'].toString(),
            l10n.assignments,
            InstructorColors.warning,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: InstructorColors.textTertiaryColor(isDark),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 60,
      color: InstructorColors.borderColor(isDark),
    );
  }

  Widget _buildInfoSection(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactInformation,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_outlined,
            l10n.email,
            _instructor['email'],
            isDark,
          ),
          _buildInfoRow(
            Icons.phone_outlined,
            l10n.phone,
            _instructor['phone'],
            isDark,
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            l10n.office,
            _instructor['office'],
            isDark,
          ),
          _buildInfoRow(
            Icons.access_time_outlined,
            l10n.officeHours,
            _instructor['officeHours'],
            isDark,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.specialization,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_instructor['specialization'] as String).split(', ').map(
              (spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: InstructorColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    spec,
                    style: const TextStyle(
                      color: InstructorColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.about,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _instructor['bio'],
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: InstructorColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: InstructorColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(bool isDark, AppLocalizations l10n) {
    final education = _instructor['education'] as List<Map<String, String>>;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 20,
                color: InstructorColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.education,
                style: TextStyle(
                  color: InstructorColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...education.map((edu) => _buildEducationItem(edu, isDark)),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, String> edu, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: InstructorColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: InstructorColors.primary, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu['degree']!,
                  style: TextStyle(
                    color: InstructorColors.textPrimaryColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      edu['school']!,
                      style: TextStyle(
                        color: InstructorColors.textSecondaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ' • ${edu['year']}',
                      style: TextStyle(
                        color: InstructorColors.textTertiaryColor(isDark),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(bool isDark, AppLocalizations l10n) {
    final courses = _instructor['courses'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: InstructorColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InstructorColors.borderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 20,
                    color: InstructorColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.currentCourses,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/instructor/courses'),
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    color: InstructorColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...courses.map((course) => _buildCourseItem(course, isDark)),
        ],
      ),
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> course, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/instructor/course-management'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    InstructorColors.primary,
                    InstructorColors.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  course['code'].toString().split(' ').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['name'],
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        course['code'],
                        style: TextStyle(
                          color: InstructorColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' • ${course['students']} students',
                        style: TextStyle(
                          color: InstructorColors.textTertiaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            Icons.settings_outlined,
            l10n.settings,
            () => context.push('/instructor/settings'),
            isDark,
          ),
          _buildActionButton(
            Icons.help_outline_rounded,
            l10n.helpSupport,
            () => context.push('/settings/help'),
            isDark,
          ),
          _buildActionButton(
            Icons.logout_rounded,
            l10n.logout,
            () => _showLogoutConfirmation(isDark, l10n),
            isDark,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: InstructorColors.borderColor(isDark)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive
                  ? InstructorColors.error
                  : InstructorColors.textSecondaryColor(isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? InstructorColors.error
                      : InstructorColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: InstructorColors.textTertiaryColor(isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: InstructorColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.editProfile,
                    style: TextStyle(
                      color: InstructorColors.textPrimaryColor(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: InstructorColors.textTertiaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Change profile photo
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: InstructorColors.primary,
                          ),
                          child: const Center(
                            child: Text(
                              'SM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: InstructorColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: InstructorColors.cardColor(isDark),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildEditField(
                    l10n.displayName,
                    _instructor['name'],
                    isDark,
                  ),
                  _buildEditField(l10n.phone, _instructor['phone'], isDark),
                  _buildEditField(
                    l10n.officeHours,
                    _instructor['officeHours'],
                    isDark,
                  ),
                  _buildEditField(
                    l10n.bio,
                    _instructor['bio'],
                    isDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.profileUpdated),
                            backgroundColor: InstructorColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InstructorColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.saveChanges,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    String value,
    bool isDark, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: InstructorColors.textSecondaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            maxLines: maxLines,
            style: TextStyle(
              color: InstructorColors.textPrimaryColor(isDark),
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: InstructorColors.borderColor(isDark),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: InstructorColors.borderColor(isDark),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: InstructorColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(bool isDark, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: InstructorColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: TextStyle(
            color: InstructorColors.textPrimaryColor(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: InstructorColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: InstructorColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: InstructorColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
