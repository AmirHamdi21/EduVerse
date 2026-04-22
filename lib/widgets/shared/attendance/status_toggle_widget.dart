import 'package:flutter/material.dart';

class StatusToggleWidget extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;
  final bool isDisabled;
  final bool isDark;

  const StatusToggleWidget({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.isDisabled = false,
    this.isDark = false,
  });

  static const List<_StatusOption> _options = <_StatusOption>[
    _StatusOption(
      key: 'present',
      label: 'Present',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF10B981),
    ),
    _StatusOption(
      key: 'absent',
      label: 'Absent',
      icon: Icons.cancel_rounded,
      color: Color(0xFFEF4444),
    ),
    _StatusOption(
      key: 'late',
      label: 'Late',
      icon: Icons.schedule_rounded,
      color: Color(0xFFF59E0B),
    ),
    _StatusOption(
      key: 'excused',
      label: 'Excused',
      icon: Icons.help_center_rounded,
      color: Color(0xFF0EA5E9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: _options.map((option) {
            final selected = currentStatus.toLowerCase() == option.key;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? option.color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? option.color.withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: isDisabled ? null : () => onChanged(option.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          option.icon,
                          size: 18,
                          color: selected
                              ? option.color
                              : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: selected
                              ? Padding(
                                  key: ValueKey<String>(option.key),
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: option.color,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _StatusOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
