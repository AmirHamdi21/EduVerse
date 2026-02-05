import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          l10n.privacyPolicy,
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
          // Header Card
          _buildHeaderCard(isDark, l10n),
          const SizedBox(height: 24),

          // Sections
          _buildSection(
            isDark,
            title: '1. ${l10n.informationWeCollect}',
            content: l10n.informationWeCollectContent,
            icon: Icons.info_rounded,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '2. ${l10n.howWeUseInfo}',
            content: l10n.howWeUseInfoContent,
            icon: Icons.analytics_rounded,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '3. ${l10n.informationSharing}',
            content: l10n.informationSharingContent,
            icon: Icons.share_rounded,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '4. ${l10n.dataSecurity}',
            content: l10n.dataSecurityContent,
            icon: Icons.security_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '5. ${l10n.cookiesTracking}',
            content: l10n.cookiesTrackingContent,
            icon: Icons.cookie_rounded,
            color: const Color(0xFFEC4899),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '6. ${l10n.yourRights}',
            content: l10n.yourRightsContent,
            icon: Icons.gavel_rounded,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '7. ${l10n.childrenPrivacy}',
            content: l10n.childrenPrivacyContent,
            icon: Icons.child_care_rounded,
            color: const Color(0xFF14B8A6),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '8. ${l10n.internationalTransfers}',
            content: l10n.internationalTransfersContent,
            icon: Icons.public_rounded,
            color: const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '9. ${l10n.policyChanges}',
            content: l10n.policyChangesContent,
            icon: Icons.update_rounded,
            color: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '10. ${l10n.contactUs}',
            content: l10n.privacyContactContent,
            icon: Icons.contact_mail_rounded,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacyPolicy,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.lastUpdated('January 1, 2024'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.privacyIntro,
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

  Widget _buildSection(
    bool isDark, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
