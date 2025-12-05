import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:edu_verse/widgets/common/animated_circular_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../widgets/common/animated_progress_bar.dart';
import 'course_model.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;
  final Animation<double>? animation;

  const CourseCard({super.key, required this.course, this.animation});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return SlideTransition(
          position:
              widget.animation?.drive(
                Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ) ??
              AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity:
                widget.animation?.drive(
                  Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ) ??
                AlwaysStoppedAnimation(1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16213E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFFD1D5DC),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseHeader(isDark),
                    const SizedBox(height: 24),
                    _buildProgressSection(isDark),
                    const SizedBox(height: 24),
                    _buildActionButtons(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.course.iconBackgroundColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.course.courseIcon,
            color: widget.course.iconBackgroundColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.course.title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.course.instructor,
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF4A5565),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.course.nextEvent,
                style: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF6A7282),
                  fontSize: 12,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // CircularProgressIndicator(
        //   value: widget.course.progress,
        //   strokeWidth: 3,

        //   valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF155DFC)),
        // ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: 72,
              height: 72,
              // child: CircularProgressIndicator(
              //   value: widget.course.progress, // 0.0 to 1.0
              //   strokeWidth: 4,
              //   backgroundColor: isDark
              //       ? Colors.white10
              //       : const Color(0xFFE0E7FF),
              //   valueColor: AlwaysStoppedAnimation<Color>(
              //     isDark ? const Color(0xff8EC5FF) : const Color(0xFF155DFC),
              //   ),
              // ),
              child: AnimatedCircularBar(
                value: widget.course.progress,
                backgroundColor: isDark
                    ? Colors.white10
                    : const Color(0xFFE0E7FF),
                valueColor: isDark
                    ? const Color(0xff8EC5FF)
                    : const Color(0xFF155DFC),
                minHeight: 4,
                duration: const Duration(milliseconds: 1500),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: isDark ? Colors.white10 : const Color(0xFFF0F4FF),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE0E7FF),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${(widget.course.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xff8EC5FF)
                        : const Color(0xFF155DFC),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(widget.course.progress * 100).toInt()}% ' + l10n.completed,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF4A5565),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.course.eventDate,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF4A5565),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CompactAnimatedProgressBar(
          value: widget.course.progress,
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFFE5E7EB),
          valueColor: const Color(0xFF155DFC),
          minHeight: 6,
          duration: const Duration(milliseconds: 1500),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF155DFC).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.course.onPrimaryButtonPressed ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                widget.course.primaryButtonLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.course.onSecondaryButtonPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF155DFC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : const Color(0xFF155DFC),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Materials',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
