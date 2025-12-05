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
}
