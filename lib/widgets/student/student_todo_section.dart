import 'package:edu_verse/widgets/student/student_todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../generated_l10n/app_localizations.dart';

class StudentTodoSection extends StatelessWidget {
  const StudentTodoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.toDoSmartReminders,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF101727),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            StudentTodoItem(
              title: l10n.algorithmAssignment,
              dueDate: '${l10n.due}: Nov 8, 2025',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            StudentTodoItem(
              title: l10n.aiEthicsPaperOutline,
              dueDate: '${l10n.due}: Nov 9, 2025',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            StudentTodoItem(
              title: l10n.prepareDataStructuresQuiz,
              dueDate: '${l10n.due}: Nov 10, 2025',
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  // Widget _buildTodoItem({
  //   required String title,
  //   required String dueDate,
  //   required bool isDark,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF16213E) : Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(
  //         color: isDark
  //             ? Colors.white.withOpacity(0.1)
  //             : const Color(0xFFE5E7EB),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         // Checkbox or indicator can be added here
  //         // For example:
  //         Checkbox(
  //           value: true,
  //           onChanged: (bool? newValue) {},
  //           activeColor: const Color(0xFF155CFB),
  //           checkColor: Colors.white,
  //         ),
  //         // Container(
  //         //   width: 20,
  //         //   height: 20,
  //         //   decoration: BoxDecoration(
  //         //     border: Border.all(color: const Color(0xFF155CFB), width: 2),
  //         //     borderRadius: BorderRadius.circular(6),
  //         //   ),
  //         // ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: isDark ? Colors.white : const Color(0xFF101727),
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 dueDate,
  //                 style: TextStyle(
  //                   color: isDark ? Colors.white70 : const Color(0xFF495565),
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const Icon(Icons.chevron_right, color: Color(0xFF155CFB)),
  //       ],
  //     ),
  //   );
  // }
}
