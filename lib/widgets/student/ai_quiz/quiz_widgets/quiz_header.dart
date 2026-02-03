import 'package:flutter/material.dart';
import 'package:edu_verse/common/utils/responsive.dart';

class QuizHeader extends StatelessWidget {
  final String courseName;
  final int currentQuestion;
  final int totalQuestions;
  final bool isDark;
  final VoidCallback onClose;
  final VoidCallback onQuestionNavigator;

  const QuizHeader({
    super.key,
    required this.courseName,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.isDark,
    required this.onClose,
    required this.onQuestionNavigator,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.p16,
        vertical: responsive.p12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Close button
            _buildIconButton(
              icon: Icons.close_rounded,
              onTap: onClose,
              isDark: isDark,
            ),
            SizedBox(width: responsive.p12),
            
            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    courseName,
                    style: TextStyle(
                      fontSize: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      fontFamily: 'Arimo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Question $currentQuestion of $totalQuestions',
                    style: TextStyle(
                      fontSize: responsive.fontSize12,
                      color: isDark 
                          ? const Color(0xFF9CA3AF) 
                          : const Color(0xFF6B7280),
                      fontFamily: 'Arimo',
                    ),
                  ),
                ],
              ),
            ),
            
            // Question navigator button
            _buildNavigatorButton(context, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF2D2D44) 
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF6B7280),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNavigatorButton(BuildContext context, ResponsiveUtil responsive) {
    return GestureDetector(
      onTap: onQuestionNavigator,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.p12,
          vertical: responsive.p8,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '$currentQuestion/$totalQuestions',
              style: TextStyle(
                fontSize: responsive.fontSize12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Arimo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
