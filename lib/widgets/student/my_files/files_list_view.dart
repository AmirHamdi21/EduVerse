import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';

class FilesListView extends StatelessWidget {
  final bool isDark;
  final List<MyFile> files;
  final Function(MyFile) onFileTap;
  final Function(MyFile) onFileLongPress;

  const FilesListView({
    super.key,
    required this.isDark,
    required this.files,
    required this.onFileTap,
    required this.onFileLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final file = files[index];
          return _FileListItem(
            file: file,
            isDark: isDark,
            onTap: () => onFileTap(file),
            onLongPress: () => onFileLongPress(file),
          );
        }, childCount: files.length),
      ),
    );
  }
}

class _FileListItem extends StatelessWidget {
  final MyFile file;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FileListItem({
    required this.file,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFilesCubit, MyFilesState>(
      buildWhen: (p, c) =>
          p.isMultiSelectMode != c.isMultiSelectMode ||
          p.selectedFileIds.contains(file.id) !=
              c.selectedFileIds.contains(file.id) ||
          p.files.where((f) => f.id == file.id).firstOrNull?.isFavorite !=
              c.files.where((f) => f.id == file.id).firstOrNull?.isFavorite,
      builder: (context, state) {
        final isMultiSelect = state.isMultiSelectMode;
        final isSelected = state.selectedFileIds.contains(file.id);
        final currentFile =
            state.files.where((f) => f.id == file.id).firstOrNull ?? file;

        return GestureDetector(
          onTap: () {
            if (isMultiSelect) {
              context.read<MyFilesCubit>().toggleFileSelection(file.id);
            } else {
              onTap();
            }
          },
          onLongPress: () {
            if (!isMultiSelect) {
              context.read<MyFilesCubit>().toggleMultiSelectMode();
              context.read<MyFilesCubit>().toggleFileSelection(file.id);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                      : isDark
                      ? Colors.black.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Selection checkbox
                if (isMultiSelect)
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                // File icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _getFileGradient(currentFile.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _getFileIcon(currentFile.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _truncateFileName(currentFile.name, 30),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (currentFile.isFavorite)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getFileColor(
                                currentFile.type,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              currentFile.extension.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getFileColor(currentFile.type),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentFile.formattedSize,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(currentFile.modifiedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // More options
                if (!isMultiSelect)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getFileGradient(FileType type) {
    final color = _getFileColor(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withValues(alpha: 0.8)],
    );
  }

  Color _getFileColor(FileType type) {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFEF4444);
      case FileType.document:
        return const Color(0xFF3B82F6);
      case FileType.image:
        return const Color(0xFF10B981);
      case FileType.video:
        return const Color(0xFF8B5CF6);
      case FileType.audio:
        return const Color(0xFFF59E0B);
      case FileType.spreadsheet:
        return const Color(0xFF10B981);
      case FileType.presentation:
        return const Color(0xFFF97316);
      case FileType.archive:
        return const Color(0xFF6366F1);
      case FileType.code:
        return const Color(0xFF14B8A6);
      case FileType.other:
        return const Color(0xFF64748B);
    }
  }

  IconData _getFileIcon(FileType type) {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.document:
        return Icons.description_rounded;
      case FileType.image:
        return Icons.image_rounded;
      case FileType.video:
        return Icons.video_library_rounded;
      case FileType.audio:
        return Icons.audiotrack_rounded;
      case FileType.spreadsheet:
        return Icons.table_chart_rounded;
      case FileType.presentation:
        return Icons.slideshow_rounded;
      case FileType.archive:
        return Icons.folder_zip_rounded;
      case FileType.code:
        return Icons.code_rounded;
      case FileType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _truncateFileName(String name, int maxLength) {
    if (name.length <= maxLength) return name;

    // Find the extension
    final lastDot = name.lastIndexOf('.');
    if (lastDot == -1 || lastDot == 0) {
      // No extension, just truncate
      return '${name.substring(0, maxLength - 3)}...';
    }

    final extension = name.substring(lastDot);
    final baseName = name.substring(0, lastDot);

    // Reserve space for extension and "..."
    final availableLength = maxLength - extension.length - 3;
    if (availableLength <= 0) {
      return '${name.substring(0, maxLength - 3)}...';
    }

    return '${baseName.substring(0, availableLength)}...$extension';
  }
}
