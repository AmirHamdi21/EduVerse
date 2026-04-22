import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/instructor/lab_detail_cubit.dart';
import '../../../bloc/instructor/lab_detail_state.dart';
import '../../../models/labs/lab_submission_model.dart';
import '../../../services/api/core_api_client.dart';
import '../../../services/api/lab_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/instructor/labs/lab_barrel.dart';

class LabDetailScreen extends StatelessWidget {
  const LabDetailScreen({
    super.key,
    required this.labId,
    this.initialTab = 0,
    this.labService,
    this.storageService,
  });

  final String labId;
  final int initialTab;
  final LabService? labService;
  final StorageService? storageService;

  @override
  Widget build(BuildContext context) {
    final resolvedStorage = storageService ?? StorageService();
    final coreApiClient = CoreApiClient(storageService: resolvedStorage);
    final resolvedLabService =
        labService ?? LabService(coreApiClient: coreApiClient);

    return BlocProvider<LabDetailCubit>(
      create: (_) {
        final cubit = LabDetailCubit(labService: resolvedLabService);
        cubit.loadLabDetail(labId).then((_) {
          cubit.loadInstructions(labId);
          cubit.loadSubmissions(labId);
          cubit.loadAttendance(labId);
        });
        return cubit;
      },
      child: _LabDetailView(
        labId: labId,
        initialTab: initialTab,
        storageService: resolvedStorage,
      ),
    );
  }
}

class _LabDetailView extends StatefulWidget {
  const _LabDetailView({
    required this.labId,
    required this.initialTab,
    required this.storageService,
  });

  final String labId;
  final int initialTab;
  final StorageService storageService;

  @override
  State<_LabDetailView> createState() => _LabDetailViewState();
}

class _LabDetailViewState extends State<_LabDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _roleCheckDone = false;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _resolveRoleAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        _roleCheckDone = true;
        _canManage = roleNames.isEmpty || roleNames.contains('instructor');
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _roleCheckDone = true;
        _canManage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LabDetailCubit, LabDetailState>(
      listener: (context, state) {
        if (state is! LabDetailLoaded) {
          return;
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state.message != null && state.message!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        context.read<LabDetailCubit>().clearMessages();
      },
      builder: (context, state) {
        if (state is LabDetailInitial || state is LabDetailLoading) {
          final title = state is LabDetailLoading && state.cachedLab != null
              ? state.cachedLab!.title
              : 'Lab Detail';

          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is LabDetailError) {
          if (state.statusCode == 404) {
            return Scaffold(
              appBar: AppBar(title: const Text('Lab Detail')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.search_off_rounded, size: 48),
                      const SizedBox(height: 10),
                      const Text('Lab not found'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Lab Detail')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 10),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<LabDetailCubit>()
                          .loadLabDetail(widget.labId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final loaded = state as LabDetailLoaded;

        return Scaffold(
          appBar: AppBar(
            title: Text(loaded.lab.title),
            bottom: TabBar(
              controller: _tabController,
              tabs: const <Tab>[
                Tab(text: 'Instructions'),
                Tab(text: 'Submissions'),
                Tab(text: 'Attendance'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              loaded.instructions == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: InstructionManager(
                        labId: widget.labId,
                        instructions: loaded.instructions!,
                        canManage: _roleCheckDone && _canManage,
                        isUpdating: state is LabInstructionUpdating,
                      ),
                    ),
              loaded.submissions == null
                  ? const Center(child: CircularProgressIndicator())
                  : SubmissionsList(
                      submissions: loaded.submissions!,
                      canManage: _roleCheckDone && _canManage,
                      onTapSubmission: (submission) =>
                          _openGradingPanel(context, loaded, submission),
                    ),
              loaded.attendance == null
                  ? const Center(child: CircularProgressIndicator())
                  : AttendanceSheet(
                      records: loaded.attendance!,
                      canManage: _roleCheckDone && _canManage,
                      onMarkAttendance: (userId, status) {
                        return context.read<LabDetailCubit>().markAttendance(
                          widget.labId,
                          <AttendanceData>[
                            AttendanceData(
                              userId: userId,
                              attendanceStatus: status,
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openGradingPanel(
    BuildContext context,
    LabDetailLoaded loaded,
    LabSubmissionModel submission,
  ) async {
    if (!_canManage) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<LabDetailCubit>(),
          child: BlocBuilder<LabDetailCubit, LabDetailState>(
            builder: (context, state) {
              final detailState = state is LabDetailLoaded ? state : loaded;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: LabGradingPanel(
                    submission: submission,
                    maxScore: detailState.lab.maxScore,
                    dueDate: detailState.lab.dueDate,
                    isSaving: detailState.isSubmittingGrade,
                    errorMessage: detailState.errorMessage,
                    onSave:
                        (
                          finalScore,
                          feedback,
                          status,
                          latePenaltyPercent,
                        ) async {
                          final cubit = context.read<LabDetailCubit>();

                          await cubit.gradeSubmission(
                            widget.labId,
                            submission.id.toString(),
                            finalScore,
                            feedback: feedback,
                            status: status,
                            latePenaltyPercent: latePenaltyPercent,
                          );

                          if (!mounted || !sheetContext.mounted) {
                            return;
                          }

                          final nextState = cubit.state;
                          if (nextState is LabDetailLoaded &&
                              (nextState.errorMessage == null ||
                                  nextState.errorMessage!.isEmpty)) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
