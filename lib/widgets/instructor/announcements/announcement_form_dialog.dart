import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/instructor/announcement_model.dart';
import 'announcement_colors.dart';

class AnnouncementFormDialog extends StatefulWidget {
  final AnnouncementItem? announcement;
  final bool isDark;
  final Function(AnnouncementItem) onSave;
  final VoidCallback onCancel;

  const AnnouncementFormDialog({
    super.key,
    this.announcement,
    required this.isDark,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  
  bool _publishImmediately = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String _selectedAudience = 'All Students (120)';
  List<String> _attachments = [];
  bool _isLoading = false;
  String? _titleError;
  String? _contentError;

  final List<String> _audienceOptions = [
    'All Students (120)',
    'CS101 - Operating Systems (45)',
    'CS202 - Data Structures (38)',
    'CS305 - Database (52)',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _contentController = TextEditingController(text: widget.announcement?.content ?? '');
    
    if (widget.announcement != null) {
      _publishImmediately = widget.announcement!.status != AnnouncementStatus.scheduled;
      _scheduledDate = widget.announcement!.scheduledAt;
      if (_scheduledDate != null) {
        _scheduledTime = TimeOfDay.fromDateTime(_scheduledDate!);
      }
      _attachments = List.from(widget.announcement!.attachments);
    }
    
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  void _validateAndSave({required bool asDraft}) {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Title is required' : null;
      _contentError = _contentController.text.trim().isEmpty ? 'Content is required' : null;
    });

    if (_titleError != null || _contentError != null) return;

    if (!asDraft && !_publishImmediately && _scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a schedule date'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AnnouncementColors.scheduled,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final status = asDraft
          ? AnnouncementStatus.draft
          : (_publishImmediately ? AnnouncementStatus.published : AnnouncementStatus.scheduled);

      DateTime? scheduledAt;
      if (!_publishImmediately && _scheduledDate != null && _scheduledTime != null) {
        scheduledAt = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }

      final newAnnouncement = AnnouncementItem(
        id: widget.announcement?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        status: status,
        createdAt: widget.announcement?.createdAt ?? DateTime.now(),
        scheduledAt: scheduledAt,
        publishedAt: status == AnnouncementStatus.published ? DateTime.now() : null,
        audience: _selectedAudience.split('(').first.trim(),
        totalAudience: int.tryParse(
          _selectedAudience.split('(').last.replaceAll(')', '').trim(),
        ) ?? 120,
        readCount: widget.announcement?.readCount ?? 0,
        attachments: _attachments,
      );

      widget.onSave(newAnnouncement);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AnnouncementColors.primary,
              onPrimary: Colors.white,
              surface: widget.isDark ? AnnouncementColors.darkCard : Colors.white,
              onSurface: widget.isDark ? Colors.white : AnnouncementColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AnnouncementColors.primary,
              onPrimary: Colors.white,
              surface: widget.isDark ? AnnouncementColors.darkCard : Colors.white,
              onSurface: widget.isDark ? Colors.white : AnnouncementColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  void _addAttachment() {
    // Simulate file picker
    setState(() {
      _attachments.add('attachment_${_attachments.length + 1}.pdf');
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _useAIAssistant() {
    // Simulate AI generating content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('AI is generating content...'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AnnouncementColors.accent,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_titleController.text.isEmpty) {
        _titleController.text = 'Important Update for Students';
      }
      if (_contentController.text.isEmpty) {
        _contentController.text = 
            'Dear students,\n\nWe would like to inform you about an important update regarding your coursework. '
            'Please make sure to check your assignments and upcoming deadlines.\n\n'
            'If you have any questions, feel free to reach out during office hours.\n\n'
            'Best regards,\nYour Instructor';
      }
      setState(() {});
    });
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
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            color: widget.isDark ? AnnouncementColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
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
                      const SizedBox(height: 8),
                      _buildAIAssistantButton(),
                      const SizedBox(height: 16),
                      _buildContentField(),
                      const SizedBox(height: 20),
                      _buildAudienceSelector(),
                      const SizedBox(height: 20),
                      _buildScheduleSection(),
                      const SizedBox(height: 20),
                      _buildAttachmentsSection(),
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
                ? AnnouncementColors.darkBorder.withOpacity(0.3)
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
                  'Share important updates with your students',
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
          decoration: InputDecoration(
            hintText: 'Enter announcement title...',
            hintStyle: TextStyle(
              color: AnnouncementColors.textTertiaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: widget.isDark 
                ? AnnouncementColors.darkSurface.withOpacity(0.5)
                : AnnouncementColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _titleError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.borderColor(widget.isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _titleError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.borderColor(widget.isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _titleError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  Widget _buildAIAssistantButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _useAIAssistant,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AnnouncementColors.accent.withOpacity(0.1),
                AnnouncementColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AnnouncementColors.accent.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: AnnouncementColors.accent,
              ),
              const SizedBox(width: 10),
              Text(
                'AI Writing Assistant',
                style: TextStyle(
                  color: AnnouncementColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
          decoration: InputDecoration(
            hintText: 'Write your announcement here...',
            hintStyle: TextStyle(
              color: AnnouncementColors.textTertiaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: widget.isDark 
                ? AnnouncementColors.darkSurface.withOpacity(0.5)
                : AnnouncementColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _contentError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.borderColor(widget.isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _contentError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.borderColor(widget.isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _contentError != null 
                    ? AnnouncementColors.delete
                    : AnnouncementColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
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

  Widget _buildAudienceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audience',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark 
                ? AnnouncementColors.darkSurface.withOpacity(0.5)
                : AnnouncementColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AnnouncementColors.borderColor(widget.isDark),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAudience,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AnnouncementColors.textSecondaryColor(widget.isDark),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(14),
              dropdownColor: widget.isDark 
                  ? AnnouncementColors.darkCard
                  : Colors.white,
              items: _audienceOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      color: AnnouncementColors.textPrimaryColor(widget.isDark),
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAudience = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark 
            ? AnnouncementColors.darkSurface.withOpacity(0.3)
            : AnnouncementColors.primarySurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark 
              ? AnnouncementColors.darkBorder.withOpacity(0.3)
              : AnnouncementColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Publish Immediately',
                style: TextStyle(
                  color: AnnouncementColors.textPrimaryColor(widget.isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _publishImmediately,
                onChanged: (value) {
                  setState(() => _publishImmediately = value);
                },
                activeColor: AnnouncementColors.primary,
              ),
            ],
          ),
          if (!_publishImmediately) ...[
            const SizedBox(height: 16),
            _buildDateTimeRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeRow() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Date',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimePicker(
                icon: Icons.calendar_today_rounded,
                value: _scheduledDate != null 
                    ? dateFormat.format(_scheduledDate!)
                    : 'Select date',
                onTap: _selectDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimePicker(
                icon: Icons.access_time_rounded,
                value: _scheduledTime != null 
                    ? _scheduledTime!.format(context)
                    : 'Select time',
                onTap: _selectTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark 
                ? AnnouncementColors.darkCard
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AnnouncementColors.borderColor(widget.isDark),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AnnouncementColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: AnnouncementColors.textPrimaryColor(widget.isDark),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: TextStyle(
            color: AnnouncementColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark 
                ? AnnouncementColors.darkSurface.withOpacity(0.3)
                : AnnouncementColors.primarySurface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AnnouncementColors.primary.withOpacity(0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: AnnouncementColors.primary.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'Drag files here or tap to browse',
                style: TextStyle(
                  color: AnnouncementColors.textSecondaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addAttachment,
                icon: Icon(
                  Icons.attach_file_rounded,
                  size: 18,
                  color: AnnouncementColors.textSecondaryColor(widget.isDark),
                ),
                label: Text(
                  'Add Files',
                  style: TextStyle(
                    color: AnnouncementColors.textSecondaryColor(widget.isDark),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AnnouncementColors.borderColor(widget.isDark),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachments.asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDark 
                    ? AnnouncementColors.darkSurface
                    : AnnouncementColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AnnouncementColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: AnnouncementColors.textPrimaryColor(widget.isDark),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeAttachment(entry.key),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AnnouncementColors.delete,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _validateAndSave(asDraft: true),
            icon: _isLoading 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Draft'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AnnouncementColors.textSecondaryColor(widget.isDark),
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
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _validateAndSave(asDraft: false),
            icon: _isLoading 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    _publishImmediately ? Icons.send_rounded : Icons.schedule_rounded,
                    size: 18,
                  ),
            label: Text(_publishImmediately ? 'Publish' : 'Schedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AnnouncementColors.primary,
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
}
