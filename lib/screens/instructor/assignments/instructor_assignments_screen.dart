import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/instructor_assignments_cubit.dart';
import '../../../bloc/instructor/instructor_assignments_state.dart';
import '../../../models/assignments/assignment_model.dart';
import '../../../models/core/enums/assignment_enums.dart' as api;
import '../../../services/api/assignment_service.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/assignments/assignment_barrel.dart';

class InstructorAssignmentsScreen extends StatelessWidget {
  const InstructorAssignmentsScreen({
    super.key,
    this.assignmentService,
    this.enrollmentService,
    this.canManageAssignments = true,
    this.initialCourseId,
    this.lockCourseSelection = false,
    this.embedded = false,
  });

  final AssignmentService? assignmentService;
  final EnrollmentService? enrollmentService;
  final bool canManageAssignments;
  final int? initialCourseId;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final coreApiClient = CoreApiClient(storageService: StorageService());
    final resolvedAssignmentService =
        assignmentService ?? AssignmentService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorAssignmentsCubit>(
      create: (_) => InstructorAssignmentsCubit(
        assignmentService: resolvedAssignmentService,
        enrollmentService: resolvedEnrollmentService,
      )..loadTeachingCourses(preferredCourseId: initialCourseId),
      child: _InstructorAssignmentsView(
        canManage: canManageAssignments,
        lockCourseSelection: lockCourseSelection,
        embedded: embedded,
      ),
    );
  }
}

class _InstructorAssignmentsView extends StatefulWidget {
  const _InstructorAssignmentsView({
    required this.canManage,
    required this.lockCourseSelection,
    required this.embedded,
  });

  final bool canManage;
  final bool lockCourseSelection;
  final bool embedded;

  @override
  State<_InstructorAssignmentsView> createState() =>
      _InstructorAssignmentsViewState();
}

class _InstructorAssignmentsViewState
    extends State<_InstructorAssignmentsView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  AssignmentType? _typeFilter;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstructorAssignmentsCubit, InstructorAssignmentsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<InstructorAssignmentsCubit>();
        final assignments = state.assignmentItems;
        final availableCourseIds = state.teachingCourses
            .map((course) => course.courseId)
            .toSet();
        final selectedCourseId =
            availableCourseIds.contains(state.selectedCourseId)
            ? state.selectedCourseId
            : null;

        final content = Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DropdownButtonFormField<int>(
                value: selectedCourseId,
                decoration: const InputDecoration(
                  labelText: 'Teaching course',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: state.teachingCourses.map((course) {
                  final label = '${course.course.code} - ${course.course.name}'
                      .trim();
                  return DropdownMenuItem<int>(
                    value: course.courseId,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: widget.lockCourseSelection
                    ? null
                    : (value) => cubit.selectCourse(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    if (!mounted) {
                      return;
                    }
                    context.read<InstructorAssignmentsCubit>().setSearchQuery(
                      value,
                    );
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search assignments',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: <Widget>[
                  _StatusFilterChip(
                    label: 'All',
                    selected: state.statusFilter == null,
                    onTap: () => cubit.setStatusFilter(null),
                  ),
                  _StatusFilterChip(
                    label: 'Draft',
                    selected: state.statusFilter == api.AssignmentStatus.draft,
                    onTap: () =>
                        cubit.setStatusFilter(api.AssignmentStatus.draft),
                  ),
                  _StatusFilterChip(
                    label: 'Published',
                    selected:
                        state.statusFilter == api.AssignmentStatus.published,
                    onTap: () =>
                        cubit.setStatusFilter(api.AssignmentStatus.published),
                  ),
                  _StatusFilterChip(
                    label: 'Closed',
                    selected: state.statusFilter == api.AssignmentStatus.closed,
                    onTap: () =>
                        cubit.setStatusFilter(api.AssignmentStatus.closed),
                  ),
                  _StatusFilterChip(
                    label: 'Archived',
                    selected:
                        state.statusFilter == api.AssignmentStatus.archived,
                    onTap: () =>
                        cubit.setStatusFilter(api.AssignmentStatus.archived),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: <Widget>[
                  _TypeFilterChip(
                    label: 'All',
                    selected: _typeFilter == null,
                    onTap: () => setState(() => _typeFilter = null),
                  ),
                  _TypeFilterChip(
                    label: 'Assignments',
                    selected: _typeFilter == AssignmentType.document,
                    onTap: () => setState(
                      () => _typeFilter = AssignmentType.document,
                    ),
                  ),
                  _TypeFilterChip(
                    label: 'Labs',
                    selected: _typeFilter == AssignmentType.lab,
                    onTap: () => setState(() => _typeFilter = AssignmentType.lab),
                  ),
                  _TypeFilterChip(
                    label: 'Projects',
                    selected: _typeFilter == AssignmentType.project,
                    onTap: () => setState(
                      () => _typeFilter = AssignmentType.project,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildList(cubit, state, assignments)),
          ],
        );

        if (widget.embedded) {
          return content;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Assignments')),
          floatingActionButton: widget.canManage
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await context.push(
                      '/instructor/assignments/create',
                    );
                    if (!mounted) {
                      return;
                    }
                    if (result == true) {
                      await cubit.loadAssignments(
                        page: 1,
                        limit: 20,
                        refresh: true,
                      );
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Assignment'),
                )
              : null,
          body: content,
        );
      },
    );
  }

  Widget _buildList(
    InstructorAssignmentsCubit cubit,
    InstructorAssignmentsState state,
    List<AssignmentModel> assignments,
  ) {
    if (state.isLoading && state.assignments == null) {
      return ListView.builder(
        physics: widget.embedded ? const ClampingScrollPhysics() : null,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 116,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Apply type filter
    final typedAssignments = _typeFilter == null
        ? assignments
        : assignments.where((a) => a.type == _typeFilter).toList();

    if (typedAssignments.isEmpty) {
      return const _EmptyAssignmentsState();
    }

    // If a specific type is selected, show flat list
    if (_typeFilter != null) {
      return RefreshIndicator(
        onRefresh: () => cubit.loadAssignments(page: 1, refresh: true),
        child: CustomScrollView(
          physics: widget.embedded ? const ClampingScrollPhysics() : null,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverList.builder(
                itemCount: typedAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = typedAssignments[index];
                  return _buildAssignmentCard(cubit, assignment);
                },
              ),
            ),
          ],
        ),
      );
    }

    // "All" type: group by type with section headers
    final byType = <AssignmentType, List<AssignmentModel>>{};
    for (final a in typedAssignments) {
      byType.putIfAbsent(a.type, () => []).add(a);
    }

    // Order: document (Assignment) first, then lab, then project, then others
    final typeOrder = [
      AssignmentType.document,
      AssignmentType.lab,
      AssignmentType.project,
      AssignmentType.code,
      AssignmentType.presentation,
      AssignmentType.quiz,
      AssignmentType.other,
    ];

    final sections = <_TypeSection>[];
    for (final type in typeOrder) {
      final items = byType[type];
      if (items != null && items.isNotEmpty) {
        sections.add(_TypeSection(type: type, items: items));
      }
    }

    // Any remaining types not in typeOrder
    for (final entry in byType.entries) {
      if (!typeOrder.contains(entry.key)) {
        sections.add(_TypeSection(type: entry.key, items: entry.value));
      }
    }

    int totalSliverItems = 0;
    for (final section in sections) {
      totalSliverItems += 1 + section.items.length; // header + items
    }

    return RefreshIndicator(
      onRefresh: () => cubit.loadAssignments(page: 1, refresh: true),
      child: CustomScrollView(
        physics: widget.embedded ? const ClampingScrollPhysics() : null,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList.builder(
              itemCount: totalSliverItems,
              itemBuilder: (context, index) {
                int offset = 0;
                for (final section in sections) {
                  if (index == offset) {
                    // Section header
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            section.type.icon,
                            size: 18,
                            color: section.type.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            section.type.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: section.type.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  offset += 1;
                  if (index < offset + section.items.length) {
                    final itemIndex = index - offset;
                    return _buildAssignmentCard(
                      cubit,
                      section.items[itemIndex],
                    );
                  }
                  offset += section.items.length;
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    InstructorAssignmentsCubit cubit,
    AssignmentModel assignment,
  ) {
    final assignmentId = _assignmentIdOf(assignment);
    return AssignmentCard(
      assignment: assignment,
      canManage: widget.canManage,
      onViewSubmissions: () => context.push(
        '/instructor/assignments/$assignmentId/submissions',
        extra: <String, dynamic>{
          'assignmentTitle': assignment.title,
          'maxScore': assignment.maxGrade,
          'assignmentDueDate': assignment.dueDate,
          'latePenaltyPercent': assignment.latePenaltyPercent,
          'isArchived':
              assignment.apiStatus == api.AssignmentStatus.archived,
        },
      ),
      onEdit: widget.canManage
          ? () async {
              final result = await context.push(
                '/instructor/assignments/create',
                extra: <String, dynamic>{
                  'assignmentId': assignmentId,
                  'assignment': assignment,
                },
              );
              if (!mounted) {
                return;
              }
              if (result == true) {
                await cubit.loadAssignments(
                  page: 1,
                  limit: 20,
                  refresh: true,
                );
              }
            }
          : null,
      onDelete: widget.canManage
          ? () => _confirmDelete(context, cubit, assignmentId, assignment.title)
          : null,
      onStatusChange: widget.canManage
          ? (status) => cubit.updateStatus(assignmentId, status)
          : null,
    );
  }

  static void _confirmDelete(
    BuildContext context,
    InstructorAssignmentsCubit cubit,
    int assignmentId,
    String title,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Assignment?'),
          content: Text(
            'Are you sure you want to delete "$title"? '
            'This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteAssignment(assignmentId);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  static int _assignmentIdOf(AssignmentModel assignment) {
    if (assignment.assignmentId > 0) {
      return assignment.assignmentId;
    }
    return int.tryParse(assignment.id) ?? 0;
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TypeSection {
  final AssignmentType type;
  final List<AssignmentModel> items;
  const _TypeSection({required this.type, required this.items});
}

class _EmptyAssignmentsState extends StatelessWidget {
  const _EmptyAssignmentsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.assignment_outlined, size: 52),
            SizedBox(height: 10),
            Text(
              'No assignments found for this course.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
