import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/lab_resources/ta_lab_resources_barrel.dart';

class TALabResourcesScreen extends StatefulWidget {
  const TALabResourcesScreen({super.key});

  @override
  State<TALabResourcesScreen> createState() => _TALabResourcesScreenState();
}

class _TALabResourcesScreenState extends State<TALabResourcesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  int _selectedLabIndex = 0;

  final List<String> _labs = ['Lab 1', 'Lab 2', 'Lab 3', 'Lab 4'];
  final Map<int, List<TALabMaterialItem>> _materialsByLab = {};
  final Map<int, int> _qualityScores = {0: 82, 1: 76, 2: 91, 3: 65};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _labs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedLabIndex = _tabController.index;
        });
      }
    });
    _loadMaterials();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // Lab 1 materials
      _materialsByLab[0] = [
        TALabMaterialItem(
          id: '1',
          name: 'Data Structures Lab Guide.pdf',
          type: TAMaterialType.pdf,
          views: 156,
          downloads: 89,
          completionPercent: 92,
          aiTags: [TAMaterialAITag.verified, TAMaterialAITag.popular],
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          uploadedBy: 'TA Ahmed',
          fileSize: 2456,
        ),
        TALabMaterialItem(
          id: '2',
          name: 'LinkedList Implementation Tutorial',
          type: TAMaterialType.video,
          views: 234,
          downloads: 0,
          completionPercent: 78,
          aiTags: [TAMaterialAITag.suggestUpdate],
          uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
          uploadedBy: 'TA Ahmed',
          fileSize: 45000,
        ),
        TALabMaterialItem(
          id: '3',
          name: 'Sample Code - Binary Tree',
          type: TAMaterialType.code,
          views: 98,
          downloads: 67,
          completionPercent: 85,
          uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
          uploadedBy: 'TA Ahmed',
          fileSize: 45,
        ),
      ];

      // Lab 2 materials
      _materialsByLab[1] = [
        TALabMaterialItem(
          id: '4',
          name: 'Sorting Algorithms Overview.pdf',
          type: TAMaterialType.pdf,
          views: 189,
          downloads: 112,
          completionPercent: 88,
          aiTags: [TAMaterialAITag.lowClarity],
          uploadedAt: DateTime.now().subtract(const Duration(days: 8)),
          uploadedBy: 'TA Sara',
          fileSize: 3200,
        ),
        TALabMaterialItem(
          id: '5',
          name: 'QuickSort Visual Demo',
          type: TAMaterialType.video,
          views: 312,
          downloads: 0,
          completionPercent: 95,
          aiTags: [TAMaterialAITag.popular, TAMaterialAITag.verified],
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          uploadedBy: 'TA Sara',
          fileSize: 78000,
        ),
      ];

      // Lab 3 materials
      _materialsByLab[2] = [
        TALabMaterialItem(
          id: '6',
          name: 'Graph Theory Introduction.pdf',
          type: TAMaterialType.pdf,
          views: 145,
          downloads: 76,
          completionPercent: 91,
          uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
          uploadedBy: 'TA Ahmed',
          fileSize: 4100,
        ),
        TALabMaterialItem(
          id: '7',
          name: 'Dijkstra Algorithm Animation',
          type: TAMaterialType.video,
          views: 203,
          downloads: 0,
          completionPercent: 82,
          aiTags: [TAMaterialAITag.outdated],
          uploadedAt: DateTime.now().subtract(const Duration(days: 45)),
          uploadedBy: 'TA Ahmed',
          fileSize: 52000,
        ),
      ];

      // Lab 4 materials
      _materialsByLab[3] = [
        TALabMaterialItem(
          id: '8',
          name: 'Dynamic Programming Basics.pdf',
          type: TAMaterialType.pdf,
          views: 87,
          downloads: 45,
          completionPercent: 65,
          aiTags: [TAMaterialAITag.lowClarity, TAMaterialAITag.suggestUpdate],
          uploadedAt: DateTime.now().subtract(const Duration(days: 20)),
          uploadedBy: 'TA Sara',
          fileSize: 2800,
        ),
      ];

      _isLoading = false;
    });
  }

  List<TALabMaterialItem> get _filteredMaterials {
    final materials = _materialsByLab[_selectedLabIndex] ?? [];
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) return materials;

    return materials
        .where((m) => m.name.toLowerCase().contains(query))
        .toList();
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
          drawer: const TADrawer(currentRoute: '/ta/lab-resources'),
          appBar: _buildAppBar(isDark, l10n),
          body: _buildBody(context, isDark, l10n),
          floatingActionButton: _buildQuickActions(context, isDark, l10n),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: TAColors.cardColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: TAColors.textPrimaryColor(isDark),
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        l10n.taLabResTitle,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: TAColors.textSecondaryColor(isDark),
          ),
          onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Lab tabs
        _buildLabTabs(isDark),
        Expanded(
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _buildLabContent(isDark, l10n),
        ),
      ],
    );
  }

  Widget _buildLabTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: TAColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: TAColors.textSecondaryColor(isDark),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: _labs.map((lab) => Tab(text: lab)).toList(),
      ),
    );
  }

  Widget _buildLabContent(bool isDark, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadMaterials,
      color: TAColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quality score
            TALabQualityScore(
              score: _qualityScores[_selectedLabIndex] ?? 0,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Upload area
            _buildUploadArea(isDark, l10n),
            const SizedBox(height: 20),

            // Search
            _buildSearchBar(isDark, l10n),
            const SizedBox(height: 16),

            // Materials header
            Row(
              children: [
                Text(
                  l10n.taLabResRecentlyAdded,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredMaterials.length} ${l10n.taLabResMaterials}',
                  style: TextStyle(
                    color: TAColors.textTertiaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Materials list
            if (_filteredMaterials.isEmpty)
              _buildEmptyState(isDark, l10n)
            else
              ...List.generate(_filteredMaterials.length, (index) {
                final material = _filteredMaterials[index];
                return TALabMaterialCard(
                  material: material,
                  isDark: isDark,
                  onView: () => _viewMaterial(context, material, isDark, l10n),
                  onDownload: () => _downloadMaterial(context, material, l10n),
                  onReplace: () =>
                      _replaceMaterial(context, material, isDark, l10n),
                  onDelete: () =>
                      _deleteMaterial(context, material, isDark, l10n),
                );
              }),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(bool isDark, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _uploadNewMaterial(context, isDark, l10n),
      borderRadius: BorderRadius.circular(16),
      child: Center(
        child: Container(
          // width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: TAColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TAColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TAColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_rounded,
                  color: TAColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.taLabResUploadNew,
                style: TextStyle(
                  color: TAColors.textPrimaryColor(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.taLabResUploadDesc,
                style: TextStyle(
                  color: TAColors.textSecondaryColor(isDark),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: TAColors.textPrimaryColor(isDark),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: l10n.taLabResSearchMaterials,
          hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: TAColors.textTertiaryColor(isDark),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: TAColors.textTertiaryColor(isDark),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TAColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: TAColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.taLabResNoMaterials,
              style: TextStyle(
                color: TAColors.textPrimaryColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.taLabResNoMaterialsDesc,
              style: TextStyle(
                color: TAColors.textSecondaryColor(isDark),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: TAColors.primary),
          const SizedBox(height: 16),
          Text(
            'Loading materials...',
            style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'ai_insights',
          onPressed: () => _showAIInsights(context, isDark, l10n),
          backgroundColor: TAColors.warning,
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'new_folder',
          onPressed: () => _createNewFolder(context, isDark, l10n),
          backgroundColor: TAColors.info,
          child: const Icon(
            Icons.create_new_folder_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'upload',
          onPressed: () => _uploadNewMaterial(context, isDark, l10n),
          backgroundColor: TAColors.primary,
          icon: const Icon(Icons.upload_rounded, color: Colors.white),
          label: Text(
            l10n.taLabResUpload,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _uploadNewMaterial(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    HapticFeedback.lightImpact();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Show uploading dialog
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: TAColors.cardColor(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: TAColors.primary),
                const SizedBox(height: 16),
                Text(
                  '${l10n.taLabResUploading}...',
                  style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
                ),
                const SizedBox(height: 8),
                Text(
                  file.name,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

        // Simulate upload
        await Future.delayed(const Duration(seconds: 2));

        if (!context.mounted) return;
        Navigator.pop(context); // Close dialog

        // Add to materials
        final newMaterial = TALabMaterialItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          type: _getFileType(file.extension ?? ''),
          views: 0,
          downloads: 0,
          completionPercent: 0,
          uploadedAt: DateTime.now(),
          uploadedBy: 'You',
          fileSize: file.size ~/ 1024,
        );

        setState(() {
          _materialsByLab[_selectedLabIndex] = [
            newMaterial,
            ...(_materialsByLab[_selectedLabIndex] ?? []),
          ];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taLabResUploadSuccess),
            backgroundColor: TAColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: TAColors.error,
        ),
      );
    }
  }

  TAMaterialType _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return TAMaterialType.pdf;
      case 'mp4':
      case 'mov':
      case 'avi':
        return TAMaterialType.video;
      case 'doc':
      case 'docx':
      case 'txt':
        return TAMaterialType.document;
      case 'py':
      case 'java':
      case 'js':
      case 'cpp':
      case 'c':
        return TAMaterialType.code;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return TAMaterialType.image;
      default:
        return TAMaterialType.document;
    }
  }

  void _viewMaterial(
    BuildContext context,
    TALabMaterialItem material,
    bool isDark,
    AppLocalizations l10n,
  ) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: TAColors.cardColor(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TAColors.borderColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: TAColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getMaterialIcon(material.type),
                        color: TAColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.name,
                            style: TextStyle(
                              color: TAColors.textPrimaryColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Uploaded by ${material.uploadedBy}',
                            style: TextStyle(
                              color: TAColors.textSecondaryColor(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: TAColors.borderColor(isDark)),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailRow(
                      l10n.taLabResViews,
                      '${material.views}',
                      Icons.visibility_rounded,
                      isDark,
                    ),
                    _buildDetailRow(
                      l10n.taLabResDownloads,
                      '${material.downloads}',
                      Icons.download_rounded,
                      isDark,
                    ),
                    _buildDetailRow(
                      l10n.taLabResComplete,
                      '${material.completionPercent}%',
                      Icons.check_circle_rounded,
                      isDark,
                    ),
                    _buildDetailRow(
                      'File Size',
                      _formatFileSize(material.fileSize),
                      Icons.storage_rounded,
                      isDark,
                    ),
                    if (material.aiTags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'AI Insights',
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: material.aiTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagColor(tag).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: _getTagColor(tag),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getTagLabel(tag, l10n),
                                  style: TextStyle(
                                    color: _getTagColor(tag),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadMaterial(context, material, l10n);
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: Text(l10n.taLabResDownload),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TAColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TAColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(TAMaterialType type) {
    switch (type) {
      case TAMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case TAMaterialType.video:
        return Icons.play_circle_rounded;
      case TAMaterialType.document:
        return Icons.description_rounded;
      case TAMaterialType.code:
        return Icons.code_rounded;
      case TAMaterialType.image:
        return Icons.image_rounded;
      case TAMaterialType.link:
        return Icons.link_rounded;
    }
  }

  String _formatFileSize(int kb) {
    if (kb < 1024) return '$kb KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  Color _getTagColor(TAMaterialAITag tag) {
    switch (tag) {
      case TAMaterialAITag.lowClarity:
        return TAColors.warning;
      case TAMaterialAITag.suggestUpdate:
        return TAColors.info;
      case TAMaterialAITag.outdated:
        return TAColors.error;
      case TAMaterialAITag.popular:
        return TAColors.success;
      case TAMaterialAITag.verified:
        return TAColors.primary;
    }
  }

  String _getTagLabel(TAMaterialAITag tag, AppLocalizations l10n) {
    switch (tag) {
      case TAMaterialAITag.lowClarity:
        return l10n.taLabResAILowClarity;
      case TAMaterialAITag.suggestUpdate:
        return l10n.taLabResAISuggestUpdate;
      case TAMaterialAITag.outdated:
        return l10n.taLabResAIOutdated;
      case TAMaterialAITag.popular:
        return 'Popular';
      case TAMaterialAITag.verified:
        return 'Verified';
    }
  }

  void _downloadMaterial(
    BuildContext context,
    TALabMaterialItem material,
    AppLocalizations l10n,
  ) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.taLabResDownloading} ${material.name}...'),
        backgroundColor: TAColors.info,
      ),
    );
  }

  void _replaceMaterial(
    BuildContext context,
    TALabMaterialItem material,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    HapticFeedback.lightImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taLabResReplaceTitle,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          '${l10n.taLabResReplaceDesc} "${material.name}"?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.warning),
            child: Text(
              l10n.taLabResReplace,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taLabResReplaceSuccess),
          backgroundColor: TAColors.success,
        ),
      );
    }
  }

  void _deleteMaterial(
    BuildContext context,
    TALabMaterialItem material,
    bool isDark,
    AppLocalizations l10n,
  ) async {
    HapticFeedback.lightImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taLabResDeleteTitle,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: Text(
          '${l10n.taLabResDeleteDesc} "${material.name}"?',
          style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _materialsByLab[_selectedLabIndex]?.removeWhere(
          (m) => m.id == material.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.taLabResDeleteSuccess),
          backgroundColor: TAColors.success,
        ),
      );
    }
  }

  void _showAIInsights(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    HapticFeedback.lightImpact();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TAColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome, color: TAColors.warning),
                ),
                const SizedBox(width: 14),
                Text(
                  l10n.taLabResAIInsights,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInsightItem(
              '3 materials',
              'need clarity improvements',
              Icons.edit_note_rounded,
              TAColors.warning,
              isDark,
            ),
            _buildInsightItem(
              '1 material',
              'is outdated (>30 days old)',
              Icons.update_rounded,
              TAColors.error,
              isDark,
            ),
            _buildInsightItem(
              '2 materials',
              'are popular with students',
              Icons.trending_up_rounded,
              TAColors.success,
              isDark,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
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
    );
  }

  void _createNewFolder(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TAColors.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.taLabResNewFolder,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: TAColors.textPrimaryColor(isDark)),
          decoration: InputDecoration(
            hintText: l10n.taLabResFolderName,
            hintStyle: TextStyle(color: TAColors.textTertiaryColor(isDark)),
            prefixIcon: Icon(
              Icons.folder_rounded,
              color: TAColors.textTertiaryColor(isDark),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.borderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TAColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: TAColors.textSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.taLabResFolderCreated),
                  backgroundColor: TAColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TAColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.create,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
