// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../bloc/theme/theme_bloc.dart';
// import '../../../bloc/theme/theme_state.dart';
// import '../../../generated_l10n/app_localizations.dart';

// class StudentStatsSection extends StatelessWidget {
//   const StudentStatsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeBloc, ThemeState>(
//       buildWhen: (previous, current) => previous.isDark != current.isDark,
//       builder: (context, themeState) {
//         final isDark = themeState.isDark;
//         final l10n = AppLocalizations.of(context);

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Compact 2x2 Stats Grid
//             Row(
//               children: [
//                 Expanded(
//                   child: _CompactStatCard(
//                     title: l10n.gpa,
//                     value: '3.62',
//                     maxValue: 4.0,
//                     isDark: isDark,
//                     icon: Icons.school_rounded,
//                     gradientColors: const [
//                       Color(0xFF8B5CF6),
//                       Color(0xFF6366F1),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _CompactStatCard(
//                     title: l10n.attendance,
//                     value: '100',
//                     maxValue: 100,
//                     isDark: isDark,
//                     icon: Icons.check_circle_rounded,
//                     gradientColors: const [
//                       Color(0xFF10B981),
//                       Color(0xFF059669),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _CompactStatCard(
//                     title: l10n.semesterProgress,
//                     value: '67',
//                     maxValue: 100,
//                     isDark: isDark,
//                     icon: Icons.trending_up_rounded,
//                     gradientColors: const [
//                       Color(0xFF3B82F6),
//                       Color(0xFF2563EB),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _DeadlineCard(
//                     date: 'Mar 12',
//                     courseName: '${l10n.calculusII} ${l10n.exam}',
//                     isDark: isDark,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _CompactStatCard extends StatefulWidget {
//   final String title;
//   final String value;
//   final double maxValue;
//   final bool isDark;
//   final IconData icon;
//   final List<Color> gradientColors;

//   const _CompactStatCard({
//     required this.title,
//     required this.value,
//     required this.maxValue,
//     required this.isDark,
//     required this.icon,
//     required this.gradientColors,
//   });

//   @override
//   State<_CompactStatCard> createState() => _CompactStatCardState();
// }

// class _CompactStatCardState extends State<_CompactStatCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _progressAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );
//     _progressAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     );
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final numericValue = double.parse(widget.value);
//     final progressValue = numericValue / widget.maxValue;
//     final isMaxed = progressValue >= 1.0;

//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         height: 115,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: widget.isDark
//                 ? widget.gradientColors[0].withValues(alpha: 0.15)
//                 : widget.gradientColors[0].withValues(alpha: 0.12),
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: widget.gradientColors[0].withValues(alpha: 0.08),
//               blurRadius: 16,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: widget.gradientColors,
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(widget.icon, color: Colors.white, size: 18),
//                 ),
//                 if (isMaxed)
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF10B981).withValues(alpha: 0.15),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.stars_rounded,
//                       color: Color(0xFF10B981),
//                       size: 14,
//                     ),
//                   ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               widget.value,
//               style: TextStyle(
//                 color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
//                 fontSize: 26,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: -1,
//                 height: 1,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.title,
//                     style: TextStyle(
//                       color: widget.isDark
//                           ? Colors.white60
//                           : const Color(0xFF64748B),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 AnimatedBuilder(
//                   animation: _progressAnimation,
//                   builder: (context, child) {
//                     return Text(
//                       '${(progressValue * 100 * _progressAnimation.value).toInt()}%',
//                       style: TextStyle(
//                         color: widget.gradientColors[0],
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DeadlineCard extends StatefulWidget {
//   final String date;
//   final String courseName;
//   final bool isDark;

//   const _DeadlineCard({
//     required this.date,
//     required this.courseName,
//     required this.isDark,
//   });

//   @override
//   State<_DeadlineCard> createState() => _DeadlineCardState();
// }

// class _DeadlineCardState extends State<_DeadlineCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         height: 115,
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: widget.isDark
//                 ? [
//                     const Color(0xFFEF4444).withValues(alpha: 0.15),
//                     const Color(0xFFDC2626).withValues(alpha: 0.1),
//                   ]
//                 : [
//                     const Color(0xFFEF4444).withValues(alpha: 0.08),
//                     const Color(0xFFFEE2E2),
//                   ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: const Color(
//               0xFFEF4444,
//             ).withValues(alpha: widget.isDark ? 0.3 : 0.2),
//             width: 1.5,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(
//                     Icons.access_time_rounded,
//                     color: Colors.white,
//                     size: 18,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEF4444).withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.date,
//                     style: const TextStyle(
//                       color: Color(0xFFEF4444),
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Deadline',
//                   style: TextStyle(
//                     color: widget.isDark
//                         ? Colors.white60
//                         : const Color(0xFF64748B),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   widget.courseName,
//                   style: TextStyle(
//                     color: widget.isDark
//                         ? Colors.white
//                         : const Color(0xFF0F172A),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     height: 1.2,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
/* other design */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class StudentStatsSection extends StatelessWidget {
  const StudentStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) => previous.isDark != current.isDark,
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Stats Grid (2x2)
            Row(
              children: [
                Expanded(
                  child: _CompactStatCard(
                    title: l10n.gpa,
                    value: '3.62',
                    maxValue: 4.0,
                    isDark: isDark,
                    icon: Icons.school_rounded,
                    gradientColors: const [
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                    onTap: () => context.push('/grades'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactStatCard(
                    title: l10n.attendance,
                    value: '100',
                    maxValue: 100,
                    isDark: isDark,
                    icon: Icons.check_circle_rounded,
                    gradientColors: const [
                      Color(0xFF10B981),
                      Color(0xFF059669),
                    ],
                    onTap: () => context.push('/attendance'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Semester Progress - Full Width with Visual Progress
            _ProgressCard(
              title: l10n.semesterProgress,
              value: 67,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Upcoming Deadline - Compact & Actionable
            _CompactDeadlineCard(
              title: l10n.upcomingDeadline,
              date: 'Mar 12',
              year: '2026',
              courseName: '${l10n.calculusII} ${l10n.exam}',
              isDark: isDark,
              onTap: () => context.push('/tasks'),
            ),
          ],
        );
      },
    );
  }
}

/// Compact stat card with circular progress indicator
class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double maxValue;
  final bool isDark;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.maxValue,
    required this.isDark,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numericValue = double.parse(value);
    final progressValue = numericValue / maxValue;
    final isMaxed = progressValue >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    gradientColors[0].withValues(alpha: 0.15),
                    gradientColors[1].withValues(alpha: 0.1),
                  ]
                : [
                    gradientColors[0].withValues(alpha: 0.08),
                    gradientColors[1].withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? gradientColors[0].withValues(alpha: 0.2)
                : gradientColors[0].withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (isMaxed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progressValue * 100).toInt()}%',
                  style: TextStyle(
                    color: gradientColors[0],
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width progress card with horizontal bar
class _ProgressCard extends StatelessWidget {
  final String title;
  final int value;
  final bool isDark;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: value >= 80
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : value >= 50
                        ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (value >= 80
                                  ? const Color(0xFF10B981)
                                  : value >= 50
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFF59E0B))
                              .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$value%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AnimatedProgressBar(value: value / 100, isDark: isDark),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Started',
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Complete',
                style: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated horizontal progress bar
class _AnimatedProgressBar extends StatefulWidget {
  final double value;
  final bool isDark;

  const _AnimatedProgressBar({required this.value, required this.isDark});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: value >= 0.8
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : value >= 0.5
                          ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                          : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (value >= 0.8
                                    ? const Color(0xFF10B981)
                                    : value >= 0.5
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact deadline card with better visual hierarchy
class _CompactDeadlineCard extends StatelessWidget {
  final String title;
  final String date;
  final String year;
  final String courseName;
  final bool isDark;
  final VoidCallback? onTap;

  const _CompactDeadlineCard({
    required this.title,
    required this.date,
    required this.year,
    required this.courseName,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFFEF4444).withValues(alpha: 0.12),
                    const Color(0xFFDC2626).withValues(alpha: 0.08),
                  ]
                : [
                    const Color(0xFFEF4444).withValues(alpha: 0.06),
                    const Color(0xFFFEE2E2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(
              0xFFEF4444,
            ).withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    year,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFFEF4444),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    courseName,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : const Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
