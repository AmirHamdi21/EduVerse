import 'package:flutter/material.dart';
import '../../../models/instructor/announcement_model.dart';
import 'announcement_colors.dart';

class AnnouncementFormDialog extends StatefulWidget {
  final AnnouncementItem? announcement;
  final bool isDark;
  final bool isAdmin;
  final Color? accentColor;
  final List<Map<String, String>>? courseOptions;
  final Function(AnnouncementItem) onSave;
  final VoidCallback onCancel;

  const AnnouncementFormDialog({
    super.key,
    this.announcement,
    required this.isDark,
    this.isAdmin = false,
    this.accentColor,
    this.courseOptions,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  String _selectedCourseId = '0';
  String _selectedPriority = 'medium';
  String _selectedAudience = 'all';
  bool _isSaving = false;
  String? _titleError;
  String? _contentError;

  List<Map<String, String>> get _resolvedCourseOptions {
    final provided =
        widget.courseOptions
            ?.where(
              (c) =>
                  (c['id'] ?? '').isNotEmpty && (c['label'] ?? '').isNotEmpty,
            )
            .toList() ??
        <Map<String, String>>[];

    if (provided.any((c) => c['id'] == '0')) {
      return provided;
    }

    return [
      {'id': '0', 'label': 'Campus-wide'},
      ...provided,
    ];
  }

  Color get _accentColor => widget.accentColor ?? AnnouncementColors.primary;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.announcement?.content ?? '',
    );
    _selectedPriority = widget.announcement?.priority ?? 'medium';

    final options = _resolvedCourseOptions;
    final existingCourseId = widget.announcement?.courseId;
    if (existingCourseId != null &&
        options.any((c) => c['id'] == existingCourseId)) {
      _selectedCourseId = existingCourseId;
    } else {
      _selectedCourseId = options.isNotEmpty ? options.first['id']! : '0';
    }

    _selectedAudience = _normalizeAudience(
      widget.announcement?.targetAudience ?? 'all',
    );

    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _validateAndSave({required bool publish}) {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty
          ? 'Title is required'
          : null;
      _contentError = _contentController.text.trim().isEmpty
          ? 'Content is required'
          : null;
    });

    if (_titleError != null || _contentError != null) {
      return;
    }

    setState(() => _isSaving = true);

    final selectedCourse = _resolvedCourseOptions.firstWhere(
      (c) => c['id'] == _selectedCourseId,
      orElse: () => const {'id': '0', 'label': 'Campus-wide'},
    );

    final status = publish
        ? AnnouncementStatus.published
        : AnnouncementStatus.draft;

    final payload = AnnouncementItem(
      id:
          widget.announcement?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      status: status,
      createdAt: widget.announcement?.createdAt ?? DateTime.now(),
      publishedAt: publish ? DateTime.now() : widget.announcement?.publishedAt,
      audience: selectedCourse['label'] ?? 'Campus-wide',
      totalAudience: widget.announcement?.totalAudience ?? 0,
      readCount: widget.announcement?.readCount ?? 0,
      attachments: widget.announcement?.attachments ?? const <String>[],
      courseName: _selectedCourseId == '0' ? null : selectedCourse['label'],
      courseId: _selectedCourseId == '0' ? null : _selectedCourseId,
      isPinned: widget.announcement?.isPinned ?? false,
      priority: _selectedPriority,
      announcementType: widget.announcement?.announcementType,
      authorName: widget.announcement?.authorName,
      targetAudience: widget.isAdmin ? _selectedAudience : null,
      viewCount: widget.announcement?.viewCount ?? 0,
    );

    widget.onSave(payload);
  }

  String _normalizeAudience(String raw) {
    const allowed = <String>{'all', 'students', 'instructors', 'tas'};
    final normalized = raw.trim().toLowerCase();
    return allowed.contains(normalized) ? normalized : 'all';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          decoration: BoxDecoration(
            color: widget.isDark ? AnnouncementColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isEditing),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 20),
                      _buildCourseSelector(),
                      const SizedBox(height: 20),
                      _buildPrioritySelector(),
                      if (widget.isAdmin) ...[
                        const SizedBox(height: 20),
                        _buildTargetAudienceSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildActionButtons(isEditing),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDark
                ? AnnouncementColors.darkBorder.withValues(alpha: 0.3)
                : AnnouncementColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Announcement' : 'New Announcement',
                  style: TextStyle(
                    color: AnnouncementColors.textPrimaryColor(widget.isDark),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isAdmin
                      ? 'Share campus updates with the selected audience'
                      : 'Share important updates with your students',
                  style: TextStyle(
                    color: AnnouncementColors.textSecondaryColor(widget.isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancel,
            icon: Icon(
              Icons.close_rounded,
              color: AnnouncementColors.textSecondaryColor(widget.isDark),
            ),
            style: IconButton.styleFrom(
              backgroundColor: widget.isDark
                  ? AnnouncementColors.darkSurface
                  : AnnouncementColors.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: TextStyle(
            color: AnnouncementColors.textPrimaryColor(widget.isDark),
            fontSize: 15,
          ),
          decoration: _inputDecoration(
            hintText: 'Enter announcement title...',
            errorText: _titleError,
          ),
          onChanged: (_) {
            if (_titleError != null) {
              setState(() => _titleError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 6,
          style: TextStyle(
            color: AnnouncementColors.textPrimaryColor(widget.isDark),
            fontSize: 15,
          ),
          decoration: _inputDecoration(
            hintText: 'Write your announcement here...',
            errorText: _contentError,
          ),
          onChanged: (_) {
            if (_contentError != null) {
              setState(() => _contentError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AnnouncementColors.darkSurface.withValues(alpha: 0.5)
                : AnnouncementColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AnnouncementColors.borderColor(widget.isDark),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourseId,
              isExpanded: true,
              dropdownColor: widget.isDark
                  ? AnnouncementColors.darkCard
                  : Colors.white,
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(widget.isDark),
                fontSize: 14,
              ),
              items: _resolvedCourseOptions.map((course) {
                return DropdownMenuItem<String>(
                  value: course['id'],
                  child: Text(course['label'] ?? 'Course'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCourseId = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    const priorities = ['low', 'medium', 'high', 'urgent'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AnnouncementColors.darkSurface.withValues(alpha: 0.5)
                : AnnouncementColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AnnouncementColors.borderColor(widget.isDark),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPriority,
              isExpanded: true,
              dropdownColor: widget.isDark
                  ? AnnouncementColors.darkCard
                  : Colors.white,
              style: TextStyle(
                color: AnnouncementColors.textPrimaryColor(widget.isDark),
                fontSize: 14,
              ),
              items: priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(
                    '${priority[0].toUpperCase()}${priority.substring(1)}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetAudienceSection() {
    final options = [
      {
        'value': 'all',
        'label': 'All Users',
        'icon': Icons.groups_rounded,
        'color': _accentColor,
      },
      {
        'value': 'students',
        'label': 'Students',
        'icon': Icons.school_rounded,
        'color': AnnouncementColors.published,
      },
      {
        'value': 'instructors',
        'label': 'Instructors',
        'icon': Icons.person_rounded,
        'color': AnnouncementColors.accent,
      },
      {
        'value': 'tas',
        'label': 'TAs',
        'icon': Icons.groups_rounded,
        'color': AnnouncementColors.scheduled,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Audience',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: options.map((option) {
            final isSelected = _selectedAudience == option['value'];
            final color = option['color'] as Color;

            return InkWell(
              onTap: () {
                setState(() => _selectedAudience = option['value'] as String);
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (widget.isDark
                            ? color.withValues(alpha: 0.2)
                            : color.withValues(alpha: 0.08))
                      : (widget.isDark
                            ? AnnouncementColors.darkSurface.withValues(alpha: 0.5)
                            : AnnouncementColors.surface),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? color.withValues(alpha: 0.6)
                        : AnnouncementColors.borderColor(widget.isDark),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? color
                          : AnnouncementColors.textSecondaryColor(
                              widget.isDark,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? color
                              : AnnouncementColors.textPrimaryColor(
                                  widget.isDark,
                                ),
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isSaving
                ? null
                : () => _validateAndSave(publish: false),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Draft'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AnnouncementColors.textSecondaryColor(
                widget.isDark,
              ),
              side: BorderSide(
                color: AnnouncementColors.borderColor(widget.isDark),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _validateAndSave(publish: true),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(isEditing ? 'Update & Publish' : 'Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AnnouncementColors.textTertiaryColor(widget.isDark),
      ),
      filled: true,
      fillColor: widget.isDark
          ? AnnouncementColors.darkSurface.withValues(alpha: 0.5)
          : AnnouncementColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: errorText != null
              ? AnnouncementColors.delete
              : AnnouncementColors.borderColor(widget.isDark),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: errorText != null
              ? AnnouncementColors.delete
              : AnnouncementColors.borderColor(widget.isDark),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
              color: errorText != null
                  ? AnnouncementColors.delete
                  : _accentColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorText: errorText,
    );
  }
}
