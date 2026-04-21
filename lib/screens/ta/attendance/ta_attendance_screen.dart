import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/attendance/ta_attendance_cubit.dart';
import '../../../bloc/attendance/ta_attendance_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../services/api/attendance_service.dart';
import '../../../services/api/enrollment_service.dart';
import '../../../widgets/shared/attendance/status_toggle_widget.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TAAttendanceScreen extends StatelessWidget {
  const TAAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TAAttendanceCubit>(
      create: (context) => TAAttendanceCubit(
        attendanceService: context.read<AttendanceService>(),
        enrollmentService: context.read<EnrollmentService>(),
      )..loadAvailableLabs(),
      child: const _TAAttendanceView(),
    );
  }
}

class _TAAttendanceView extends StatefulWidget {
  const _TAAttendanceView();

  @override
  State<_TAAttendanceView> createState() => _TAAttendanceViewState();
}

class _TAAttendanceViewState extends State<_TAAttendanceView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/attendance'),
          body: SafeArea(
            child: BlocConsumer<TAAttendanceCubit, TAAttendanceState>(
              listener: (context, state) {
                if (state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: TAColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    _buildHeader(isDark),
                    _buildTabs(isDark, state),
                    Expanded(child: _buildBody(isDark, state)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        border: Border(bottom: BorderSide(color: TAColors.borderColor(isDark))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: TAColors.textPrimaryColor(isDark)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'TA Attendance',
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.read<TAAttendanceCubit>().loadHistory(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark, TAAttendanceState state) {
    final cubit = context.read<TAAttendanceCubit>();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              isDark: isDark,
              active: state.view == TAAttendanceView.upload,
              label: 'Upload Photo',
              onTap: cubit.resetToUpload,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _tabButton(
              isDark: isDark,
              active: state.view == TAAttendanceView.results,
              label: 'Results',
              onTap: state.detectedStudents.isEmpty ? null : cubit.showResults,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _tabButton(
              isDark: isDark,
              active: state.view == TAAttendanceView.history,
              label: 'History (${state.pastSessions.length})',
              onTap: () {
                cubit.loadHistory();
                cubit.showHistory();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required bool isDark,
    required bool active,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? TAColors.primary : TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TAColors.borderColor(isDark)),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : TAColors.textPrimaryColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, TAAttendanceState state) {
    switch (state.view) {
      case TAAttendanceView.upload:
        return _buildUploadView(isDark, state);
      case TAAttendanceView.processing:
        return _buildProcessingView(isDark, state);
      case TAAttendanceView.results:
        return _buildResultsView(isDark, state);
      case TAAttendanceView.history:
        return _buildHistoryView(isDark, state);
    }
  }

  Widget _buildUploadView(bool isDark, TAAttendanceState state) {
    final cubit = context.read<TAAttendanceCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<int>(
          value: state.selectedSectionId,
          decoration: const InputDecoration(
            labelText: 'Select Lab Section',
            border: OutlineInputBorder(),
          ),
          items: state.availableLabs
              .map(
                (lab) => DropdownMenuItem<int>(
                  value: lab.sectionId,
                  child: Text(
                    '${lab.course.courseCode} - ${lab.course.name} (${lab.section.sectionNumber})',
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            final selected = state.availableLabs
                .where((e) => e.sectionId == value)
                .toList()
                .firstOrNull;
            cubit.selectLab(selected);
          },
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              allowMultiple: false,
            );
            final path = result?.files.single.path;
            if (path != null && path.isNotEmpty) {
              cubit.selectFile(File(path));
            }
          },
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TAColors.borderColor(isDark),
                width: 1.2,
              ),
            ),
            child: state.selectedFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to choose class photo',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(state.selectedFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: state.isLoading ? null : cubit.processAttendance,
          icon: const Icon(Icons.psychology_rounded),
          label: const Text('Process with AI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TAColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView(bool isDark, TAAttendanceState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.psychology_rounded,
            size: 54,
            color: TAColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Processing attendance...',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(value: state.processingProgress),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(bool isDark, TAAttendanceState state) {
    final cubit = context.read<TAAttendanceCubit>();
    final present = state.detectedStudents
        .where((s) => s.status == 'present')
        .length;
    final absent = state.detectedStudents
        .where((s) => s.status == 'absent')
        .length;
    final uncertain = state.detectedStudents
        .where((s) => (s.confidence ?? 1) < 0.6)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _stat('Detected', '${state.totalDetected}'),
            const SizedBox(width: 8),
            _stat('Present', '$present'),
            const SizedBox(width: 8),
            _stat('Absent', '$absent'),
            const SizedBox(width: 8),
            _stat('Uncertain', '$uncertain'),
          ],
        ),
        const SizedBox(height: 12),
        ...state.detectedStudents.map(
          (student) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TAColors.borderColor(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (student.confidence != null)
                      Text(
                        'AI ${(student.confidence! * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                StatusToggleWidget(
                  currentStatus: student.status,
                  isDark: isDark,
                  onChanged: (status) =>
                      cubit.overrideStatus(student.userId, status),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: cubit.saveResults,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Attendance'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final csv = cubit.exportCsv();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('CSV generated (${csv.length} chars)'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: TAColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryView(bool isDark, TAAttendanceState state) {
    final cubit = context.read<TAAttendanceCubit>();

    if (state.pastSessions.isEmpty) {
      return Center(
        child: Text(
          'No completed sessions yet.',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.pastSessions.length,
      itemBuilder: (context, index) {
        final session = state.pastSessions[index];
        final total =
            session.presentCount +
            session.absentCount +
            session.lateCount +
            session.excusedCount;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TAColors.borderColor(isDark)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.sessionDate} • ${session.sessionType ?? 'lab'}',
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Present ${session.presentCount}/$total',
                      style: TextStyle(
                        color: TAColors.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => cubit.viewHistoryDetails(session),
                child: const Text('View'),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension _ListExt<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
