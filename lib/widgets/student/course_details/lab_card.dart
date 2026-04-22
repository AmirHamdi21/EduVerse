import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'package:intl/intl.dart';

class LabCard extends StatefulWidget {
  final Lab lab;
  final bool isDark;
  final VoidCallback? onViewSubmissionTap;
  final VoidCallback? onSubmitWorkTap;
  final VoidCallback? onResourcesTap;

  const LabCard({
    super.key,
    required this.lab,
    required this.isDark,
    this.onViewSubmissionTap,
    this.onSubmitWorkTap,
    this.onResourcesTap,
  });

  @override
  State<LabCard> createState() => _LabCardState();
}

class _LabCardState extends State<LabCard> with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _contentController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardController.forward();
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Color _getStatusColor(LabStatus status) {
    switch (status) {
      case LabStatus.graded:
        return const Color(0xFF008236);
      case LabStatus.submitted:
        return const Color(0xFF1447E6);
      case LabStatus.pending:
        return const Color(0xFFCA3500);
      case LabStatus.notStarted:
        return const Color(0xFF364153);
    }
  }

  Color _getStatusBgColor(LabStatus status) {
    switch (status) {
      case LabStatus.graded:
        return const Color(0xFFE0F8F0);
      case LabStatus.submitted:
        return const Color(0xFFEFF6FF);
      case LabStatus.pending:
        return const Color(0xFFFFEDD4);
      case LabStatus.notStarted:
        return const Color(0xFFF3F4F6);
    }
  }

  String _getStatusText(LabStatus status) {
    switch (status) {
      case LabStatus.graded:
        return widget.lab.gradePercentage != null
            ? 'Graded (${widget.lab.gradePercentage}%)'
            : 'Graded';
      case LabStatus.submitted:
        return 'Submitted';
      case LabStatus.pending:
        return 'Pending';
      case LabStatus.notStarted:
        return 'Not Started';
    }
  }

  String _formatDueDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);
    final statusColor = _getStatusColor(widget.lab.status);
    final statusBgColor = _getStatusBgColor(widget.lab.status);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF3D3D54)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lab.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arimo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.lab.description,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Arimo',
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(widget.lab.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Due Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${_formatDueDate(widget.lab.dueDate)}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons
                  Row(
                    children: [
                      if (widget.lab.status == LabStatus.graded ||
                          widget.lab.status == LabStatus.submitted) ...[
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: widget.isDark
                                    ? Color(0xFF8EC5FF)
                                    : Color(0xFF155DFC),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onViewSubmissionTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'View Submission',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Color(0xFF8EC5FF)
                                          : Color(0xFF155DFC),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: widget.isDark
                                    ? Color(0xffE5E7EB)
                                    : Color(0xFF364153),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onResourcesTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'Resources',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? Color(0xffE5E7EB)
                                          : Color(0xFF364153),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (widget.lab.status == LabStatus.pending) ...[
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF155DFC,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onSubmitWorkTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Submit Work',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Arimo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: const Color(0xFFD1D5DC),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onResourcesTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'Resources',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF155DFC,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onSubmitWorkTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Submit Work',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Arimo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD1D5DC),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onResourcesTap,
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'Resources',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
