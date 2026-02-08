import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/instructor/attendance_model.dart';
import 'attendance_colors.dart';

class StudentDetailSheet extends StatefulWidget {
  final StudentAttendance student;
  final bool isDark;
  final Function(String) onNoteSaved;
  final VoidCallback onClose;

  const StudentDetailSheet({
    super.key,
    required this.student,
    required this.isDark,
    required this.onNoteSaved,
    required this.onClose,
  });

  @override
  State<StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends State<StudentDetailSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _noteController;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.student.note ?? '');
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _saveNote() {
    setState(() => _isSaving = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onNoteSaved(_noteController.text);
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note saved successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AttendanceColors.present,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.student.studentName
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join();
    final colors = [
      AttendanceColors.primary,
      AttendanceColors.present,
      AttendanceColors.accent,
      AttendanceColors.late,
      AttendanceColors.teal,
    ];
    final color = colors[widget.student.studentName.hashCode % colors.length];

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: widget.isDark ? AttendanceColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AttendanceColors.darkBorder
                    : AttendanceColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.student.studentName,
                              style: TextStyle(
                                color: AttendanceColors.textPrimaryColor(
                                  widget.isDark,
                                ),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.student.studentId,
                              style: TextStyle(
                                color: AttendanceColors.textTertiaryColor(
                                  widget.isDark,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AttendanceColors.textSecondaryColor(
                            widget.isDark,
                          ),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: widget.isDark
                              ? AttendanceColors.darkSurface
                              : AttendanceColors.surface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Attendance Overview
                  _buildOverviewSection(color),
                  const SizedBox(height: 24),

                  // Add Note Section
                  _buildNoteSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(Color color) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final rate = widget.student.overallAttendanceRate;
    final progressColor = AttendanceColors.getProgressColor(rate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AttendanceColors.darkSurface.withValues(alpha: 0.5)
            : AttendanceColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? AttendanceColors.darkBorder.withValues(alpha: 0.3)
              : AttendanceColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Overview',
            style: TextStyle(
              color: AttendanceColors.textPrimaryColor(widget.isDark),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Rate',
                style: TextStyle(
                  color: AttendanceColors.textSecondaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(rate * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (widget.student.lastAttended != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Attended',
                  style: TextStyle(
                    color: AttendanceColors.textSecondaryColor(widget.isDark),
                    fontSize: 13,
                  ),
                ),
                Text(
                  dateFormat.format(widget.student.lastAttended!),
                  style: TextStyle(
                    color: AttendanceColors.textPrimaryColor(widget.isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Classes Attended',
                style: TextStyle(
                  color: AttendanceColors.textSecondaryColor(widget.isDark),
                  fontSize: 13,
                ),
              ),
              Text(
                '${widget.student.attendedClasses}/${widget.student.totalClasses}',
                style: TextStyle(
                  color: AttendanceColors.textPrimaryColor(widget.isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Note',
          style: TextStyle(
            color: AttendanceColors.textPrimaryColor(widget.isDark),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          style: TextStyle(
            color: AttendanceColors.textPrimaryColor(widget.isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note for this student...',
            hintStyle: TextStyle(
              color: AttendanceColors.textTertiaryColor(widget.isDark),
            ),
            filled: true,
            fillColor: widget.isDark
                ? AttendanceColors.darkSurface.withValues(alpha: 0.5)
                : AttendanceColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AttendanceColors.borderColor(widget.isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AttendanceColors.borderColor(widget.isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AttendanceColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveNote,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_isSaving ? 'Saving...' : 'Save Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AttendanceColors.primary,
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
