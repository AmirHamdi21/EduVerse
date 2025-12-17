import 'package:flutter/material.dart';
import '../courses/course_model.dart';
import 'package:intl/intl.dart';

class AssignmentCard extends StatefulWidget {
  final Assignment assignment;
  final bool isDark;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.isDark,
  });

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard>
    with TickerProviderStateMixin {
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

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return const Color(0xFF008236);
      case AssignmentStatus.inProgress:
        return const Color(0xFFCA3500);
      case AssignmentStatus.notStarted:
        return const Color(0xFF364153);
    }
  }

  Color _getStatusBgColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return const Color(0xFFDCFCE7);
      case AssignmentStatus.inProgress:
        return const Color(0xFFFFEDD4);
      case AssignmentStatus.notStarted:
        return const Color(0xFFF3F4F6);
    }
  }

  String _getStatusText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.completed:
        return 'Completed';
      case AssignmentStatus.inProgress:
        return 'In Progress';
      case AssignmentStatus.notStarted:
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
    final statusColor = _getStatusColor(widget.assignment.status);
    final statusBgColor = _getStatusBgColor(widget.assignment.status);

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
                  // Title and Progress Percentage
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.assignment.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.assignment.progressPercentage}%',
                        style: const TextStyle(
                          color: Color(0xFF155DFC),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    widget.assignment.description,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Arimo',
                      height: 1.5,
                    ),
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
                        'Due: ${_formatDueDate(widget.assignment.dueDate)}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          widget.isDark
                              ? const Color(0xFF3D3D54)
                              : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                widget.isDark
                                    ? const Color(0xFF3D3D54)
                                    : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor:
                              widget.assignment.progressPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2B7FFF),
                                  Color(0xFF155DFC),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Questions Completed (if applicable)
                  if (widget.assignment.completedQuestions != null &&
                      widget.assignment.totalQuestions != null) ...[
                    Text(
                      '${widget.assignment.completedQuestions} of ${widget.assignment.totalQuestions} questions completed',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Arimo',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: widget.isDark
                                  ? const Color(0xFF8EC5FF)
                                  : const Color(0xFF155DFC),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility_outlined,
                                    size: 16,
                                    color: widget.isDark
                                        ? const Color(0xFF8EC5FF)
                                        : const Color(0xFF155DFC),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      color: widget.isDark
                                          ? const Color(0xFF8EC5FF)
                                          : const Color(0xFF155DFC),
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
                      const SizedBox(width: 8),
                      if (widget.assignment.status == AssignmentStatus.completed)
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
                                onTap: () {},
                                borderRadius: BorderRadius.circular(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.feedback_outlined,
                                      size: 16,
                                      color: textColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Feedback',
                                      style: TextStyle(
                                        color: textColor,
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
                        )
                      else
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2B7FFF),
                                  Color(0xFF155DFC),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF155DFC)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Submit',
                                      style: TextStyle(
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
