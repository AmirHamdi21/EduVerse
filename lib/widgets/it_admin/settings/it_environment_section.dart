import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_settings_barrel.dart';

class ITEnvironmentSection extends StatelessWidget {
  final bool isDark;
  final List<EnvironmentConfig> environments;
  final String selectedEnvironment;
  final Function(String) onEnvironmentSelected;
  final String statusMessage;

  const ITEnvironmentSection({
    super.key,
    required this.isDark,
    required this.environments,
    required this.selectedEnvironment,
    required this.onEnvironmentSelected,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ITColors.darkCard.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ITColors.accent,
          width: 1,
        ),
        boxShadow: ITColors.cardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildEnvironmentButtons(),
          const SizedBox(height: 16),
          _buildStatusBanner(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environment',
          style: TextStyle(
            color: ITColors.textPrimaryColor(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select environment to manage configurations',
          style: TextStyle(
            color: ITColors.textSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: environments.map((env) {
        final isSelected = env.id == selectedEnvironment;
        return _buildEnvironmentButton(env, isSelected);
      }).toList(),
    );
  }

  Widget _buildEnvironmentButton(EnvironmentConfig env, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onEnvironmentSelected(env.id),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [ITColors.success, Color(0xFF009966)],
                  )
                : null,
            color: isSelected
                ? null
                : isDark
                    ? ITColors.darkSurface
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? ITColors.darkBorder
                        : Colors.black.withValues(alpha: 0.1),
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ITColors.success.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                env.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : ITColors.textSecondaryColor(isDark),
              ),
              const SizedBox(width: 8),
              Text(
                env.name,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : ITColors.textPrimaryColor(isDark),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ITColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9F8CF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: ITColors.success,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusMessage,
              style: const TextStyle(
                color: Color(0xFF0D542B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
