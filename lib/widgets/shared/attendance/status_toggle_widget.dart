import 'package:flutter/material.dart';
import '../../../generated_l10n/app_localizations.dart';

class StatusToggleWidget extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;
  final bool isDisabled;
  final bool isDark;
  final Color? activeColor;
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? mutedColor;

  const StatusToggleWidget({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.isDisabled = false,
    this.isDark = false,
    this.activeColor,
    this.surfaceColor,
    this.borderColor,
    this.mutedColor,
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
    final l10n = AppLocalizations.of(context);
    final resolvedSurface =
        surfaceColor ??
        (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9));
    final resolvedBorder =
        borderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final resolvedMuted =
        mutedColor ??
        (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    final options = <_StatusOption>[
      _options[0].copyWith(label: l10n.present),
      _options[1].copyWith(label: l10n.absent),
      _options[2].copyWith(label: l10n.late),
      _options[3].copyWith(label: l10n.excused),
    ];

    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return Container(
            decoration: BoxDecoration(
              color: resolvedSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resolvedBorder),
            ),
            padding: const EdgeInsets.all(4),
            child: compact
                ? Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: options
                        .map(
                          (option) => SizedBox(
                            width: (constraints.maxWidth - 12) / 2,
                            child: _StatusChip(
                              option: option,
                              selected:
                                  currentStatus.toLowerCase() == option.key,
                              isDisabled: isDisabled,
                              mutedColor: resolvedMuted,
                              onChanged: onChanged,
                            ),
                          ),
                        )
                        .toList(),
                  )
                : Row(
                    children: options
                        .map(
                          (option) => Expanded(
                            child: _StatusChip(
                              option: option,
                              selected:
                                  currentStatus.toLowerCase() == option.key,
                              isDisabled: isDisabled,
                              mutedColor: resolvedMuted,
                              onChanged: onChanged,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.option,
    required this.selected,
    required this.isDisabled,
    required this.mutedColor,
    required this.onChanged,
  });

  final _StatusOption option;
  final bool selected;
  final bool isDisabled;
  final Color mutedColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: selected
            ? option.color.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? option.color.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDisabled ? null : () => onChanged(option.key),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 18,
                color: selected ? option.color : mutedColor,
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

  _StatusOption copyWith({String? label}) {
    return _StatusOption(
      key: key,
      label: label ?? this.label,
      icon: icon,
      color: color,
    );
  }
}
