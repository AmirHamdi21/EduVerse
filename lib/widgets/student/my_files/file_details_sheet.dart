import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import '../../../bloc/my_files/my_files_cubit.dart';
import '../../../bloc/my_files/my_files_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class FileDetailsSheet extends StatelessWidget {
  final MyFile file;
  final bool isDark;

  const FileDetailsSheet({
    super.key,
    required this.file,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // File preview
                _buildFilePreview(),
                const SizedBox(height: 20),
                // File name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    file.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // File size and type
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getFileColor(file.type).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        file.extension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getFileColor(file.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      file.formattedSize,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action buttons
                _buildActionButtons(context, l10n),
                const SizedBox(height: 24),
                // File details
                _buildFileDetails(l10n),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getFileColor(file.type),
            _getFileColor(file.type).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getFileColor(file.type).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: file.type == FileType.image
          ? _buildImagePreview()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFileIcon(file.type),
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    file.extension.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.file(
        File(file.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  file.extension.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.open_in_new_rounded,
              label: l10n.open,
              color: const Color(0xFF3B82F6),
              onTap: () => _openFile(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<MyFilesCubit, MyFilesState>(
              buildWhen: (p, c) {
                final pFile = p.files.where((f) => f.id == file.id).firstOrNull;
                final cFile = c.files.where((f) => f.id == file.id).firstOrNull;
                return pFile?.isFavorite != cFile?.isFavorite;
              },
              builder: (context, state) {
                final currentFile = state.files.where((f) => f.id == file.id).firstOrNull ?? file;
                return _buildActionButton(
                  context,
                  icon: currentFile.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  label: currentFile.isFavorite ? l10n.unfavorite : l10n.favorite,
                  color: const Color(0xFFF59E0B),
                  onTap: () =>
                      context.read<MyFilesCubit>().toggleFavorite(file.id),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.delete_rounded,
              label: l10n.delete,
              color: const Color(0xFFEF4444),
              onTap: () => _showDeleteConfirmation(context, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileDetails(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.fileDetails,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(l10n.fileType, _getFileTypeName(file.type, l10n)),
            _buildDetailRow(l10n.size, file.formattedSize),
            _buildDetailRow(l10n.created, _formatFullDate(file.createdAt)),
            _buildDetailRow(l10n.modified, _formatFullDate(file.modifiedAt)),
            _buildDetailRow(l10n.location, file.path, isPath: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: isPath ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFile(BuildContext context) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteFile,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          '${l10n.deleteFileConfirmation} "${file.name}"?',
          style: TextStyle(
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<MyFilesCubit>().deleteFile(file.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
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

  String _getFileTypeName(FileType type, AppLocalizations l10n) {
    switch (type) {
      case FileType.pdf:
        return 'PDF Document';
      case FileType.document:
        return l10n.document;
      case FileType.image:
        return l10n.image;
      case FileType.video:
        return l10n.video;
      case FileType.audio:
        return l10n.audioFile;
      case FileType.spreadsheet:
        return l10n.spreadsheet;
      case FileType.presentation:
        return l10n.presentation;
      case FileType.archive:
        return l10n.archive;
      case FileType.code:
        return l10n.codeFile;
      case FileType.other:
        return l10n.file;
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
