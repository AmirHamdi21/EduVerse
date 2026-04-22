import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'my_files_state.dart';

class MyFilesCubit extends Cubit<MyFilesState> {
  static const String _filesKey = 'my_files_data';
  static const String _foldersKey = 'my_folders_data';
  final _uuid = const Uuid();

  MyFilesCubit() : super(const MyFilesState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _loadFiles();
      await _calculateStorageStats();
      _applyFiltersAndSort();
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();

    // Load files
    final filesJson = prefs.getString(_filesKey);
    List<MyFile> files = [];
    if (filesJson != null) {
      final List<dynamic> decoded = jsonDecode(filesJson);
      files = decoded.map((e) => MyFile.fromJson(e)).toList();

      // Verify files still exist
      files = await _verifyFilesExist(files);
    }

    // Load folders
    final foldersJson = prefs.getString(_foldersKey);
    List<MyFolder> folders = [];
    if (foldersJson != null) {
      final List<dynamic> decoded = jsonDecode(foldersJson);
      folders = decoded.map((e) => MyFolder.fromJson(e)).toList();
    }

    emit(state.copyWith(files: files, folders: folders, isLoading: false));
  }

  Future<List<MyFile>> _verifyFilesExist(List<MyFile> files) async {
    final validFiles = <MyFile>[];
    for (var file in files) {
      if (await File(file.path).exists()) {
        validFiles.add(file);
      }
    }
    return validFiles;
  }

  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = jsonEncode(state.files.map((e) => e.toJson()).toList());
    await prefs.setString(_filesKey, filesJson);
  }

  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final foldersJson = jsonEncode(
      state.folders.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_foldersKey, foldersJson);
  }

  Future<void> _calculateStorageStats() async {
    int totalSize = 0;
    final typeDistribution = <FileType, int>{};

    for (var file in state.files) {
      totalSize += file.size;
      typeDistribution[file.type] =
          (typeDistribution[file.type] ?? 0) + file.size;
    }

    emit(
      state.copyWith(
        storageStats: StorageStats(
          usedSpace: totalSize,
          totalSpace: 5 * 1024 * 1024 * 1024, // 5GB
          typeDistribution: typeDistribution,
        ),
      ),
    );
  }

  void _applyFiltersAndSort() {
    var filtered = List<MyFile>.from(state.files);

    // Apply folder filter
    if (state.currentFolderId != null) {
      filtered = filtered
          .where((f) => f.folderId == state.currentFolderId)
          .toList();
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
    }

    // Apply type filter
    switch (state.filterOption) {
      case FileFilterOption.all:
        break;
      case FileFilterOption.pdf:
        filtered = filtered.where((f) => f.type == FileType.pdf).toList();
        break;
      case FileFilterOption.documents:
        filtered = filtered
            .where(
              (f) =>
                  f.type == FileType.document ||
                  f.type == FileType.pdf ||
                  f.type == FileType.spreadsheet ||
                  f.type == FileType.presentation,
            )
            .toList();
        break;
      case FileFilterOption.images:
        filtered = filtered.where((f) => f.type == FileType.image).toList();
        break;
      case FileFilterOption.videos:
        filtered = filtered.where((f) => f.type == FileType.video).toList();
        break;
      case FileFilterOption.audio:
        filtered = filtered.where((f) => f.type == FileType.audio).toList();
        break;
      case FileFilterOption.recent:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered
            .where((f) => f.modifiedAt.isAfter(sevenDaysAgo))
            .toList();
        break;
      case FileFilterOption.favorites:
        filtered = filtered.where((f) => f.isFavorite).toList();
        break;
    }

    // Apply sort
    switch (state.sortOption) {
      case FileSortOption.nameAsc:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case FileSortOption.nameDesc:
        filtered.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case FileSortOption.dateNewest:
        filtered.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case FileSortOption.dateOldest:
        filtered.sort((a, b) => a.modifiedAt.compareTo(b.modifiedAt));
        break;
      case FileSortOption.sizeSmallest:
        filtered.sort((a, b) => a.size.compareTo(b.size));
        break;
      case FileSortOption.sizeLargest:
        filtered.sort((a, b) => b.size.compareTo(a.size));
        break;
      case FileSortOption.typeAsc:
        filtered.sort((a, b) => a.type.index.compareTo(b.type.index));
        break;
    }

    emit(state.copyWith(filteredFiles: filtered));
  }

  void setFilter(FileFilterOption option) {
    emit(state.copyWith(filterOption: option));
    _applyFiltersAndSort();
  }

  void setSort(FileSortOption option) {
    emit(state.copyWith(sortOption: option));
    _applyFiltersAndSort();
  }

  void setViewMode(ViewMode mode) {
    emit(state.copyWith(viewMode: mode));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFiltersAndSort();
  }

  void selectFile(MyFile file) {
    emit(state.copyWith(selectedFile: file));
  }

  void clearSelectedFile() {
    emit(state.copyWith(clearSelectedFile: true));
  }

  void toggleMultiSelectMode() {
    emit(
      state.copyWith(
        isMultiSelectMode: !state.isMultiSelectMode,
        selectedFileIds: {},
      ),
    );
  }

  void toggleFileSelection(String fileId) {
    final newSelection = Set<String>.from(state.selectedFileIds);
    if (newSelection.contains(fileId)) {
      newSelection.remove(fileId);
    } else {
      newSelection.add(fileId);
    }
    emit(state.copyWith(selectedFileIds: newSelection));
  }

  void selectAllFiles() {
    final allIds = state.filteredFiles.map((f) => f.id).toSet();
    emit(state.copyWith(selectedFileIds: allIds));
  }

  void clearSelection() {
    emit(state.copyWith(selectedFileIds: {}, isMultiSelectMode: false));
  }

  void navigateToFolder(String? folderId) {
    if (folderId == null) {
      emit(state.copyWith(clearCurrentFolder: true));
    } else {
      emit(state.copyWith(currentFolderId: folderId));
    }
    _applyFiltersAndSort();
  }

  Future<void> uploadFiles() async {
    try {
      emit(
        state.copyWith(
          uploadProgress: const UploadProgress(
            fileName: '',
            status: UploadStatus.picking,
          ),
        ),
      );

      final result = await picker.FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: picker.FileType.any,
      );

      if (result == null || result.files.isEmpty) {
        emit(state.copyWith(clearUploadProgress: true));
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${appDir.path}/my_files');
      if (!await filesDir.exists()) {
        await filesDir.create(recursive: true);
      }

      final newFiles = <MyFile>[];
      final totalFiles = result.files.length;

      for (int i = 0; i < result.files.length; i++) {
        final platformFile = result.files[i];
        if (platformFile.path == null) continue;

        emit(
          state.copyWith(
            uploadProgress: UploadProgress(
              fileName: platformFile.name,
              progress: i / totalFiles,
              status: UploadStatus.uploading,
            ),
          ),
        );

        final sourceFile = File(platformFile.path!);
        final targetPath =
            '${filesDir.path}/${_uuid.v4()}_${platformFile.name}';

        // Simulate upload progress
        await _copyFileWithProgress(sourceFile, targetPath, (progress) {
          emit(
            state.copyWith(
              uploadProgress: UploadProgress(
                fileName: platformFile.name,
                progress: (i + progress) / totalFiles,
                status: UploadStatus.uploading,
              ),
            ),
          );
        });

        final extension = platformFile.name.split('.').last;
        final fileType = MyFile.getTypeFromExtension(extension);

        final newFile = MyFile(
          id: _uuid.v4(),
          name: platformFile.name,
          path: targetPath,
          type: fileType,
          size: platformFile.size,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
          folderId: state.currentFolderId,
          mimeType: _getMimeType(extension),
        );

        newFiles.add(newFile);
      }

      final updatedFiles = [...state.files, ...newFiles];
      emit(
        state.copyWith(
          files: updatedFiles,
          uploadProgress: UploadProgress(
            fileName: '${newFiles.length} files',
            progress: 1.0,
            status: UploadStatus.completed,
          ),
        ),
      );

      await _saveFiles();
      await _calculateStorageStats();
      _applyFiltersAndSort();

      // Clear upload progress after delay
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(clearUploadProgress: true));
    } catch (e) {
      emit(
        state.copyWith(
          uploadProgress: UploadProgress(
            fileName: '',
            status: UploadStatus.failed,
            errorMessage: e.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _copyFileWithProgress(
    File source,
    String targetPath,
    void Function(double) onProgress,
  ) async {
    final target = File(targetPath);
    final sourceSize = await source.length();

    if (sourceSize < 1024 * 1024) {
      // Small files - just copy
      await source.copy(targetPath);
      onProgress(1.0);
      return;
    }

    // Large files - copy with progress
    final input = source.openRead();
    final output = target.openWrite();

    int bytesWritten = 0;
    await for (var chunk in input) {
      output.add(chunk);
      bytesWritten += chunk.length;
      onProgress(bytesWritten / sourceSize);
    }

    await output.close();
  }

  String? _getMimeType(String extension) {
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'wav': 'audio/wav',
      'txt': 'text/plain',
      'json': 'application/json',
      'zip': 'application/zip',
    };
    return mimeTypes[extension.toLowerCase()];
  }

  Future<void> deleteFile(String fileId) async {
    final file = state.files.firstWhere((f) => f.id == fileId);

    try {
      final sourceFile = File(file.path);
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }
    } catch (_) {}

    final updatedFiles = state.files.where((f) => f.id != fileId).toList();
    emit(state.copyWith(files: updatedFiles, clearSelectedFile: true));
    await _saveFiles();
    await _calculateStorageStats();
    _applyFiltersAndSort();
  }

  Future<void> deleteSelectedFiles() async {
    for (var fileId in state.selectedFileIds) {
      final file = state.files.firstWhere((f) => f.id == fileId);
      try {
        final sourceFile = File(file.path);
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }
      } catch (_) {}
    }

    final updatedFiles = state.files
        .where((f) => !state.selectedFileIds.contains(f.id))
        .toList();
    emit(
      state.copyWith(
        files: updatedFiles,
        selectedFileIds: {},
        isMultiSelectMode: false,
      ),
    );
    await _saveFiles();
    await _calculateStorageStats();
    _applyFiltersAndSort();
  }

  Future<void> toggleFavorite(String fileId) async {
    final updatedFiles = state.files.map((f) {
      if (f.id == fileId) {
        return f.copyWith(isFavorite: !f.isFavorite);
      }
      return f;
    }).toList();

    emit(state.copyWith(files: updatedFiles));
    await _saveFiles();
    _applyFiltersAndSort();
  }

  Future<void> renameFile(String fileId, String newName) async {
    final updatedFiles = state.files.map((f) {
      if (f.id == fileId) {
        return f.copyWith(name: newName, modifiedAt: DateTime.now());
      }
      return f;
    }).toList();

    emit(state.copyWith(files: updatedFiles));
    await _saveFiles();
    _applyFiltersAndSort();
  }

  Future<void> createFolder(String name) async {
    final newFolder = MyFolder(
      id: _uuid.v4(),
      name: name,
      parentId: state.currentFolderId,
      createdAt: DateTime.now(),
    );

    final updatedFolders = [...state.folders, newFolder];
    emit(state.copyWith(folders: updatedFolders));
    await _saveFolders();
  }

  Future<void> deleteFolder(String folderId) async {
    // Delete all files in folder
    final filesToDelete = state.files
        .where((f) => f.folderId == folderId)
        .toList();
    for (var file in filesToDelete) {
      try {
        final sourceFile = File(file.path);
        if (await sourceFile.exists()) {
          await sourceFile.delete();
        }
      } catch (_) {}
    }

    final updatedFiles = state.files
        .where((f) => f.folderId != folderId)
        .toList();
    final updatedFolders = state.folders
        .where((f) => f.id != folderId)
        .toList();

    emit(state.copyWith(files: updatedFiles, folders: updatedFolders));
    await _saveFiles();
    await _saveFolders();
    await _calculateStorageStats();
    _applyFiltersAndSort();
  }

  Future<void> moveFilesToFolder(List<String> fileIds, String? folderId) async {
    final updatedFiles = state.files.map((f) {
      if (fileIds.contains(f.id)) {
        return f.copyWith(folderId: folderId);
      }
      return f;
    }).toList();

    emit(
      state.copyWith(
        files: updatedFiles,
        selectedFileIds: {},
        isMultiSelectMode: false,
      ),
    );
    await _saveFiles();
    _applyFiltersAndSort();
  }

  void refresh() {
    _initialize();
  }
}
