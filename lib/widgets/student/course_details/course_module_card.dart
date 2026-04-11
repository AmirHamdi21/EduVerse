import 'package:flutter/material.dart';
import '../courses/course_model.dart';

class CourseModuleCard extends StatefulWidget {
  final CourseModule module;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isDark;

  const CourseModuleCard({
    super.key,
    required this.module,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.isDark,
  });

  @override
  State<CourseModuleCard> createState() => _CourseModuleCardState();
}

class _CourseModuleCardState extends State<CourseModuleCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _contentBadgeAnimation;
  // ignore: unused_field
  late Animation<double> _durationAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _descriptionAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _contentBadgeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _durationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(CourseModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Color _getStatusColor(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return const Color(0xFF008236);
      case ModuleStatus.inProgress:
        return const Color(0xFFCA3500);
      case ModuleStatus.notStarted:
        return const Color(0xFF364153);
    }
  }

  Color _getStatusBgColor(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return const Color(0xFFDCFCE7);
      case ModuleStatus.inProgress:
        return const Color(0xFFFFEDD4);
      case ModuleStatus.notStarted:
        return const Color(0xFFF3F4F6);
    }
  }

  String _getStatusText(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return 'Completed';
      case ModuleStatus.inProgress:
        return 'In Progress';
      case ModuleStatus.notStarted:
        return 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark ? const Color(0xFF2D2D44) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF101828);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF4A5565);
    final statusColor = _getStatusColor(widget.module.status);
    final statusBgColor = _getStatusBgColor(widget.module.status);

    return Container(
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
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggleExpand,
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: widget.isExpanded ? 0 : 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Arimo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(widget.module.status),
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
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onToggleExpand,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark
                            ? const Color(0xFF3D3D54)
                            : const Color(0xFFF3F4F6),
                      ),
                      child: AnimatedRotation(
                        turns: widget.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  FadeTransition(
                    opacity: _descriptionAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _expandController,
                              curve: const Interval(
                                0.0,
                                0.3,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Text(
                        widget.module.description,
                        style: TextStyle(
                          color: widget.isDark
                              ? Color(0xffD1D5DC)
                              : const Color(0xFF4A5565),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Arimo',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Content types
                  FadeTransition(
                    opacity: _contentBadgeAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _expandController,
                              curve: const Interval(
                                0.2,
                                0.5,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Column(
                        children: [
                          Row(
                            spacing: 16,
                            children: [
                              _buildContentBadge(
                                'Video',
                                Icons.play_circle_outline,
                              ),
                              if (widget.module.contents.any(
                                (c) => c.type == 'pdf',
                              ))
                                _buildContentBadge(
                                  'PDF',
                                  Icons.description_outlined,
                                ),
                              if (widget.module.contents.any(
                                (c) => c.type == 'slides',
                              ))
                                _buildContentBadge('Slides', Icons.slideshow),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '45 min',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Arimo',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            height: 1,
                            color: widget.isDark
                                ? const Color(0xFF3D3D54)
                                : const Color(0xFFE5E7EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // AI Summarize button
                  FadeTransition(
                    opacity: _buttonAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _expandController,
                              curve: const Interval(
                                0.6,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(
                            color: const Color(0xFFBEDBFF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: const Color(0xFF155DFC),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Summarize with AI',
                              style: TextStyle(
                                color: Color(0xFF155DFC),
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentBadge(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF155DFC)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF155DFC),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Arimo',
          ),
        ),
      ],
    );
  }
}
