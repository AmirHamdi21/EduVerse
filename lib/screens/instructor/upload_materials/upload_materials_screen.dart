import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/instructor/upload_materials_model.dart';
import '../../../widgets/instructor/upload_materials/upload_materials_barrel.dart';

/// Upload Materials Screen for instructors
class UploadMaterialsScreen extends StatefulWidget {
  const UploadMaterialsScreen({super.key});

  @override
  State<UploadMaterialsScreen> createState() => _UploadMaterialsScreenState();
}

class _UploadMaterialsScreenState extends State<UploadMaterialsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _materialDescController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // Selection state
  String? _selectedCourseId;
  String? _selectedModuleId;
  CourseMaterialType? _filterType;
  String _searchQuery = '';

  // Upload state
  final List<UploadQueueItem> _uploadQueue = [];
  final List<CourseMaterial> _uploadedMaterials = [];
  bool _isUploading = false;

  // Mock data
  final List<CourseOption> _courses = [
    CourseOption(
      id: 'cs101',
      name: 'Introduction to Computer Science',
      code: 'CS 101',
      modules: [
        const CourseModule(
          id: 'm1',
          name: 'Module 1: Basics',
          materialCount: 5,
        ),
        const CourseModule(
          id: 'm2',
          name: 'Module 2: Programming',
          materialCount: 3,
        ),
        const CourseModule(
          id: 'm3',
          name: 'Module 3: Data Structures',
          materialCount: 0,
        ),
      ],
    ),
    const CourseOption(
      id: 'cs201',
      name: 'Data Structures & Algorithms',
      code: 'CS 201',
      modules: [
        CourseModule(id: 'm1', name: 'Arrays & Lists', materialCount: 4),
        CourseModule(id: 'm2', name: 'Trees & Graphs', materialCount: 2),
      ],
    ),
    const CourseOption(
      id: 'cs301',
      name: 'Database Systems',
      code: 'CS 301',
      modules: [
        CourseModule(id: 'm1', name: 'SQL Basics', materialCount: 6),
        CourseModule(id: 'm2', name: 'Normalization', materialCount: 1),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMockMaterials();
  }

  void _loadMockMaterials() {
    _uploadedMaterials.addAll([
      CourseMaterial(
        id: '1',
        name: 'Course Syllabus',
        description: 'Complete course syllabus for CS 101',
        type: CourseMaterialType.document,
        fileSize: 256000,
        courseId: 'cs101',
        uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
        status: UploadStatus.completed,
        isVisible: true,
        downloadCount: 45,
        tags: ['syllabus', 'important'],
      ),
      CourseMaterial(
        id: '2',
        name: 'Lecture 1 - Introduction',
        type: CourseMaterialType.video,
        fileSize: 125000000,
        courseId: 'cs101',
        moduleId: 'm1',
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
        status: UploadStatus.completed,
        isVisible: true,
        downloadCount: 32,
        tags: ['lecture', 'video'],
      ),
      CourseMaterial(
        id: '3',
        name: 'Week 1 Slides',
        type: CourseMaterialType.presentation,
        fileSize: 4500000,
        courseId: 'cs101',
        moduleId: 'm1',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: UploadStatus.completed,
        isVisible: true,
        downloadCount: 28,
      ),
      CourseMaterial(
        id: '4',
        name: 'Programming Exercise Dataset',
        type: CourseMaterialType.spreadsheet,
        fileSize: 890000,
        courseId: 'cs101',
        moduleId: 'm2',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: UploadStatus.completed,
        isVisible: false,
        downloadCount: 0,
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _materialNameController.dispose();
    _materialDescController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  List<CourseModule> get _availableModules {
    if (_selectedCourseId == null) return [];
    final course = _courses.firstWhere(
      (c) => c.id == _selectedCourseId,
      orElse: () => const CourseOption(id: '', name: '', code: ''),
    );
    return course.modules;
  }

  List<CourseMaterial> get _filteredMaterials {
    return _uploadedMaterials.where((material) {
      // Filter by course
      if (_selectedCourseId != null && material.courseId != _selectedCourseId) {
        return false;
      }
      // Filter by module
      if (_selectedModuleId != null && material.moduleId != _selectedModuleId) {
        return false;
      }
      // Filter by type
      if (_filterType != null && material.type != _filterType) {
        return false;
      }
      // Filter by search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return material.name.toLowerCase().contains(query) ||
            (material.description?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  void _showUploadOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UploadOptionsSheet(
        isDark: isDark,
        onFileUpload: () => _handleFileUpload(isDark),
        onLinkAdd: () => _showAddLinkDialog(isDark),
        onFolderUpload: () => _handleFolderUpload(),
      ),
    );
  }

  void _handleFileUpload(bool isDark) {
    Navigator.pop(context);
    // Simulate file picker
    _simulateFileSelection();
  }

  void _simulateFileSelection() {
    // Add mock files to upload queue
    final mockFiles = [
      UploadQueueItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: 'Lecture_Notes_Week2.pdf',
        fileSize: 2500000,
        type: CourseMaterialType.document,
        status: UploadStatus.pending,
      ),
      UploadQueueItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        fileName: 'Assignment_Template.docx',
        fileSize: 156000,
        type: CourseMaterialType.document,
        status: UploadStatus.pending,
      ),
    ];

    setState(() {
      _uploadQueue.addAll(mockFiles);
      _tabController.animateTo(0); // Switch to upload tab
    });

    _startUploading();
  }

  void _startUploading() {
    if (_isUploading) return;
    _isUploading = true;
    _processUploadQueue();
  }

  void _processUploadQueue() async {
    for (int i = 0; i < _uploadQueue.length; i++) {
      if (_uploadQueue[i].status != UploadStatus.pending) continue;

      // Start uploading
      setState(() {
        _uploadQueue[i] = _uploadQueue[i].copyWith(
          status: UploadStatus.uploading,
          progress: 0.0,
        );
      });

      // Simulate upload progress
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        setState(() {
          _uploadQueue[i] = _uploadQueue[i].copyWith(progress: progress);
        });
      }

      // Processing
      setState(() {
        _uploadQueue[i] = _uploadQueue[i].copyWith(
          status: UploadStatus.processing,
          progress: 1.0,
        );
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Completed
      setState(() {
        _uploadQueue[i] = _uploadQueue[i].copyWith(
          status: UploadStatus.completed,
        );

        // Add to uploaded materials
        _uploadedMaterials.insert(
          0,
          CourseMaterial(
            id: _uploadQueue[i].id,
            name: _uploadQueue[i].fileName.split('.').first,
            type: _uploadQueue[i].type,
            fileSize: _uploadQueue[i].fileSize,
            courseId: _selectedCourseId ?? 'cs101',
            moduleId: _selectedModuleId,
            uploadedAt: DateTime.now(),
            status: UploadStatus.completed,
            isVisible: true,
            downloadCount: 0,
          ),
        );
      });
    }

    _isUploading = false;
  }

  void _handleFolderUpload() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Folder upload coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddLinkDialog(bool isDark) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => _AddLinkDialog(
        isDark: isDark,
        controller: _linkController,
        onAdd: (url, title) {
          setState(() {
            _uploadedMaterials.insert(
              0,
              CourseMaterial(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: title,
                type: CourseMaterialType.link,
                fileUrl: url,
                courseId: _selectedCourseId ?? 'cs101',
                moduleId: _selectedModuleId,
                uploadedAt: DateTime.now(),
                status: UploadStatus.completed,
                isVisible: true,
                downloadCount: 0,
              ),
            );
          });
          Navigator.pop(context);
          _linkController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link added successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: UploadMaterialsColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  void _cancelUpload(int index) {
    setState(() {
      _uploadQueue.removeAt(index);
    });
  }

  void _retryUpload(int index) {
    setState(() {
      _uploadQueue[index] = _uploadQueue[index].copyWith(
        status: UploadStatus.pending,
        progress: 0.0,
        errorMessage: null,
      );
    });
    _startUploading();
  }

  void _removeFromQueue(int index) {
    setState(() {
      _uploadQueue.removeAt(index);
    });
  }

  void _clearCompletedUploads() {
    setState(() {
      _uploadQueue.removeWhere((item) => item.status == UploadStatus.completed);
    });
  }

  void _deleteMaterial(CourseMaterial material) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.isDark;
          return AlertDialog(
            backgroundColor: isDark
                ? UploadMaterialsColors.darkCard
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Material?',
              style: TextStyle(
                color: UploadMaterialsColors.textPrimaryColor(isDark),
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${material.name}"? This action cannot be undone.',
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: UploadMaterialsColors.textSecondaryColor(isDark),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _uploadedMaterials.remove(material);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Material deleted'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: UploadMaterialsColors.error,
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

  void _toggleVisibility(CourseMaterial material) {
    final index = _uploadedMaterials.indexOf(material);
    if (index != -1) {
      setState(() {
        _uploadedMaterials[index] = material.copyWith(
          isVisible: !material.isVisible,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            material.isVisible
                ? 'Material hidden from students'
                : 'Material visible to students',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _editMaterial(CourseMaterial material, bool isDark) {
    _materialNameController.text = material.name;
    _materialDescController.text = material.description ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Material',
          style: TextStyle(
            color: UploadMaterialsColors.textPrimaryColor(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _materialNameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(
                color: UploadMaterialsColors.textPrimaryColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _materialDescController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(
                color: UploadMaterialsColors.textPrimaryColor(isDark),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final index = _uploadedMaterials.indexOf(material);
              if (index != -1) {
                setState(() {
                  _uploadedMaterials[index] = material.copyWith(
                    name: _materialNameController.text,
                    description: _materialDescController.text.isEmpty
                        ? null
                        : _materialDescController.text,
                  );
                });
              }
              Navigator.pop(context);
              _materialNameController.clear();
              _materialDescController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Material updated'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: UploadMaterialsColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UploadMaterialsColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: UploadMaterialsColors.backgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: Column(
            children: [
              // Tab bar
              Container(
                color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: UploadMaterialsColors.primary,
                  unselectedLabelColor:
                      UploadMaterialsColors.textSecondaryColor(isDark),
                  indicatorColor: UploadMaterialsColors.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.upload),
                          if (_uploadQueue.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: UploadMaterialsColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_uploadQueue.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.materials),
                          if (_uploadedMaterials.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: UploadMaterialsColors.surfaceColor(
                                  isDark,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_uploadedMaterials.length}',
                                style: TextStyle(
                                  color:
                                      UploadMaterialsColors.textSecondaryColor(
                                        isDark,
                                      ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUploadTab(isDark, l10n),
                    _buildMaterialsTab(isDark, l10n),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUploadOptions(isDark),
            backgroundColor: UploadMaterialsColors.uploadGreen,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.upload),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      leadingWidth: 30,
      backgroundColor: isDark ? UploadMaterialsColors.darkCard : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: UploadMaterialsColors.textPrimaryColor(isDark),
        ),
        onPressed: () => context.pop(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: UploadMaterialsColors.uploadGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.uploadMaterial,
                style: TextStyle(
                  color: UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.uploadMaterialSubtitle,
                style: TextStyle(
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (_uploadQueue.any((item) => item.status == UploadStatus.completed))
          TextButton.icon(
            onPressed: _clearCompletedUploads,
            icon: Icon(
              Icons.clear_all_rounded,
              color: UploadMaterialsColors.textSecondaryColor(isDark),
              size: 12,
            ),
            label: Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            // size: 14,
            color: UploadMaterialsColors.textSecondaryColor(isDark),
          ),
          onPressed: () => _showMoreOptions(isDark),
        ),
      ],
    );
  }

  Widget _buildUploadTab(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course & Module selection
          UploadSectionHeader(
            title: l10n.selectDestination,
            subtitle: l10n.selectDestinationSubtitle,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          CourseSelector(
            courses: _courses,
            selectedCourseId: _selectedCourseId,
            onCourseChanged: (id) {
              setState(() {
                _selectedCourseId = id;
                _selectedModuleId = null;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ModuleSelector(
            modules: _availableModules,
            selectedModuleId: _selectedModuleId,
            onModuleChanged: (id) {
              setState(() {
                _selectedModuleId = id;
              });
            },
            isDark: isDark,
            enabled: _selectedCourseId != null,
          ),
          const SizedBox(height: 24),

          // Drop zone
          UploadSectionHeader(title: l10n.uploadFiles, isDark: isDark),
          const SizedBox(height: 8),
          UploadDropZone(
            isDark: isDark,
            onTap: () => _showUploadOptions(isDark),
          ),
          const SizedBox(height: 16),

          // Quick upload buttons
          Row(
            children: [
              Expanded(
                child: UploadTypeButton(
                  icon: Icons.description_rounded,
                  label: l10n.documents,
                  color: UploadMaterialsColors.document,
                  onTap: () => _simulateFileSelection(),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UploadTypeButton(
                  icon: Icons.video_library_rounded,
                  label: l10n.videos,
                  color: UploadMaterialsColors.video,
                  onTap: () => _simulateFileSelection(),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UploadTypeButton(
                  icon: Icons.link_rounded,
                  label: l10n.links,
                  color: UploadMaterialsColors.link,
                  onTap: () => _showAddLinkDialog(isDark),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Upload queue
          if (_uploadQueue.isNotEmpty) ...[
            UploadSectionHeader(
              title: l10n.uploadQueue,
              subtitle: '${_uploadQueue.length} ${l10n.files}',
              isDark: isDark,
              trailing: TextButton(
                onPressed: _clearCompletedUploads,
                child: Text(
                  l10n.clearCompleted,
                  style: TextStyle(
                    color: UploadMaterialsColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._uploadQueue.asMap().entries.map((entry) {
              return UploadQueueCard(
                item: entry.value,
                onCancel: () => _cancelUpload(entry.key),
                onRetry: () => _retryUpload(entry.key),
                onRemove: () => _removeFromQueue(entry.key),
                isDark: isDark,
              );
            }),
          ] else
            UploadQueueEmpty(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: l10n.searchMaterials,
              hintStyle: TextStyle(
                color: UploadMaterialsColors.textTertiaryColor(isDark),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: UploadMaterialsColors.textSecondaryColor(isDark),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: UploadMaterialsColors.textSecondaryColor(isDark),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? UploadMaterialsColors.darkSurface
                  : UploadMaterialsColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color: UploadMaterialsColors.textPrimaryColor(isDark),
            ),
          ),
        ),

        // Type filter
        MaterialTypeFilter(
          selectedType: _filterType,
          onTypeChanged: (type) {
            setState(() {
              _filterType = type;
            });
          },
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        // Materials list
        Expanded(
          child: _filteredMaterials.isEmpty
              ? MaterialsListEmpty(
                  isDark: isDark,
                  onUpload: () => _showUploadOptions(isDark),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMaterials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final material = _filteredMaterials[index];
                    return MaterialItemCard(
                      material: material,
                      onTap: () {},
                      onEdit: () => _editMaterial(material, isDark),
                      onDelete: () => _deleteMaterial(material),
                      onToggleVisibility: () => _toggleVisibility(material),
                      onDownload: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${material.name}...'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showMoreOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UploadMaterialsColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.sort_rounded,
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                title: Text(
                  'Sort Materials',
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.download_rounded,
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                title: Text(
                  'Export All',
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings_outlined,
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
                title: Text(
                  'Upload Settings',
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upload options bottom sheet
class _UploadOptionsSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onFileUpload;
  final VoidCallback onLinkAdd;
  final VoidCallback onFolderUpload;

  const _UploadOptionsSheet({
    required this.isDark,
    required this.onFileUpload,
    required this.onLinkAdd,
    required this.onFolderUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? UploadMaterialsColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: UploadMaterialsColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Upload Options',
                style: TextStyle(
                  color: UploadMaterialsColors.textPrimaryColor(isDark),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildOption(
              icon: Icons.upload_file_rounded,
              label: 'Upload Files',
              subtitle: 'Select files from your device',
              color: UploadMaterialsColors.uploadGreen,
              onTap: onFileUpload,
            ),
            _buildOption(
              icon: Icons.folder_rounded,
              label: 'Upload Folder',
              subtitle: 'Upload entire folder with subfolders',
              color: UploadMaterialsColors.warning,
              onTap: onFolderUpload,
            ),
            _buildOption(
              icon: Icons.link_rounded,
              label: 'Add Link',
              subtitle: 'Add external link or resource',
              color: UploadMaterialsColors.link,
              onTap: onLinkAdd,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: UploadMaterialsColors.textPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: UploadMaterialsColors.textSecondaryColor(isDark),
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Add link dialog
class _AddLinkDialog extends StatefulWidget {
  final bool isDark;
  final TextEditingController controller;
  final Function(String url, String title) onAdd;

  const _AddLinkDialog({
    required this.isDark,
    required this.controller,
    required this.onAdd,
  });

  @override
  State<_AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<_AddLinkDialog> {
  final _titleController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateUrl);
    _titleController.addListener(_validateUrl);
  }

  void _validateUrl() {
    setState(() {
      _isValid =
          widget.controller.text.isNotEmpty &&
          _titleController.text.isNotEmpty &&
          Uri.tryParse(widget.controller.text)?.hasAbsolutePath == true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark
          ? UploadMaterialsColors.darkCard
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add Link',
        style: TextStyle(
          color: UploadMaterialsColors.textPrimaryColor(widget.isDark),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.title_rounded,
                color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
              ),
            ),
            style: TextStyle(
              color: UploadMaterialsColors.textPrimaryColor(widget.isDark),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'URL',
              labelStyle: TextStyle(
                color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.link_rounded,
                color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
              ),
              hintText: 'https://...',
            ),
            style: TextStyle(
              color: UploadMaterialsColors.textPrimaryColor(widget.isDark),
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: UploadMaterialsColors.textSecondaryColor(widget.isDark),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () =>
                    widget.onAdd(widget.controller.text, _titleController.text)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: UploadMaterialsColors.primary,
            disabledBackgroundColor: UploadMaterialsColors.primary.withValues(
              alpha: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Add Link'),
        ),
      ],
    );
  }
}
