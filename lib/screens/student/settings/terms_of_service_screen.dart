import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../generated_l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          l10n.termsOfService,
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
            title: '1. ${l10n.acceptanceOfTerms}',
            content: l10n.acceptanceOfTermsContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '2. ${l10n.useOfService}',
            content: l10n.useOfServiceContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '3. ${l10n.userAccounts}',
            content: l10n.userAccountsContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '4. ${l10n.intellectualProperty}',
            content: l10n.intellectualPropertyContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '5. ${l10n.userContent}',
            content: l10n.userContentContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '6. ${l10n.prohibitedActivities}',
            content: l10n.prohibitedActivitiesContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '7. ${l10n.termination}',
            content: l10n.terminationContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '8. ${l10n.disclaimers}',
            content: l10n.disclaimersContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '9. ${l10n.limitationOfLiability}',
            content: l10n.limitationOfLiabilityContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '10. ${l10n.changesToTerms}',
            content: l10n.changesToTermsContent,
          ),
          const SizedBox(height: 16),
          _buildSection(
            isDark,
            title: '11. ${l10n.contactUs}',
            content: l10n.contactUsContent,
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
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
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
                  Icons.article_rounded,
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
                      l10n.termsOfService,
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
            l10n.termsIntro,
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

  Widget _buildSection(bool isDark, {required String title, required String content}) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
