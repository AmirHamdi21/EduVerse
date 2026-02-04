# My Files Feature Documentation

## Overview

The My Files feature provides students with a comprehensive file management system. Users can upload, organize, view, and manage their files locally. The feature supports various file types, favorites, multi-select operations, and provides storage statistics.

## Architecture

### Directory Structure

```
lib/
├── bloc/
│   └── my_files/
│       ├── my_files_cubit.dart    # State management & business logic
│       └── my_files_state.dart    # State models, enums, and state class
├── screens/
│   └── student/
│       └── my_files/
│           └── my_files_screen.dart   # Main screen
└── widgets/
    └── student/
        └── my_files/
            ├── files_app_bar.dart           # App bar with search/sort/view toggle
            ├── storage_overview_card.dart   # Storage statistics card
            ├── filter_chips_bar.dart        # File type filter chips
            ├── files_grid_view.dart         # Grid layout for files
            ├── files_list_view.dart         # List layout for files
            ├── upload_progress_overlay.dart # Upload progress indicator
            ├── file_details_sheet.dart      # File details bottom sheet
            ├── empty_files_view.dart        # Empty state view
            └── confirm_delete_file.dart     # Delete confirmation dialog
```

### State Management

Uses **Cubit pattern** (flutter_bloc) for predictable state management.

#### MyFilesState

```dart
class MyFilesState {
  final List<MyFile> files;
  final List<MyFile> filteredFiles;
  final List<MyFolder> folders;
  final MyFile? selectedFile;
  final StorageStats storageStats;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final FileFilterOption filterOption;
  final FileSortOption sortOption;
  final ViewMode viewMode;
  final bool isMultiSelectMode;
  final Set<String> selectedFileIds;
  final UploadProgress? uploadProgress;
}
```

#### MyFile Model

```dart
class MyFile {
  final String id;
  final String name;
  final String path;
  final String extension;
  final FileType type;
  final int sizeInBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isFavorite;
  final String? thumbnailPath;
  
  String get formattedSize => _formatFileSize(sizeInBytes);
}
```

#### FileType Enum

```dart
enum FileType {
  pdf,
  document,
  image,
  video,
  audio,
  spreadsheet,
  presentation,
  archive,
  code,
  other,
}
```

## Features

### 1. File Upload

- **File Picker**: Select files from device storage
- **Multiple Selection**: Upload multiple files at once
- **Progress Indicator**: Real-time upload progress overlay
- **Auto-categorization**: Files automatically categorized by type

### 2. File Management

- **Grid View**: Visual grid layout with file thumbnails
- **List View**: Compact list layout with file details
- **View Toggle**: Switch between grid and list views
- **File Details**: Bottom sheet with complete file information

### 3. File Actions

- **Open**: Open file with default system app
- **Favorite**: Mark/unmark files as favorites
- **Delete**: Delete single or multiple files
- **Multi-select**: Long press to enable multi-selection

### 4. Search & Filter

- **Real-time Search**: Search files by name
- **Filter by Type**:
  - All Files
  - Documents (PDF, DOC, TXT)
  - Images (PNG, JPG, GIF)
  - Videos (MP4, MOV, AVI)
  - Audio (MP3, WAV, M4A)
  - Other

### 5. Sort Options

- Name (A-Z / Z-A)
- Date Modified (Newest / Oldest)
- Size (Largest / Smallest)
- Type

### 6. Storage Overview

- Total storage used
- Storage breakdown by file type
- Visual progress bar
- File count by category

## File Storage

### Local Storage Structure

```
{appDocuments}/
└── my_files/
    ├── documents/
    ├── images/
    ├── videos/
    ├── audio/
    └── other/
```

### Metadata Persistence

File metadata stored in SharedPreferences:

```dart
static const String _storageKey = 'my_files_metadata';

// Save files metadata
Future<void> _saveFiles() async {
  final prefs = await SharedPreferences.getInstance();
  final filesJson = state.files.map((f) => f.toJson()).toList();
  await prefs.setString(_storageKey, jsonEncode(filesJson));
}
```

## Packages Used

| Package | Version | Purpose |
|---------|---------|---------|
| `file_picker` | ^8.1.6 | File selection from device |
| `open_file` | ^3.5.10 | Open files with system apps |
| `path_provider` | ^2.1.5 | Access app documents directory |
| `shared_preferences` | ^2.3.4 | Metadata persistence |
| `path` | ^1.9.0 | File path manipulation |

## UI Components

### StorageOverviewCard

Displays storage statistics:

```dart
StorageOverviewCard(
  isDark: isDark,
  totalSize: '2.4 GB',
  usedSize: '1.8 GB',
  fileCount: 145,
  breakdown: [
    StorageItem(type: FileType.document, size: '500 MB'),
    StorageItem(type: FileType.image, size: '800 MB'),
    // ...
  ],
)
```

### FilterChipsBar

Horizontal scrollable filter chips:

```dart
FilterChipsBar(
  isDark: isDark,
  selectedFilter: FileFilterOption.all,
  onFilterChanged: (filter) => cubit.setFilter(filter),
)
```

### FileDetailsSheet

Bottom sheet with file information and actions:

```dart
FileDetailsSheet(
  file: selectedFile,
  isDark: isDark,
  onOpen: () => cubit.openFile(file),
  onFavorite: () => cubit.toggleFavorite(file.id),
  onDelete: () => cubit.deleteFile(file.id),
)
```

### ConfirmDeleteFileDialog

Modern animated delete confirmation:

```dart
ConfirmDeleteFileDialog(
  isDark: isDark,
  fileCount: selectedCount,
  onCancel: () => Navigator.pop(context),
  onDelete: () {
    Navigator.pop(context);
    cubit.deleteSelectedFiles();
  },
)
```

## Localization

All UI text is localized in both English and Arabic:

| Key | English | Arabic |
|-----|---------|--------|
| `myFiles` | My Files | ملفاتي |
| `upload` | Upload | رفع |
| `allFiles` | All Files | جميع الملفات |
| `documents` | Documents | المستندات |
| `images` | Images | الصور |
| `videos` | Videos | الفيديوهات |
| `favorites` | Favorites | المفضلة |
| `storage` | Storage | التخزين |
| `fileSize` | Size | الحجم |
| `modified` | Modified | تم التعديل |
| `deleteFiles` | Delete Files | حذف الملفات |
| `deleteFilesConfirmation` | Are you sure you want to delete the selected files? | هل أنت متأكد من حذف الملفات المحددة؟ |
| `filesSelected` | files selected | ملفات محددة |
| `fileSelected` | file selected | ملف محدد |
| `noFiles` | No files yet | لا توجد ملفات بعد |
| `uploadFirst` | Upload your first file | ارفع ملفك الأول |

## Theme Support

### Color Scheme by File Type

| File Type | Color |
|-----------|-------|
| PDF | `#EF4444` (Red) |
| Document | `#3B82F6` (Blue) |
| Image | `#10B981` (Green) |
| Video | `#8B5CF6` (Purple) |
| Audio | `#F59E0B` (Amber) |
| Spreadsheet | `#10B981` (Green) |
| Presentation | `#F97316` (Orange) |
| Archive | `#6366F1` (Indigo) |
| Code | `#14B8A6` (Teal) |
| Other | `#64748B` (Gray) |

### Light Mode

| Element | Color |
|---------|-------|
| Background | `#F8FAFC` |
| Card | `#FFFFFF` |
| Border | `#E2E8F0` |
| Primary Text | `#1E293B` |
| Secondary Text | `#64748B` |

### Dark Mode

| Element | Color |
|---------|-------|
| Background | `#0F172A` |
| Card | `#1E293B` |
| Border | `#334155` |
| Primary Text | `#FFFFFF` |
| Secondary Text | `#94A3B8` |

## Navigation

### Route

```dart
GoRoute(
  path: '/my-files',
  name: 'myFiles',
  builder: (context, state) => const MyFilesScreen(),
),
```

### Access Points

1. **Student Drawer**: Menu item in navigation drawer
2. **Deep Link**: `eduverse://my-files`

## Error Handling

### Scenarios Handled

1. **Permission Denied**: Shows dialog to grant storage permission
2. **File Not Found**: Displays error toast with file name
3. **Upload Failed**: Shows error with retry option
4. **Delete Failed**: Displays error message
5. **Open Failed**: Falls back to share dialog

### Error Display

```dart
if (state.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(state.errorMessage!),
      backgroundColor: const Color(0xFFEF4444),
      action: SnackBarAction(
        label: l10n.dismiss,
        textColor: Colors.white,
        onPressed: () => cubit.clearError(),
      ),
    ),
  );
}
```

## Performance Optimizations

1. **Selective Rebuilds**: `buildWhen` in BlocBuilder for targeted UI updates
2. **Lazy Loading**: File thumbnails loaded on-demand
3. **Debounced Search**: 300ms debounce on search input
4. **Efficient Lists**: `SliverGrid` and `SliverList` for smooth scrolling
5. **Cached Metadata**: File metadata cached in memory
6. **File Name Truncation**: Long names truncated to prevent overflow

### File Name Truncation

```dart
String _truncateFileName(String name, int maxLength) {
  if (name.length <= maxLength) return name;
  
  final lastDot = name.lastIndexOf('.');
  if (lastDot == -1 || lastDot == 0) {
    return '${name.substring(0, maxLength - 3)}...';
  }
  
  final extension = name.substring(lastDot);
  final baseName = name.substring(0, lastDot);
  final availableLength = maxLength - extension.length - 3;
  
  return '${baseName.substring(0, availableLength)}...$extension';
}
```

## Multi-Select Mode

### Activation

- Long press on any file to enter multi-select mode
- Tap files to select/deselect

### Actions in Multi-Select

- **Cancel**: Exit multi-select mode
- **Delete**: Delete all selected files (with confirmation)

### FAB Behavior

```dart
if (state.isMultiSelectMode) {
  return Row(
    children: [
      FloatingActionButton(
        heroTag: 'cancel',
        onPressed: () => cubit.clearSelection(),
        child: Icon(Icons.close_rounded),
      ),
      if (state.selectedFileIds.isNotEmpty)
        FloatingActionButton.extended(
          heroTag: 'delete',
          onPressed: () => _showDeleteConfirmation(),
          icon: Icon(Icons.delete_rounded),
          label: Text('${state.selectedFileIds.length}'),
        ),
    ],
  );
}
```

## Real-time Favorite Update

The favorite button updates in real-time using BlocBuilder:

```dart
BlocBuilder<MyFilesCubit, MyFilesState>(
  buildWhen: (p, c) {
    final pFile = p.files.where((f) => f.id == file.id).firstOrNull;
    final cFile = c.files.where((f) => f.id == file.id).firstOrNull;
    return pFile?.isFavorite != cFile?.isFavorite;
  },
  builder: (context, state) {
    final currentFile = state.files
        .where((f) => f.id == file.id)
        .firstOrNull ?? file;
    
    return IconButton(
      icon: Icon(
        currentFile.isFavorite 
            ? Icons.star_rounded 
            : Icons.star_outline_rounded,
        color: currentFile.isFavorite 
            ? const Color(0xFFF59E0B) 
            : null,
      ),
      onPressed: () => cubit.toggleFavorite(file.id),
    );
  },
)
```

## Usage Example

```dart
// Navigate to My Files
context.push('/my-files');

// Upload files programmatically
context.read<MyFilesCubit>().uploadFiles();

// Toggle favorite
context.read<MyFilesCubit>().toggleFavorite(fileId);

// Delete selected files
context.read<MyFilesCubit>().deleteSelectedFiles();

// Change view mode
context.read<MyFilesCubit>().toggleViewMode();
```

## Future Enhancements

- [ ] Cloud storage integration (Google Drive, Dropbox)
- [ ] File sharing between users
- [ ] Folder creation and organization
- [ ] File preview (images, PDFs, documents)
- [ ] Offline file access
- [ ] File versioning
- [ ] Bulk download/upload
- [ ] Storage quota management
- [ ] File encryption
- [ ] Recent files section
- [ ] File tagging system
