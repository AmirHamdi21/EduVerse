import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class InstructorQuickAccessGrid extends StatelessWidget {
  const InstructorQuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16213E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              _buildQuickAccessItem(
                context,
                title: l10n.myCourses,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF50A2FF), Color(0xFF155CFB)],
                ),
                icon: Icons.school_outlined,
                onTap: () {
                  context.push('/instructor/courses');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: l10n.assignments,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC17AFF), Color(0xFF980FFA)],
                ),
                icon: Icons.assignment_outlined,
                onTap: () {
                  context.push('/instructor/assignments');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: l10n.gradingCenter,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDC700), Color(0xFFD08700)],
                ),
                icon: Icons.grading_outlined,
                onTap: () {
                  context.push('/instructor/grading');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: l10n.uploadMaterial,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF05DF72), Color(0xFF00A63D)],
                ),
                icon: Icons.upload_file_outlined,
                onTap: () {
                  context.push('/instructor/upload-materials');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: 'Labs',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                icon: Icons.science_outlined,
                onTap: () {
                  context.push('/instructor/labs');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: l10n.analytics,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00D2F2), Color(0xFF0092B8)],
                ),
                icon: Icons.analytics_outlined,
                onTap: () {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text(l10n.analyticsComingSoon)),
                  // );
                  context.push('/instructor/reports');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: l10n.aiAssistant,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFB63B6), Color(0xFFE50076)],
                ),
                icon: Icons.psychology_outlined,
                onTap: () {
                  context.push('/ai-chat');
                },
              ),
              _buildQuickAccessItem(
                context,
                title: 'Discussions',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                ),
                icon: Icons.forum_outlined,
                onTap: () {
                  context.push('/instructor/discussions');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context, {
    required String title,
    required LinearGradient gradient,
    required IconData icon,
    required Function() onTap,
  }) {
    final isDark = context.read<ThemeBloc>().state.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF354152),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
