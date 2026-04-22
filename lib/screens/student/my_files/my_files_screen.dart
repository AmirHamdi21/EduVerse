import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/student/my_files/files_app_bar.dart';
import '../../../widgets/student/my_files/files_grid_view.dart';
import '../../../widgets/student/my_files/files_list_view.dart';
import '../../../widgets/student/my_files/storage_overview_card.dart';
import '../../../widgets/student/my_files/filter_chips_bar.dart';
import '../../../widgets/student/my_files/upload_progress_overlay.dart';
import '../../../widgets/student/my_files/file_details_sheet.dart';
import '../../../widgets/student/my_files/empty_files_view.dart';
import '../../../widgets/student/my_files/confirm_delete_file.dart';

class MyFilesScreen extends StatefulWidget {
  const MyFilesScreen({super.key});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen>
    with SingleTickerProviderStateMixin {
  late MyFilesCubit _filesCubit;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _filesCubit = MyFilesCubit();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _filesCubit.close();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _filesCubit,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previous, current) => previous.isDark != current.isDark,
        builder: (context, themeState) {
          final isDark = themeState.isDark;
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    FilesAppBar(isDark: isDark),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          StorageOverviewCard(isDark: isDark),
                          FilterChipsBar(isDark: isDark),
                        ],
                      ),
                    ),
                    _buildFilesContent(isDark, l10n),
                  ],
                ),
                const UploadProgressOverlay(),
              ],
            ),
            floatingActionButton: _buildFAB(isDark, l10n),
          );
        },
      ),
    );
  }

  Widget _buildFilesContent(bool isDark, AppLocalizations l10n) {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (previous, current) =>
          previous.filteredFiles != current.filteredFiles ||
          previous.viewMode != current.viewMode ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        if (state.isLoading) {
          return SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: isDark ? Colors.white : const Color(0xFF3B82F6),
              ),
            ),
          );
        }

        if (state.filteredFiles.isEmpty) {
          return SliverFillRemaining(
            child: EmptyFilesView(
              isDark: isDark,
              onUpload: () => _filesCubit.uploadFiles(),
            ),
          );
        }

        if (state.viewMode == ViewMode.grid) {
          return FilesGridView(
            isDark: isDark,
            files: state.filteredFiles,
            onFileTap: (file) => _showFileDetails(context, file, isDark),
            onFileLongPress: (file) => _filesCubit.toggleMultiSelectMode(),
          );
        }

        return FilesListView(
          isDark: isDark,
          files: state.filteredFiles,
          onFileTap: (file) => _showFileDetails(context, file, isDark),
          onFileLongPress: (file) => _filesCubit.toggleMultiSelectMode(),
        );
      },
    );
  }

  void _showFileDetails(BuildContext context, MyFile file, bool isDark) {
    _filesCubit.selectFile(file);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: _filesCubit,
        child: FileDetailsSheet(file: file, isDark: isDark),
      ),
    ).then((_) => _filesCubit.clearSelectedFile());
  }

  Widget _buildFAB(bool isDark, AppLocalizations l10n) {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (previous, current) =>
          previous.isMultiSelectMode != current.isMultiSelectMode ||
          previous.selectedFileIds != current.selectedFileIds,
      builder: (context, state) {
        if (state.isMultiSelectMode) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'cancel',
                onPressed: () => _filesCubit.clearSelection(),
                backgroundColor: const Color(0xFF64748B),
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              if (state.selectedFileIds.isNotEmpty)
                FloatingActionButton.extended(
                  heroTag: 'delete',
                  onPressed: () => _showDeleteConfirmation(context, l10n),
                  backgroundColor: const Color(0xFFEF4444),
                  icon: const Icon(Icons.delete_rounded, color: Colors.white),
                  label: Text(
                    '${state.selectedFileIds.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          );
        }

        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _filesCubit.uploadFiles(),
            backgroundColor: const Color(0xFF3B82F6),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              l10n.upload,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final selectedCount = _filesCubit.state.selectedFileIds.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDeleteFileDialog(
        isDark: isDark,
        fileCount: selectedCount,
        onCancel: () => Navigator.pop(ctx),
        onDelete: () {
          Navigator.pop(ctx);
          _filesCubit.deleteSelectedFiles();
        },
      ),
    );
  }
}
