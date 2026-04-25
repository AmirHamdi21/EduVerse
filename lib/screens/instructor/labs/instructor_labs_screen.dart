import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/instructor/instructor_labs_cubit.dart';
import '../../../bloc/instructor/instructor_labs_state.dart';
import '../../../models/core/enums/lab_enums.dart' as api;
import '../../../models/labs/lab_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/labs/lab_barrel.dart';

class InstructorLabsScreen extends StatelessWidget {
  const InstructorLabsScreen({
    super.key,
    this.labService,
    this.enrollmentService,
    this.storageService,
    this.canManageLabs = true,
    this.initialCourseId,
  });

  final LabService? labService;
  final EnrollmentService? enrollmentService;
  final StorageService? storageService;
  final bool canManageLabs;
  final int? initialCourseId;

  @override
  Widget build(BuildContext context) {
    final resolvedStorage = storageService ?? StorageService();
    final coreApiClient = CoreApiClient(storageService: resolvedStorage);

    final resolvedLabService =
        labService ?? LabService(coreApiClient: coreApiClient);
    final resolvedEnrollmentService =
        enrollmentService ?? EnrollmentService(coreApiClient: coreApiClient);

    return BlocProvider<InstructorLabsCubit>(
      create: (_) => InstructorLabsCubit(
        labService: resolvedLabService,
        enrollmentService: resolvedEnrollmentService,
      )..initialize(preferredCourseId: initialCourseId),
      child: _InstructorLabsView(
        canManageLabs: canManageLabs,
        storageService: resolvedStorage,
      ),
    );
  }
}

class _InstructorLabsView extends StatefulWidget {
  const _InstructorLabsView({
    required this.canManageLabs,
    required this.storageService,
  });

  final bool canManageLabs;
  final StorageService storageService;

  @override
  State<_InstructorLabsView> createState() => _InstructorLabsViewState();
}

class _InstructorLabsViewState extends State<_InstructorLabsView> {
  final TextEditingController _searchController = TextEditingController();

  bool _resolvedCanManage = false;

  @override
  void initState() {
    super.initState();
    _resolveRoleAccess();
  }

  @override
  void didUpdateWidget(covariant _InstructorLabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storageService != widget.storageService ||
        oldWidget.canManageLabs != widget.canManageLabs) {
      _resolveRoleAccess();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await widget.storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (!mounted) {
        return;
      }

      setState(() {
        if (roleNames.isEmpty) {
          _resolvedCanManage = widget.canManageLabs;
        } else {
          _resolvedCanManage = roleNames.contains('instructor');
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resolvedCanManage = widget.canManageLabs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstructorLabsCubit, InstructorLabsState>(
      listener: (context, state) {
        if (state is InstructorLabsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<InstructorLabsCubit>();

        if (state is InstructorLabsLoading || state is InstructorLabsInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lab Management')),
            body: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 116,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        if (state is InstructorLabsError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lab Management')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => cubit.loadLabs(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final loaded = state as InstructorLabsLoaded;

        return Scaffold(
          appBar: AppBar(title: const Text('Lab Management')),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: DropdownButtonFormField<int>(
                  key: ValueKey<int?>(loaded.selectedCourseId),
                  initialValue: loaded.selectedCourseId,
                  decoration: const InputDecoration(
                    labelText: 'Teaching course',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: loaded.teachingCourses
                      .map(
                        (course) => DropdownMenuItem<int>(
                          value: course.courseId,
                          child: Text(
                            '${course.course.code} - ${course.course.name}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) => cubit.selectCourse(value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search labs',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => cubit.filterLabs(
                    searchQuery: value,
                    status: loaded.selectedStatus,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _StatusFilterChip(
                      label: 'All',
                      selected: loaded.selectedStatus == 'all',
                      onTap: () => cubit.filterLabs(status: 'all'),
                    ),
                    _StatusFilterChip(
                      label: 'Draft',
                      selected: loaded.selectedStatus == 'draft',
                      onTap: () => cubit.filterLabs(status: 'draft'),
                    ),
                    _StatusFilterChip(
                      label: 'Published',
                      selected: loaded.selectedStatus == 'published',
                      onTap: () => cubit.filterLabs(status: 'published'),
                    ),
                    _StatusFilterChip(
                      label: 'Closed',
                      selected: loaded.selectedStatus == 'closed',
                      onTap: () => cubit.filterLabs(status: 'closed'),
                    ),
                    _StatusFilterChip(
                      label: 'Archived',
                      selected: loaded.selectedStatus == 'archived',
                      onTap: () => cubit.filterLabs(status: 'archived'),
                    ),
                  ],
                ),
              ),
              if (_resolvedCanManage)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openCreateOrEditSheet(context, loaded),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create New Lab'),
                    ),
                  ),
                ),
              Expanded(
                child: loaded.filteredLabs.isEmpty
                    ? _EmptyLabsState(
                        canManage: _resolvedCanManage,
                        onCreate: _resolvedCanManage
                            ? () => _openCreateOrEditSheet(context, loaded)
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () => cubit.loadLabs(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: <Widget>[
                            for (final lab in loaded.filteredLabs)
                              LabCard(
                                lab: lab,
                                canManage: _resolvedCanManage,
                                onViewSubmissions: () async {
                                  await context.push(
                                    '/instructor/labs/${lab.id}?tab=submissions',
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  _searchController.clear();
                                  cubit.clearFilters();
                                },
                                onEdit: _resolvedCanManage
                                    ? () => _openCreateOrEditSheet(
                                        context,
                                        loaded,
                                        existingLab: lab,
                                      )
                                    : null,
                                onDelete: _resolvedCanManage
                                    ? () => _confirmDelete(context, lab)
                                    : null,
                                onStatusChange: _resolvedCanManage
                                    ? (status) async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        final message = await cubit.updateStatus(
                                          lab.id.isNotEmpty
                                              ? lab.id
                                              : lab.labId.toString(),
                                          status,
                                        );

                                        if (!mounted) {
                                          return;
                                        }

                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              message ??
                                                  _labStatusSuccessMessage(status),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            if (loaded.hasMorePages)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: OutlinedButton(
                                  onPressed: loaded.isLoadingMore
                                      ? null
                                      : () => cubit.loadMore(),
                                  child: loaded.isLoadingMore
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Load More'),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCreateOrEditSheet(
    BuildContext context,
    InstructorLabsLoaded state, {
    LabModel? existingLab,
  }) async {
    final cubit = context.read<InstructorLabsCubit>();
    final isEdit = existingLab != null;
    final messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        var submitting = false;

        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.86,
                child: LabCreateForm(
                  courses: state.teachingCourses,
                  existingLab: existingLab,
                  submitting: submitting,
                  onCancel: () => Navigator.of(sheetContext).pop(),
                  onSubmit: (payload) async {
                    setModalState(() => submitting = true);

                    final message = isEdit
                        ? await cubit.updateLab(
                            existingLab.id.isNotEmpty
                                ? existingLab.id
                                : existingLab.labId.toString(),
                            payload,
                          )
                        : await cubit.createLab(payload);

                    if (!mounted || !sheetContext.mounted) {
                      return;
                    }

                    setModalState(() => submitting = false);

                    if (message != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(message),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    Navigator.of(sheetContext).pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? _labSavedMessage(payload['status']?.toString())
                              : _labSavedMessage(payload['status']?.toString()),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _labSavedMessage(String? rawStatus) {
    final status = api.LabStatus.fromString(rawStatus ?? '');
    if (status == api.LabStatus.published) {
      return 'Lab saved as published. Enrolled students can now receive lab notifications.';
    }
    return 'Lab saved as draft. Publish it to notify enrolled students.';
  }

  String _labStatusSuccessMessage(api.LabStatus status) {
    switch (status) {
      case api.LabStatus.published:
        return 'Lab published. Enrolled students can now receive lab notifications.';
      case api.LabStatus.closed:
        return 'Lab closed successfully.';
      case api.LabStatus.archived:
        return 'Lab archived successfully.';
      case api.LabStatus.draft:
        return 'Lab moved to draft.';
      case api.LabStatus.unknown:
        return 'Lab status updated.';
    }
  }

  Future<void> _confirmDelete(BuildContext context, LabModel lab) async {
    final cubit = context.read<InstructorLabsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Lab?'),
          content: Text('Delete ${lab.title}? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final message = await cubit.deleteLab(
      lab.id.isNotEmpty ? lab.id : lab.labId.toString(),
    );

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message ?? 'Lab deleted successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _EmptyLabsState extends StatelessWidget {
  const _EmptyLabsState({required this.canManage, this.onCreate});

  final bool canManage;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.science_outlined, size: 52),
            const SizedBox(height: 10),
            const Text('No labs found', textAlign: TextAlign.center),
            if (canManage && onCreate != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Lab'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
