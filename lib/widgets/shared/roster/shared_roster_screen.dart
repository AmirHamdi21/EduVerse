import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/roster/roster_cubit.dart';
import '../../../bloc/roster/roster_state.dart';
import '../../../features/walkthrough/walkthrough_target.dart';
import '../../../models/instructor/instructor_course_model.dart';

class SharedRosterTheme {
  final String title;
  final String emptyCoursesTitle;
  final String emptyCoursesSubtitle;
  final String headerTitle;
  final String headerSubtitle;
  final Color primary;
  final Color accent;
  final Color teal;
  final Color orange;
  final Color pink;
  final LinearGradient headerGradient;
  final Color Function(bool isDark) background;
  final Color Function(bool isDark) cardColor;
  final Color Function(bool isDark) borderColor;
  final Color Function(bool isDark) textPrimary;
  final Color Function(bool isDark) textSecondary;
  final Color Function(bool isDark) textTertiary;

  const SharedRosterTheme({
    required this.title,
    required this.emptyCoursesTitle,
    required this.emptyCoursesSubtitle,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.primary,
    required this.accent,
    required this.teal,
    required this.orange,
    required this.pink,
    required this.headerGradient,
    required this.background,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });
}

class SharedRosterWalkthroughTargets {
  const SharedRosterWalkthroughTargets({
    required this.header,
    required this.controls,
    required this.list,
  });

  final String header;
  final String controls;
  final String list;
}

class SharedRosterScreen extends StatelessWidget {
  final bool isDark;
  final SharedRosterTheme theme;
  final SharedRosterWalkthroughTargets? walkthroughTargets;
  final String fallbackRoute;

  const SharedRosterScreen({
    super.key,
    required this.isDark,
    required this.theme,
    this.walkthroughTargets,
    this.fallbackRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background(isDark),
      body: SafeArea(
        child: BlocBuilder<RosterCubit, RosterState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<RosterCubit>().refresh(),
              color: theme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: _maybeTarget(
                      walkthroughTargets?.header,
                      _HeaderCard(theme: theme, isDark: isDark, state: state),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _maybeTarget(
                      walkthroughTargets?.controls,
                      _SectionSelector(
                        theme: theme,
                        isDark: isDark,
                        state: state,
                      ),
                    ),
                  ),
                  if (state.selectedCourse != null)
                    SliverToBoxAdapter(
                      child: _SelectedSectionSummary(
                        theme: theme,
                        isDark: isDark,
                        state: state,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _ViewModeTabs(
                      theme: theme,
                      isDark: isDark,
                      state: state,
                    ),
                  ),
                  if (state.selectedSectionId != null)
                    SliverToBoxAdapter(
                      child: _SearchAndSort(
                        theme: theme,
                        isDark: isDark,
                        state: state,
                      ),
                    ),
                  _buildBody(context, state),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: theme.cardColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.textPrimary(isDark),
          size: 20,
        ),
        onPressed: () => _handleBackPressed(context),
      ),
      title: Text(
        theme.title,
        style: TextStyle(
          color: theme.textPrimary(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, RosterState state) {
    if (state.coursesStatus == RosterStatus.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.coursesStatus == RosterStatus.error) {
      return SliverFillRemaining(
        child: _StateMessage(
          isDark: isDark,
          theme: theme,
          icon: Icons.error_outline_rounded,
          title: 'Unable to load courses',
          subtitle: state.errorMessage ?? 'Please try again.',
        ),
      );
    }

    if (state.courses.isEmpty) {
      return SliverFillRemaining(
        child: _StateMessage(
          isDark: isDark,
          theme: theme,
          icon: Icons.school_outlined,
          title: theme.emptyCoursesTitle,
          subtitle: theme.emptyCoursesSubtitle,
        ),
      );
    }

    if (state.selectedSectionId == null) {
      return SliverFillRemaining(
        child: _StateMessage(
          isDark: isDark,
          theme: theme,
          icon: Icons.touch_app_rounded,
          title: 'Select a section',
          subtitle: 'Choose a section to load the roster details.',
        ),
      );
    }

    if (state.studentsStatus == RosterStatus.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (state.studentsStatus == RosterStatus.error) {
      return SliverFillRemaining(
        child: _StateMessage(
          isDark: isDark,
          theme: theme,
          icon: Icons.warning_amber_rounded,
          title: 'Unable to load students',
          subtitle: state.errorMessage ?? 'Please try again.',
        ),
      );
    }

    final students = state.filteredStudents;
    if (students.isEmpty) {
      return SliverFillRemaining(
        child: _StateMessage(
          isDark: isDark,
          theme: theme,
          icon: Icons.people_outline_rounded,
          title: state.searchQuery.isEmpty
              ? 'No students enrolled'
              : 'No matching students',
          subtitle: state.searchQuery.isEmpty
              ? 'Enrolled students for this section will appear here.'
              : 'Try a different search query or sort option.',
        ),
      );
    }

    return state.viewMode == RosterViewMode.overview
        ? SliverList.builder(
            itemCount: students.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StudentsMeta(
                  theme: theme,
                  isDark: isDark,
                  state: state,
                );
              }

              final student = students[index - 1];
              final card = _StudentOverviewCard(
                theme: theme,
                isDark: isDark,
                student: student,
                note: state.noteForStudent(student.userId),
              );
              if (index == 1) {
                return _maybeTarget(walkthroughTargets?.list, card);
              }
              return card;
            },
          )
        : SliverToBoxAdapter(
            child: _maybeTarget(
              walkthroughTargets?.list,
              _DetailedGradesList(
                theme: theme,
                isDark: isDark,
                students: students,
              ),
            ),
          );
  }

  Widget _maybeTarget(String? id, Widget child) {
    if (id == null || id.isEmpty) return child;
    return WalkthroughTarget(id: id, child: child);
  }

  void _handleBackPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(fallbackRoute);
  }
}

class _HeaderCard extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _HeaderCard({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: theme.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      theme.headerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.headerSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _StatPill(
                icon: Icons.book_rounded,
                label: 'Courses',
                value: '${state.courses.length}',
              ),
              const SizedBox(width: 10),
              _StatPill(
                icon: Icons.groups_rounded,
                label: 'Students',
                value: '${state.totalStudents}',
              ),
              const SizedBox(width: 10),
              _StatPill(
                icon: Icons.class_rounded,
                label: 'Sections',
                value: '${state.courses.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionSelector extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _SectionSelector({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.borderColor(isDark)),
        ),
        child: DropdownButtonFormField<int>(
          initialValue: state.selectedSectionId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Select Section',
            labelStyle: TextStyle(color: theme.textSecondary(isDark)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: theme.borderColor(isDark)),
            ),
            filled: true,
            fillColor: theme.background(isDark),
          ),
          dropdownColor: theme.cardColor(isDark),
          items: state.courses.map((course) {
            return DropdownMenuItem<int>(
              value: course.sectionId,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '${course.course.code} • ${course.course.name} • Sec ${course.section.sectionNumber}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: theme.textPrimary(isDark)),
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return state.courses.map((course) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${course.course.code} • ${course.course.name} • Sec ${course.section.sectionNumber}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: theme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          onChanged: (value) {
            if (value != null) {
              context.read<RosterCubit>().selectCourse(value);
            }
          },
        ),
      ),
    );
  }
}

class _SelectedSectionSummary extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _SelectedSectionSummary({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final course = state.selectedCourse;
    if (course == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.borderColor(isDark)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              course.course.name,
              style: TextStyle(
                color: theme.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.primary,
                  label: course.course.code,
                ),
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.accent,
                  label: 'Section ${course.section.sectionNumber}',
                ),
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.teal,
                  label: course.semester.name,
                ),
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.orange,
                  label: '${course.enrolledCount} students',
                ),
              ],
            ),
            if ((state.instructorName ?? '').isNotEmpty ||
                (state.instructorEmail ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: theme.textTertiary(isDark),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [
                        if ((state.instructorName ?? '').isNotEmpty)
                          state.instructorName,
                        if ((state.instructorEmail ?? '').isNotEmpty)
                          state.instructorEmail,
                      ].whereType<String>().join(' • '),
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final Color color;
  final String label;

  const _InfoChip({
    required this.theme,
    required this.isDark,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ViewModeTabs extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _ViewModeTabs({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor(isDark)),
        ),
        child: Row(
          children: RosterViewMode.values.map((mode) {
            final selected = state.viewMode == mode;
            final label = mode == RosterViewMode.overview
                ? 'Overview'
                : 'Detailed Grades';
            return Expanded(
              child: InkWell(
                onTap: () => context.read<RosterCubit>().setViewMode(mode),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? theme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : theme.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SearchAndSort extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _SearchAndSort({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.borderColor(isDark)),
            ),
            child: TextField(
              onChanged: context.read<RosterCubit>().setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by ID, name, email, or status...',
                hintStyle: TextStyle(
                  color: theme.textTertiary(isDark),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.textTertiary(isDark),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: theme.textPrimary(isDark)),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RosterSortField.values.map((field) {
                final isSelected = state.sortField == field;
                final label = switch (field) {
                  RosterSortField.studentId => 'Student ID',
                  RosterSortField.enrollmentDate => 'Enrollment Date',
                  RosterSortField.status => 'Status',
                };
                final icon = switch (field) {
                  RosterSortField.studentId => Icons.badge_outlined,
                  RosterSortField.enrollmentDate =>
                    Icons.calendar_today_outlined,
                  RosterSortField.status => Icons.swap_vert_rounded,
                };

                return FilterChip(
                  selected: isSelected,
                  avatar: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : theme.primary,
                  ),
                  label: Text(
                    isSelected
                        ? '$label • ${state.sortDirection == RosterSortDirection.asc ? 'Asc' : 'Desc'}'
                        : label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textPrimary(isDark),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  backgroundColor: theme.cardColor(isDark),
                  selectedColor: theme.primary,
                  side: BorderSide(
                    color: isSelected
                        ? theme.primary
                        : theme.borderColor(isDark),
                  ),
                  onSelected: (_) =>
                      context.read<RosterCubit>().setSortField(field),
                  showCheckmark: false,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentsMeta extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final RosterState state;

  const _StudentsMeta({
    required this.theme,
    required this.isDark,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final sortedByLabel =
        'Sorted by ${switch (state.sortField) {
          RosterSortField.studentId => 'student ID',
          RosterSortField.enrollmentDate => 'enrollment date',
          RosterSortField.status => 'status',
        }}';

    final countPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${state.filteredStudents.length} student${state.filteredStudents.length == 1 ? '' : 's'}',
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );

    final sortText = Text(
      sortedByLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: theme.textSecondary(isDark),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                countPill,
                const SizedBox(height: 8),
                sortText,
              ],
            );
          }

          return Row(
            children: <Widget>[
              countPill,
              const SizedBox(width: 12),
              Expanded(
                child: Align(alignment: Alignment.centerRight, child: sortText),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentOverviewCard extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final SectionStudentModel student;
  final String? note;

  const _StudentOverviewCard({
    required this.theme,
    required this.isDark,
    required this.student,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (student.status.toLowerCase()) {
      'enrolled' => theme.primary,
      'completed' => theme.teal,
      'dropped' => theme.orange,
      _ => theme.pink,
    };

    final initials = _initials(student.displayName);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.borderColor(isDark).withValues(alpha: 0.75),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[theme.primary, theme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            student.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary(isDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          theme: theme,
                          isDark: isDark,
                          color: statusColor,
                          label: student.status,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.studentIdLabel,
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (student.resolvedEmail.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        student.resolvedEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textSecondary(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: note?.isNotEmpty == true ? 'Edit note' : 'Add note',
                onPressed: () => _openNoteEditor(context),
                icon: Icon(
                  Icons.sticky_note_2_outlined,
                  color: note?.isNotEmpty == true
                      ? theme.orange
                      : theme.textTertiary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (student.grade != null)
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.accent,
                  label: 'Grade ${student.grade!.toStringAsFixed(1)}',
                ),
              if (student.finalScore != null)
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.teal,
                  label: 'Score ${student.finalScore!.toStringAsFixed(1)}',
                ),
              if (student.enrollmentDate != null)
                _InfoChip(
                  theme: theme,
                  isDark: isDark,
                  color: theme.orange,
                  label: _formatDate(student.enrollmentDate!),
                ),
            ],
          ),
          if (note?.trim().isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.orange.withValues(alpha: isDark ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                note!,
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openNoteEditor(BuildContext context) async {
    final controller = TextEditingController(text: note ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Student Note',
                style: TextStyle(
                  color: theme.textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                student.displayName,
                style: TextStyle(color: theme.textSecondary(isDark)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type a note about this student...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await context.read<RosterCubit>().updateNote(
                          userId: student.userId,
                          note: controller.text,
                        );
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) {
      return 'ST';
    }
    return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DetailedGradesList extends StatelessWidget {
  final SharedRosterTheme theme;
  final bool isDark;
  final List<SectionStudentModel> students;

  const _DetailedGradesList({
    required this.theme,
    required this.isDark,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.borderColor(isDark)),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < students.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: 1,
                color: theme.borderColor(isDark).withValues(alpha: 0.55),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          students[index].displayName,
                          style: TextStyle(
                            color: theme.textPrimary(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          students[index].studentIdLabel,
                          style: TextStyle(
                            color: theme.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      students[index].grade?.toStringAsFixed(1) ?? 'N/A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      students[index].finalScore?.toStringAsFixed(1) ?? 'N/A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textPrimary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      students[index].status,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: theme.textSecondary(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final bool isDark;
  final SharedRosterTheme theme;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StateMessage({
    required this.isDark,
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: theme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondary(isDark),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
