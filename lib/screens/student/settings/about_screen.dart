import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_verse/utils/navigation/safe_back.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => safeBack(context, '/dashboard'),
          icon: Icon(
            iosBackIcon(context),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.about,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // App Info Card
          _buildAppInfoCard(isDark, l10n),
          const SizedBox(height: 24),

          // Links
          _buildSectionTitle(l10n.legal, isDark),
          const SizedBox(height: 12),
          _buildLinksCard(isDark, l10n, context),
          const SizedBox(height: 24),

          // Team
          _buildSectionTitle(l10n.team, isDark),
          const SizedBox(height: 12),
          _buildTeamCard(isDark),
          const SizedBox(height: 24),

          // Social
          _buildSocialCard(isDark, l10n),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              '© 2024 EduVerse. ${l10n.allRightsReserved}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.school_rounded,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'EduVerse',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLinksCard(
    bool isDark,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    final links = [
      (Icons.description_rounded, l10n.termsOfService, '/settings/terms'),
      (
        Icons.privacy_tip_rounded,
        l10n.privacyPolicy,
        '/settings/privacy-policy',
      ),
      (Icons.gavel_rounded, l10n.licenses, ''),
      (Icons.feedback_rounded, l10n.sendFeedback, ''),
      (Icons.star_rounded, l10n.rateApp, ''),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: links.asMap().entries.map((entry) {
          final index = entry.key;
          final link = entry.value;
          final isLast = index == links.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  if (link.$3.isNotEmpty) {
                    context.push(link.$3);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          link.$1,
                          size: 20,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          link.$2,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  color: isDark ? Colors.white12 : Colors.black12,
                  height: 1,
                  indent: 60,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeamCard(bool isDark) {
    final team = [
      ('Ahmed Mohamed', 'Lead Developer', '👨‍💻'),
      ('Sara Hassan', 'UI/UX Designer', '🎨'),
      ('Omar Ali', 'Backend Engineer', '⚙️'),
      ('Fatma Ahmed', 'QA Engineer', '🔍'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: team.map((member) {
              return Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.$3,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.$1.split(' ')[0],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    member.$2.split(' ')[0],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard(bool isDark, AppLocalizations l10n) {
    final socials = [
      (Icons.language_rounded, 'Website', const Color(0xFF3B82F6)),
      (Icons.play_circle_filled_rounded, 'YouTube', const Color(0xFFEF4444)),
      (Icons.camera_alt_rounded, 'Instagram', const Color(0xFF8B5CF6)),
      (Icons.alternate_email_rounded, 'Twitter', const Color(0xFF0EA5E9)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.followUs,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: socials.map((social) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: social.$3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(social.$1, size: 28, color: social.$3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
