import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../bloc/instructor/instructor_courses_bloc.dart';
import '../../../bloc/instructor/instructor_courses_event.dart';
import '../../../bloc/instructor/instructor_courses_state.dart';
import '../../../bloc/course_structure/course_structure_bloc.dart';
import '../../../bloc/course_structure/course_structure_event.dart';
import '../../../bloc/course_structure/course_structure_state.dart';
import '../../../bloc/materials/materials_bloc.dart';
import '../../../bloc/materials/materials_event.dart';
import '../../../bloc/materials/materials_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../models/core/course_structure_model.dart';
import '../../../models/instructor/upload_materials_model.dart';
import '../../../models/instructor/teaching_course_model.dart';
import '../../../models/materials/course_material_model.dart' as materials_api;
import '../../../services/storage_service.dart';
import '../../../utils/file_validator.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/instructor/upload_materials/upload_materials_barrel.dart';

/// Upload Materials Screen for instructors
class UploadMaterialsScreen extends StatefulWidget {
  final StorageService? storageService;

  const UploadMaterialsScreen({super.key, this.storageService});

  @override
  State<UploadMaterialsScreen> createState() => _UploadMaterialsScreenState();
}

class _UploadMaterialsScreenState extends State<UploadMaterialsScreen>
    with SingleTickerProviderStateMixin {
  static const Uuid _uuid = Uuid();

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _materialDescController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  late final StorageService _storageService;

  bool _hasUploadAccess = true;

  // Selection state
  String? _selectedCourseId;
  String? _selectedModuleId;
  CourseMaterialType? _filterType;
  String _searchQuery = '';
  String _bundleName = '';
  UploadProgressState? _lastVideoProgress;
  UploadProgressState? _lastBundleProgress;

  // Upload state
  final List<UploadQueueItem> _uploadQueue = [];
  final List<CourseMaterial> _uploadedMaterials = [];

  final List<CourseOption> _courses = <CourseOption>[];
  final Map<String, List<CourseModule>> _weekModulesByCourse =
      <String, List<CourseModule>>{};

  static final List<CourseModule> _defaultWeekModules =
      List<CourseModule>.generate(
        16,
        (index) => CourseModule(id: '${index + 1}', name: 'Week ${index + 1}'),
      );

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _tabController = TabController(length: 2, vsync: this);
    _resolveRoleAccess();
    context.read<InstructorCoursesBloc>().add(const LoadTeachingCourses());
  }

  Future<void> _resolveRoleAccess() async {
    try {
      final user = await _storageService.getUserData();
      final roleNames =
          user?.roles
              .map((role) => role.roleName.toLowerCase().trim())
              .toSet() ??
          <String>{};

      if (roleNames.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _hasUploadAccess = true;
        });
        return;
      }

      final hasUploadAccess = roleNames.any(
        (role) =>
            role == 'instructor' ||
            role == 'ta' ||
            role == 'teaching_assistant' ||
            role == 'admin' ||
            role == 'it_admin' ||
            role == 'it admin',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hasUploadAccess = hasUploadAccess;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasUploadAccess = true;
      });
    }
  }

  Widget _buildAccessDeniedState(bool isDark, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: UploadMaterialsColors.backgroundColor(isDark),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: UploadMaterialsColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: TextStyle(
                  color: UploadMaterialsColors.textPrimaryColor(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have permission to access upload materials.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: UploadMaterialsColors.textSecondaryColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => safeBack(context, '/instructor/dashboard'),
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
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
    final selectedCourseId = _selectedCourseId;
    if (selectedCourseId == null) {
      return const <CourseModule>[];
    }

    final modules = _weekModulesByCourse[selectedCourseId];
    if (modules == null || modules.isEmpty) {
      return _defaultWeekModules;
    }

    return modules;
  }

  int? get _selectedWeekNumber {
    final parsed = int.tryParse(_selectedModuleId ?? '');
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  String? get _selectedWeekLabel {
    if (_selectedModuleId == null) {
      return null;
    }

    for (final module in _availableModules) {
      if (module.id == _selectedModuleId) {
        return module.name;
      }
    }

    return null;
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
    _pickAndUploadFiles(materialType: 'document');
  }

  Future<void> _pickAndUploadFiles({required String materialType}) async {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a course first.')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: materialType == 'video' ? FileType.video : FileType.custom,
      allowedExtensions: materialType == 'video'
          ? null
          : <String>[
              'pdf',
              'docx',
              'pptx',
              'xlsx',
              'jpg',
              'jpeg',
              'png',
              'gif',
              'webp',
            ],
      withData: false,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
    if (courseId <= 0) {
      return;
    }

    for (final file in result.files) {
      if (file.path == null) {
        continue;
      }

      final validation = _validatePickedFile(file, materialType);
      if (!validation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation.errorMessage ?? 'Invalid file.')),
        );
        continue;
      }

      final uploadType = materialType == 'video' ? 'video' : 'document';
      final queueType = materialType == 'video'
          ? CourseMaterialType.video
          : CourseMaterialType.document;
      final uploadId = _uuid.v4();

      setState(() {
        _uploadQueue.insert(
          0,
          UploadQueueItem(
            id: uploadId,
            fileName: file.name,
            fileSize: file.size,
            type: queueType,
            status: UploadStatus.pending,
          ),
        );
        _tabController.animateTo(0);
      });

      context.read<MaterialsBloc>().add(
        UploadMaterial(
          courseId: courseId,
          uploadId: uploadId,
          title: file.name.split('.').first,
          materialType: uploadType,
          filePath: file.path,
          weekNumber: _selectedWeekNumber,
          isPublished: true,
        ),
      );
    }
  }

  FileValidationResult _validatePickedFile(PlatformFile file, String type) {
    if (type == 'video') {
      return FileValidator.validate(
        fileName: file.name,
        fileSizeBytes: file.size,
        kind: FileValidationKind.video,
      );
    }

    final lower = file.name.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');

    return FileValidator.validate(
      fileName: file.name,
      fileSizeBytes: file.size,
      kind: isImage ? FileValidationKind.image : FileValidationKind.document,
    );
  }

  Future<void> _handleFolderUpload() async {
    Navigator.pop(context);

    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a course first.')));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const <String>[
        'pdf',
        'docx',
        'pptx',
        'xlsx',
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'mp4',
        'mov',
        'avi',
        'mkv',
      ],
      withData: false,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
    if (courseId <= 0) {
      return;
    }

    String? bundleVideoPath;
    final bundleDocuments = <String>[];

    for (final file in result.files) {
      final path = file.path;
      if (path == null) {
        continue;
      }

      final isVideo = _isVideoFile(file.name);
      final validation = _validatePickedFile(
        file,
        isVideo ? 'video' : 'document',
      );
      if (!validation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation.errorMessage ?? 'Invalid file.')),
        );
        continue;
      }

      if (isVideo && bundleVideoPath == null) {
        bundleVideoPath = path;
      } else {
        bundleDocuments.add(path);
      }
    }

    if (bundleVideoPath == null && bundleDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid files selected for bundle.')),
      );
      return;
    }

    final uploadId = _uuid.v4();
    final bundleTitle = _bundleName.trim().isNotEmpty
        ? _bundleName.trim()
        : _resolveBundleTitle(result.files);

    setState(() {
      _bundleName = bundleTitle;
      _uploadQueue.insert(
        0,
        UploadQueueItem(
          id: uploadId,
          fileName: bundleTitle,
          fileSize: result.files.fold<int>(0, (sum, file) => sum + file.size),
          type: CourseMaterialType.archive,
          status: UploadStatus.pending,
        ),
      );
      _tabController.animateTo(0);
    });

    context.read<MaterialsBloc>().add(
      UploadMaterial(
        courseId: courseId,
        uploadId: uploadId,
        title: bundleTitle,
        materialType: 'bundle',
        weekNumber: _selectedWeekNumber,
        isPublished: true,
        bundleVideoPath: bundleVideoPath,
        bundleDocumentPaths: bundleDocuments,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bundle upload started'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: UploadMaterialsColors.success,
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
          final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
          if (courseId <= 0) {
            return;
          }

          final uploadId = _uuid.v4();
          setState(() {
            _uploadQueue.insert(
              0,
              UploadQueueItem(
                id: uploadId,
                fileName: title,
                fileSize: 0,
                type: CourseMaterialType.link,
                status: UploadStatus.pending,
              ),
            );
          });

          context.read<MaterialsBloc>().add(
            UploadMaterial(
              courseId: courseId,
              uploadId: uploadId,
              title: title,
              materialType: 'link',
              linkUrl: url,
              weekNumber: _selectedWeekNumber,
              isPublished: true,
            ),
          );

          Navigator.pop(context);
          _linkController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Link upload started'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retry by selecting the file again.')),
    );
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
                  final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
                  Navigator.pop(context);
                  if (courseId > 0) {
                    context.read<MaterialsBloc>().add(
                      DeleteMaterial(
                        courseId: courseId,
                        materialIds: <String>[material.id],
                      ),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Delete request sent'),
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
    final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
    if (courseId > 0) {
      context.read<MaterialsBloc>().add(
        ToggleMaterialVisibility(
          courseId: courseId,
          materialId: material.id,
          isPublished: !material.isVisible,
        ),
      );
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
              final courseId = int.tryParse(_selectedCourseId ?? '') ?? 0;
              if (courseId > 0 && _materialNameController.text.isNotEmpty) {
                context.read<MaterialsBloc>().add(
                  UpdateMaterial(
                    courseId: courseId,
                    materialId: material.id,
                    payload: <String, dynamic>{
                      'title': _materialNameController.text,
                      if (_materialDescController.text.isNotEmpty)
                        'description': _materialDescController.text,
                    },
                  ),
                );
              }
              Navigator.pop(context);
              _materialNameController.clear();
              _materialDescController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Material update request sent'),
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

        if (!_hasUploadAccess) {
          return _buildAccessDeniedState(isDark, l10n);
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<InstructorCoursesBloc, InstructorCoursesState>(
              listener: (context, state) {
                if (state is InstructorCoursesLoaded) {
                  final mapped = _mapTeachingCourses(state.courses);
                  setState(() {
                    _courses
                      ..clear()
                      ..addAll(mapped);

                    if (_selectedCourseId == null && _courses.isNotEmpty) {
                      _selectedCourseId = _courses.first.id;
                    }
                  });

                  final selected = int.tryParse(_selectedCourseId ?? '');
                  if (selected != null && selected > 0) {
                    context.read<MaterialsBloc>().add(LoadMaterials(selected));
                    context.read<CourseStructureBloc>().add(
                      LoadStructure(selected),
                    );
                  }
                }
              },
            ),
            BlocListener<MaterialsBloc, MaterialsState>(
              listener: (context, state) {
                if (state is MaterialsLoaded) {
                  setState(() {
                    _uploadedMaterials
                      ..clear()
                      ..addAll(state.materials.map(_mapFromMaterialApi));
                  });
                }

                if (state is UploadProgress) {
                  _upsertQueueFromProgress(state.progress);
                }

                if (state is MaterialsError && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
            BlocListener<CourseStructureBloc, CourseStructureState>(
              listener: (context, state) {
                if (state is StructureLoaded) {
                  final key = state.courseId.toString();
                  final mapped = _mapWeekModules(state.items);

                  setState(() {
                    _weekModulesByCourse[key] = mapped;

                    if (_selectedCourseId == key &&
                        _selectedModuleId != null &&
                        !mapped.any(
                          (module) => module.id == _selectedModuleId,
                        )) {
                      _selectedModuleId = null;
                    }
                  });
                }
              },
            ),
          ],
          child: Scaffold(
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
          iosBackIcon(context),
          color: UploadMaterialsColors.textPrimaryColor(isDark),
        ),
        onPressed: () => safeBack(context, '/instructor/dashboard'),
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.uploadMaterial,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: UploadMaterialsColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.uploadMaterialSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: UploadMaterialsColors.textSecondaryColor(isDark),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
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

              final selected = int.tryParse(id ?? '');
              if (selected != null && selected > 0) {
                context.read<InstructorCoursesBloc>().add(
                  SelectCourse(selected),
                );
                context.read<MaterialsBloc>().add(LoadMaterials(selected));
                context.read<CourseStructureBloc>().add(
                  LoadStructure(selected),
                );
              }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          WeekNumberSelector(
            weekNumber: _selectedWeekNumber,
            onWeekChanged: (week) {
              setState(() {
                _selectedModuleId = week?.toString();
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
                  onTap: () => _pickAndUploadFiles(materialType: 'document'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UploadTypeButton(
                  icon: Icons.video_library_rounded,
                  label: l10n.videos,
                  color: UploadMaterialsColors.video,
                  onTap: () => _pickAndUploadFiles(materialType: 'video'),
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
          const SizedBox(height: 16),
          VideoUploadSection(
            progress: _lastVideoProgress,
            isDark: isDark,
            onSelectVideo: () => _pickAndUploadFiles(materialType: 'video'),
            onRetry: () => _pickAndUploadFiles(materialType: 'video'),
            selectedWeekLabel: _selectedWeekLabel,
          ),
          const SizedBox(height: 12),
          BundleUploadSection(
            isDark: isDark,
            bundleName: _bundleName,
            onBundleNameChanged: (value) {
              setState(() {
                _bundleName = value;
              });
            },
            progress: _lastBundleProgress,
            onSelectBundleFiles: () {
              _handleFolderUpload();
            },
            onRetry: () {
              _handleFolderUpload();
            },
            selectedWeekLabel: _selectedWeekLabel,
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

  List<CourseOption> _mapTeachingCourses(List<TeachingCourseModel> courses) {
    return courses
        .map(
          (course) => CourseOption(
            id: course.courseId.toString(),
            name: course.course.courseName,
            code: course.course.courseCode,
            modules: const <CourseModule>[],
          ),
        )
        .toList();
  }

  CourseMaterial _mapFromMaterialApi(
    materials_api.CourseMaterialModel material,
  ) {
    return CourseMaterial(
      id: material.materialId,
      name: material.title,
      description: material.description,
      type: _mapMaterialType(material.type),
      fileUrl: material.url ?? material.externalUrl,
      fileName: material.title,
      fileSize: material.file?.fileSize,
      courseId: material.courseId,
      moduleId: material.weekNumber?.toString(),
      uploadedAt: material.createdAt,
      status: UploadStatus.completed,
      isVisible: material.isPublished,
      downloadCount: material.downloadCount ?? 0,
      tags: material.weekNumber != null
          ? <String>['Week ${material.weekNumber}']
          : null,
    );
  }

  CourseMaterialType _mapMaterialType(materials_api.MaterialType type) {
    switch (type) {
      case materials_api.MaterialType.video:
        return CourseMaterialType.video;
      case materials_api.MaterialType.link:
        return CourseMaterialType.link;
      case materials_api.MaterialType.document:
      case materials_api.MaterialType.reading:
      case materials_api.MaterialType.slide:
      case materials_api.MaterialType.lecture:
      case materials_api.MaterialType.other:
        return CourseMaterialType.document;
    }
  }

  List<CourseModule> _mapWeekModules(List<CourseStructureModel> items) {
    if (items.isEmpty) {
      return _defaultWeekModules;
    }

    final weekTitles = <int, String>{};
    for (final item in items) {
      if (item.weekNumber <= 0) {
        continue;
      }
      weekTitles.putIfAbsent(item.weekNumber, () => item.title);
    }

    if (weekTitles.isEmpty) {
      return _defaultWeekModules;
    }

    final sortedWeeks = weekTitles.keys.toList()..sort();
    return sortedWeeks
        .map((week) {
          final title = weekTitles[week]?.trim() ?? '';
          final label = title.isEmpty ? 'Week $week' : 'Week $week - $title';
          return CourseModule(id: week.toString(), name: label);
        })
        .toList(growable: false);
  }

  bool _isVideoFile(String fileName) {
    final lower = fileName.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  String _resolveBundleTitle(List<PlatformFile> files) {
    final preferred = files.firstWhere(
      (file) => _isVideoFile(file.name),
      orElse: () => files.first,
    );

    final dot = preferred.name.lastIndexOf('.');
    if (dot <= 0) {
      return preferred.name;
    }
    return preferred.name.substring(0, dot);
  }

  void _upsertQueueFromProgress(UploadProgressState progress) {
    final existingIndex = _uploadQueue.indexWhere(
      (item) => item.id == progress.uploadId,
    );
    final existingType = existingIndex >= 0
        ? _uploadQueue[existingIndex].type
        : _mapQueueTypeByFileName(progress.fileName);

    if (existingType == CourseMaterialType.video) {
      _lastVideoProgress = progress;
    } else if (existingType == CourseMaterialType.archive) {
      _lastBundleProgress = progress;
    }

    final queueType = _mapQueueTypeByFileName(progress.fileName);
    final queueItem = progress.toQueueItem(queueType);

    setState(() {
      final index = _uploadQueue.indexWhere(
        (item) => item.id == progress.uploadId,
      );
      if (index >= 0) {
        _uploadQueue[index] = queueItem.copyWith(
          type: _uploadQueue[index].type,
        );
      } else {
        _uploadQueue.insert(0, queueItem);
      }
    });
  }

  CourseMaterialType _mapQueueTypeByFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv')) {
      return CourseMaterialType.video;
    }

    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return CourseMaterialType.link;
    }

    return CourseMaterialType.document;
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
