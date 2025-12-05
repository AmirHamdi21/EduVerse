import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/language/language_cubit.dart';
import '../../../generated_l10n/app_localizations.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Drawer(
          backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
          child: Column(
            children: [
              SizedBox(height: 30),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF50A2FF), Color(0xFF155CFB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF101727),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard,
                      title: l10n.dashboard,
                      isDark: isDark,
                      isSelected: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.menu_book_outlined,
                      title: l10n.courses,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_today,
                      title: l10n.calendar,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.grade,
                      title: l10n.grades,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.message,
                      title: l10n.messages,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.smart_toy,
                      title: l10n.aiAssistant,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.messenger_outline_rounded,
                      title: l10n.messages,
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: const Divider(
                        thickness: 1,
                        color: Color(0xFF155CFB),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person,
                      title: l10n.profile,
                      isDark: isDark,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      title: l10n.settings,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // AI Assistant Card at bottom
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2B7FFF), Color(0xFF155CFB)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.aiAssistant,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getPersonalizedStudyHelp,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF155CFB),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(l10n.askAI),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                  ? const Color(0xFF155CFB).withOpacity(0.2)
                  : const Color(0xFF155CFB).withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? const Color(0xFF155CFB)
              : (isDark ? Colors.white70 : const Color(0xFF495565)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF155CFB)
                : (isDark ? Colors.white : const Color(0xFF101727)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
