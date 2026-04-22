import 'package:flutter/material.dart';

class StudentTodoItem extends StatefulWidget {
  final String title;
  final String dueDate;
  final bool isDark;
  final VoidCallback? onTap;

  const StudentTodoItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.isDark,
    this.onTap,
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
      onTap: widget.onTap,
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
            // Checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  isChecked = !isChecked;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked
                      ? const Color(0xFF155CFB)
                      : Colors.transparent,
                  border: Border.all(
                    color: isChecked
                        ? const Color(0xFF155CFB)
                        : (widget.isDark
                              ? Colors.white38
                              : const Color(0xFFD1D5DB)),
                    width: 2,
                  ),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
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
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      decorationColor: widget.isDark
                          ? Colors.white54
                          : Colors.black38,
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
            Icon(
              Icons.chevron_right,
              color: widget.isDark ? Colors.white54 : const Color(0xFF155CFB),
            ),
          ],
        ),
      ),
    );
  }
}
