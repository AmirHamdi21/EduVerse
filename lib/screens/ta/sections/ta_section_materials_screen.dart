import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/theme/theme_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/ta/shared/ta_colors.dart';
import '../../../widgets/ta/upload_materials/ta_upload_materials_barrel.dart';

/// TA Section Materials Screen - Upload and manage materials for a specific section.
/// Reuses the same UI/UX design as the main Upload Materials screen but scoped to a section.
///
/// ⚠️ BACKEND INTEGRATION REQUIRED ⚠️
///
/// This screen's UI is complete, but backend endpoints for section-specific materials
/// do not exist yet. The backend's CourseMaterial entity does NOT have a sectionId field.
///
/// REQUIRED BACKEND CHANGES:
///
/// 1. Database Migration:
///    ALTER TABLE course_materials
///    ADD COLUMN section_id BIGINT UNSIGNED NULL AFTER course_id,
///    ADD FOREIGN KEY (section_id) REFERENCES course_sections(id) ON DELETE SET NULL;
///
/// 2. New Endpoints Needed:
///    - GET    /api/sections/:sectionId/materials
///    - POST   /api/sections/:sectionId/materials
///    - DELETE /api/sections/:sectionId/materials/:materialId
///
/// 3. Update CourseMaterial entity to include:
///    @Column({ name: 'section_id', type: 'bigint', unsigned: true, nullable: true })
///    sectionId: number | null;
///
/// TEMPORARY WORKAROUND:
/// Currently using mock data. Once backend endpoints are ready, replace:
/// - _loadData() to call GET /api/sections/:sectionId/materials
/// - _simulateUpload() to call POST /api/sections/:sectionId/materials
/// - _deleteMaterial() to call DELETE endpoint
///
/// See: COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md for reference
class TASectionMaterialsScreen extends StatefulWidget {
  final int sectionId;
  final String sectionName;
  final int courseId;

  const TASectionMaterialsScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
    required this.courseId,
  });

  @override
  State<TASectionMaterialsScreen> createState() =>
      _TASectionMaterialsScreenState();
}

class _TASectionMaterialsScreenState extends State<TASectionMaterialsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFileType = 'all';
  String _selectedSortBy = 'recent';

  List<TAMaterialItem> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // TODO: BACKEND INTEGRATION NEEDED
    // Replace with: final result = await _sectionMaterialService.getSectionMaterials(widget.sectionId);
    // Currently using mock data because backend doesn't have section materials endpoints yet
    await Future.delayed(const Duration(milliseconds: 600));

    _materials = _getMockMaterials();

    setState(() => _isLoading = false);
  }

  List<TAMaterialItem> _getMockMaterials() {
    return [
      TAMaterialItem(
        id: '1',
        name: '${widget.sectionName}_Instructions.pdf',
        size: '2.4 MB',
        uploadDate: 'Jan 15, 2024',
        uploadedBy: 'TA',
        type: TAMaterialType.pdf,
        courseId: widget.courseId.toString(),
      ),
      TAMaterialItem(
        id: '2',
        name: '${widget.sectionName}_Demo.mp4',
        size: '145 MB',
        uploadDate: 'Jan 14, 2024',
        uploadedBy: 'TA',
        type: TAMaterialType.video,
        courseId: widget.courseId.toString(),
      ),
      TAMaterialItem(
        id: '3',
        name: 'code_examples.cpp',
        size: '8.2 KB',
        uploadDate: 'Jan 13, 2024',
        uploadedBy: 'TA',
        type: TAMaterialType.code,
        courseId: widget.courseId.toString(),
      ),
      TAMaterialItem(
        id: '4',
        name: 'study_guide.pdf',
        size: '1.8 MB',
        uploadDate: 'Jan 12, 2024',
        uploadedBy: 'TA',
        type: TAMaterialType.pdf,
        courseId: widget.courseId.toString(),
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
        filtered.sort((a, b) => a.size.compareTo(b.size));
        break;
      case 'recent':
      default:
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
              'Upload to ${widget.sectionName}',
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
              title: 'From Device',
              subtitle: 'Upload file from your device',
              onTap: () {
                Navigator.pop(context);
                _simulateUpload();
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              isDark: isDark,
              icon: Icons.cloud_rounded,
              title: 'From Cloud',
              subtitle: 'Upload from Google Drive',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Cloud storage coming soon');
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              isDark: isDark,
              icon: Icons.link_rounded,
              title: 'From URL',
              subtitle: 'Add material from URL',
              onTap: () {
                Navigator.pop(context);
                _showURLInputDialog(isDark);
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
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: TAColors.textTertiaryColor(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateUpload() {
    // TODO: BACKEND INTEGRATION NEEDED
    // Replace with actual upload logic:
    // 1. Use file_picker or image_picker to select file
    // 2. Upload via: _sectionMaterialService.uploadMaterial(widget.sectionId, file)
    // 3. Refresh materials list: await _loadData()
    // 4. Show success/error snackbar based on result
    _showSnackBar('Upload simulation - backend integration needed');
  }

  void _showURLInputDialog(bool isDark) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Material from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('URL material added');
              // TODO: Implement URL material addition
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _downloadMaterial(TAMaterialItem material) {
    _showSnackBar('Downloading ${material.name}');
    // TODO: Implement actual download
  }

  void _deleteMaterial(TAMaterialItem material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: BACKEND INTEGRATION NEEDED
              // Replace with: await _sectionMaterialService.deleteMaterial(widget.sectionId, material.id);
              Navigator.pop(context);
              setState(() {
                _materials.remove(material);
              });
              _showSnackBar('Material deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: TAColors.error),
            child: const Text('Delete'),
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
          appBar: AppBar(
            backgroundColor: TAColors.scaffoldColor(isDark),
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sectionName,
                  style: TextStyle(
                    color: TAColors.textPrimaryColor(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Section Materials',
                  style: TextStyle(
                    color: TAColors.textSecondaryColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<ThemeBloc>().add(const ToggleThemeEvent()),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: TAColors.textSecondaryColor(isDark),
                ),
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: TAColors.primary),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search materials...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: TAColors.textSecondaryColor(isDark),
                          ),
                          filled: true,
                          fillColor: TAColors.cardColor(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Filter chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('PDF', 'pdf', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('Video', 'video', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('Code', 'code', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('Image', 'image', isDark),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sort dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort by',
                          filled: true,
                          fillColor: TAColors.cardColor(isDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'recent',
                            child: Text('Most Recent'),
                          ),
                          DropdownMenuItem(
                            value: 'name',
                            child: Text('Name A-Z'),
                          ),
                          DropdownMenuItem(
                            value: 'size',
                            child: Text('File Size'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSortBy = value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Materials list
                    Expanded(
                      child: _filteredMaterials.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredMaterials.length,
                              itemBuilder: (context, index) {
                                final material = _filteredMaterials[index];
                                return _MaterialCard(
                                  material: material,
                                  isDark: isDark,
                                  onDownload: () => _downloadMaterial(material),
                                  onDelete: () => _deleteMaterial(material),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUploadDialog(isDark, l10n),
            backgroundColor: TAColors.primary,
            icon: const Icon(Icons.upload_rounded, color: Colors.white),
            label: const Text(
              'Upload Material',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFileType == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFileType = value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? TAColors.primary : TAColors.cardColor(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? TAColors.primary
                  : TAColors.borderColor(isDark),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : TAColors.textPrimaryColor(isDark),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TAColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file_rounded,
              size: 48,
              color: TAColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No materials uploaded yet',
            style: TextStyle(
              color: TAColors.textPrimaryColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the upload button to add materials',
            style: TextStyle(
              color: TAColors.textSecondaryColor(isDark),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final TAMaterialItem material;
  final bool isDark;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _MaterialCard({
    required this.material,
    required this.isDark,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TAColors.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TAColors.borderColor(isDark).withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.name,
                        style: TextStyle(
                          color: TAColors.textPrimaryColor(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${material.size} • ${material.uploadDate}',
                        style: TextStyle(
                          color: TAColors.textSecondaryColor(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (material.isAIGenerated)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: TAColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: TAColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TAColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: TAColors.error,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case TAMaterialType.video:
        return Icons.play_circle_rounded;
      case TAMaterialType.code:
        return Icons.code_rounded;
      case TAMaterialType.image:
        return Icons.image_rounded;
      case TAMaterialType.archive:
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor() {
    switch (material.type) {
      case TAMaterialType.pdf:
        return Colors.red;
      case TAMaterialType.video:
        return Colors.blue;
      case TAMaterialType.code:
        return Colors.green;
      case TAMaterialType.image:
        return Colors.purple;
      case TAMaterialType.archive:
        return Colors.orange;
      default:
        return TAColors.primary;
    }
  }
}
