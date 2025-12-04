import 'package:flutter/material.dart';

class StudentTodoItem extends StatefulWidget {
  final String title;
  final String dueDate;
  final bool isDark;
  const StudentTodoItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.isDark,
  });

  @override
  State<StudentTodoItem> createState() => _StudentTodoItemState();
}

class _StudentTodoItemState extends State<StudentTodoItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        // Handle item tap if needed
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            // Checkbox or indicator can be added here
            // For example:
            Checkbox(
              shape: CircleBorder(),
              value: isChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isChecked = newValue ?? false;
                });
              },
              activeColor: const Color(0xFF155CFB),
              checkColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF101727),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.dueDate,
                    style: TextStyle(
                      color: widget.isDark
                          ? Colors.white70
                          : const Color(0xFF495565),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF155CFB)),
          ],
        ),
      ),
    );
  }
}
