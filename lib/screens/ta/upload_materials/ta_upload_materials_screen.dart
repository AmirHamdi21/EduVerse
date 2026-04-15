import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/upload_materials/ta_upload_materials_barrel.dart';

class TAUploadMaterialsScreen extends StatefulWidget {
  const TAUploadMaterialsScreen({super.key});

  @override
  State<TAUploadMaterialsScreen> createState() =>
      _TAUploadMaterialsScreenState();
}

class _TAUploadMaterialsScreenState extends State<TAUploadMaterialsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFileType = 'all';
  String _selectedSortBy = 'recent';
  String _selectedCourse = 'CS101';
  String _selectedLab = 'Lab 3';

  List<TAMaterialItem> _materials = [];

  final List<Map<String, dynamic>> _courses = [
    {'id': 'CS101', 'name': 'CS101 - Operating System'},
    {'id': 'CS201', 'name': 'CS201 - Data Structures'},
    {'id': 'CS301', 'name': 'CS301 - Algorithms'},
  ];

  final List<Map<String, dynamic>> _labs = [
    {'id': 'lab1', 'name': 'Lab 1'},
    {'id': 'lab2', 'name': 'Lab 2'},
    {'id': 'lab3', 'name': 'Lab 3'},
    {'id': 'lab4', 'name': 'Lab 4'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    _materials = _getMockMaterials();

    setState(() => _isLoading = false);
  }

  List<TAMaterialItem> _getMockMaterials() {
    return [
      const TAMaterialItem(
        id: '1',
        name: 'Lab_3_Instructions.pdf',
        size: '2.4 MB',
        uploadDate: 'Jan 15, 2024',
        uploadedBy: 'Dr. Smith',
        type: TAMaterialType.pdf,
        courseId: 'CS101',
        labId: 'lab3',
      ),
      const TAMaterialItem(
        id: '2',
        name: 'Synchronization_Demo.mp4',
        size: '145 MB',
        uploadDate: 'Jan 14, 2024',
        uploadedBy: 'TA Assistant',
        type: TAMaterialType.video,
        courseId: 'CS101',
        labId: 'lab3',
      ),
      const TAMaterialItem(
        id: '3',
        name: 'semaphore_examples.cpp',
        size: '8.2 KB',
        uploadDate: 'Jan 13, 2024',
        uploadedBy: 'Dr. Smith',
        type: TAMaterialType.code,
        courseId: 'CS101',
        labId: 'lab3',
      ),
      const TAMaterialItem(
        id: '4',
        name: 'AI_Study_Guide_Lab3.pdf',
        size: '1.8 MB',
        uploadDate: 'Jan 12, 2024',
        uploadedBy: 'AI Generated',
        type: TAMaterialType.pdf,
        isAIGenerated: true,
        courseId: 'CS101',
        labId: 'lab3',
      ),
      const TAMaterialItem(
        id: '5',
        name: 'process_diagram.png',
        size: '420 KB',
        uploadDate: 'Jan 11, 2024',
        uploadedBy: 'TA Assistant',
        type: TAMaterialType.image,
        courseId: 'CS101',
        labId: 'lab3',
      ),
      const TAMaterialItem(
        id: '6',
        name: 'lab_resources.zip',
        size: '12.5 MB',
        uploadDate: 'Jan 10, 2024',
        uploadedBy: 'Dr. Smith',
        type: TAMaterialType.archive,
        courseId: 'CS101',
        labId: 'lab3',
      ),
    ];
  }

  List<TAMaterialItem> get _filteredMaterials {
    var filtered = _materials;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (m) =>
                m.name.toLowerCase().contains(query) ||
                m.uploadedBy.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_selectedFileType != 'all') {
      filtered = filtered.where((m) {
        switch (_selectedFileType) {
          case 'pdf':
            return m.type == TAMaterialType.pdf;
          case 'video':
            return m.type == TAMaterialType.video;
          case 'code':
            return m.type == TAMaterialType.code;
          case 'image':
            return m.type == TAMaterialType.image;
          case 'ai':
            return m.isAIGenerated;
          default:
            return true;
        }
      }).toList();
    }

    switch (_selectedSortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'size':
        // Simple sort by name since we have string sizes
        filtered.sort((a, b) => a.size.compareTo(b.size));
        break;
      case 'recent':
      default:
        // Keep original order (most recent first)
        break;
    }

    return filtered;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUploadDialog(bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TAColors.borderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.taUploadSelectFile,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildUploadOption(
              isDark: isDark,
              icon: Icons.insert_drive_file_rounded,
              title: l10n.taUploadFromDevice,
              subtitle: l10n.taUploadFromDeviceHint,
              onTap: () {
                Navigator.pop(context);
                _simulateUpload(l10n);
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              isDark: isDark,
              icon: Icons.cloud_rounded,
              title: l10n.taUploadFromCloud,
              subtitle: l10n.taUploadFromCloudHint,
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Cloud storage coming soon');
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              isDark: isDark,
              icon: Icons.link_rounded,
              title: l10n.taUploadFromURL,
              subtitle: l10n.taUploadFromURLHint,
              onTap: () {
                Navigator.pop(context);
                _showURLInputDialog(isDark, l10n);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TAColors.scaffoldColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: TAColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TAColors.textPrimaryColor(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: TAColors.textTertiaryColor(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: TAColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showURLInputDialog(bool isDark, AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taUploadFromURL,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
            filled: true,
            fillColor: TAColors.scaffoldColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.taLabCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _simulateUpload(l10n);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.taUploadImport),
          ),
        ],
      ),
    );
  }

  void _simulateUpload(AppLocalizations l10n) {
    _showSnackBar(l10n.taUploadUploading);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _materials.insert(
          0,
          TAMaterialItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'New_Material.pdf',
            size: '1.2 MB',
            uploadDate: 'Just now',
            uploadedBy: 'You',
            type: TAMaterialType.pdf,
          ),
        );
      });
      _showSnackBar(l10n.taUploadSuccess);
    });
  }

  void _showDeleteConfirmation(
    bool isDark,
    AppLocalizations l10n,
    TAMaterialItem material,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.delete,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          '${l10n.taUploadDeleteConfirm} "${material.name}"?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.taLabCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _materials.removeWhere((m) => m.id == material.id);
              });
              _showSnackBar(l10n.taUploadDeleted);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
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
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: TADrawer(
            currentRoute: '/ta/upload-materials',
            isDark: isDark,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: TAColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(isDark, l10n),
                  SliverToBoxAdapter(
                    child: _buildCourseLabSelector(isDark, l10n),
                  ),
                  SliverToBoxAdapter(child: _buildStats(isDark, l10n)),
                  SliverToBoxAdapter(
                    child: TAUploadArea(
                      isDark: isDark,
                      onUploadTap: () => _showUploadDialog(isDark, l10n),
                      onAIGenerateTap: () =>
                          TAAIMaterialGenerator.show(context, isDark),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildFilterBar(isDark, l10n)),
                  _buildMaterialsList(isDark, l10n),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: TAColors.scaffoldColor(isDark),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taUploadTitle,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.taUploadSubtitle,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        _buildHeaderButton(
          icon: Icons.visibility_outlined,
          label: l10n.taUploadViewAll,
          isDark: isDark,
          onTap: () => _showSnackBar('View all materials'),
        ),
        _buildHeaderButton(
          icon: Icons.auto_awesome,
          label: l10n.taUploadAISuggest,
          isDark: isDark,
          onTap: () => _showSnackBar('AI suggestions'),
        ),
        IconButton(
          onPressed: () =>
              context.read<ThemeBloc>().add(const ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textPrimaryColor(isDark),
          ),
        ),
      ],
      floating: true,
      pinned: true,
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: TAColors.textSecondaryColor(isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseLabSelector(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCourse,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                  dropdownColor: TAColors.cardColor(isDark),
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                  ),
                  items: _courses.map((course) {
                    return DropdownMenuItem(
                      value: course['id'] as String,
                      child: Text(course['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCourse = value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLab,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: TAColors.textSecondaryColor(isDark),
                  ),
                  dropdownColor: TAColors.cardColor(isDark),
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 13,
                  ),
                  items: _labs.map((lab) {
                    return DropdownMenuItem(
                      value: lab['name'] as String,
                      child: Text(lab['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedLab = value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.group_outlined,
            value: '120',
            label: l10n.taUploadStudents,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            icon: Icons.folder_outlined,
            value: '${_materials.length}',
            label: l10n.taUploadMaterialsCount,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            icon: Icons.access_time_rounded,
            value: '3h',
            label: l10n.taUploadLastUpdated,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: TAColors.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: TAColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: TAColors.textPrimaryColor(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: TAColors.textTertiaryColor(isDark),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: TAColors.cardColor(isDark),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: l10n.taUploadSearch,
                  hintStyle: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: TAColors.textTertiaryColor(isDark),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // File type filter
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFileType,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: TAColors.textSecondaryColor(isDark),
                  size: 18,
                ),
                dropdownColor: TAColors.cardColor(isDark),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text(l10n.taUploadAllFiles),
                  ),
                  DropdownMenuItem(
                    value: 'pdf',
                    child: Text(l10n.taUploadPDFs),
                  ),
                  DropdownMenuItem(
                    value: 'video',
                    child: Text(l10n.taUploadVideos),
                  ),
                  DropdownMenuItem(
                    value: 'code',
                    child: Text(l10n.taUploadCode),
                  ),
                  DropdownMenuItem(
                    value: 'ai',
                    child: Text(l10n.taUploadAIGenerated),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedFileType = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: TAColors.cardColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSortBy,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: TAColors.textSecondaryColor(isDark),
                  size: 18,
                ),
                dropdownColor: TAColors.cardColor(isDark),
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 12,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'recent',
                    child: Text(l10n.taUploadRecent),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text(l10n.taUploadByName),
                  ),
                  DropdownMenuItem(
                    value: 'size',
                    child: Text(l10n.taUploadBySize),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedSortBy = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(bool isDark, AppLocalizations l10n) {
    if (_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(color: TAColors.primary),
          ),
        ),
      );
    }

    final materials = _filteredMaterials;

    if (materials.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(isDark, l10n));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final material = materials[index];
          return TAMaterialCard(
            material: material,
            isDark: isDark,
            onView: () => TAFilePreviewModal.show(context, material, isDark),
            onDownload: () => _showSnackBar('Downloading ${material.name}...'),
            onReplace: () => _showSnackBar('Replace ${material.name}'),
            onDelete: () => _showDeleteConfirmation(isDark, l10n, material),
          );
        }, childCount: materials.length),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: TAColors.textTertiaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.taUploadNoMaterials,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.taUploadNoMaterialsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TAColors.textTertiaryColor(isDark),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
