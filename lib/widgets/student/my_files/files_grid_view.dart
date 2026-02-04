import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';

class FilesGridView extends StatelessWidget {
  final bool isDark;
  final List<MyFile> files;
  final Function(MyFile) onFileTap;
  final Function(MyFile) onFileLongPress;

  const FilesGridView({
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
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          mainAxisExtent: 200,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final file = files[index];
          return _FileGridItem(
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

class _FileGridItem extends StatelessWidget {
  final MyFile file;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FileGridItem({
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
        final currentFile = state.files.where((f) => f.id == file.id).firstOrNull ?? file;

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
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                      : isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: _getFileGradient(file.type),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                        ),
                        child: Center(child: _buildFileIcon(file)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _truncateFileName(currentFile.name, 20),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    currentFile.formattedSize,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(currentFile.modifiedAt),
                                  style: TextStyle(
                                    fontSize: 10,
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
                    ),
                  ],
                ),
                // Favorite indicator
                if (currentFile.isFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                    ),
                  ),
                // Selection indicator
                if (isMultiSelect)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getFileGradient(FileType type) {
    switch (type) {
      case FileType.pdf:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      case FileType.document:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case FileType.image:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case FileType.video:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case FileType.audio:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
      case FileType.spreadsheet:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF047857)],
        );
      case FileType.presentation:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        );
      case FileType.archive:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        );
      case FileType.code:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
        );
      case FileType.other:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF64748B), Color(0xFF475569)],
        );
    }
  }

  Widget _buildFileIcon(MyFile file) {
    IconData icon;
    switch (file.type) {
      case FileType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        break;
      case FileType.document:
        icon = Icons.description_rounded;
        break;
      case FileType.image:
        icon = Icons.image_rounded;
        break;
      case FileType.video:
        icon = Icons.video_library_rounded;
        break;
      case FileType.audio:
        icon = Icons.audiotrack_rounded;
        break;
      case FileType.spreadsheet:
        icon = Icons.table_chart_rounded;
        break;
      case FileType.presentation:
        icon = Icons.slideshow_rounded;
        break;
      case FileType.archive:
        icon = Icons.folder_zip_rounded;
        break;
      case FileType.code:
        icon = Icons.code_rounded;
        break;
      case FileType.other:
        icon = Icons.insert_drive_file_rounded;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            file.extension.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
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
