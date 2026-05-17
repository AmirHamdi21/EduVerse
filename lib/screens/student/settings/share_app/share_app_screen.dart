import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../utils/navigation/safe_back.dart';
import '../../../../widgets/student/settings/share_app widgets/share_app_header.dart';
import '../../../../widgets/student/settings/share_app widgets/share_option_card.dart';

class ShareAppScreen extends StatefulWidget {
  const ShareAppScreen({super.key});

  @override
  State<ShareAppScreen> createState() => _ShareAppScreenState();
}

class _ShareAppScreenState extends State<ShareAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, l10n, isDark),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.1 : 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShareAppHeader(isDark: isDark, l10n: l10n),
                  SizedBox(height: isTablet ? 48 : 32),
                  _buildChooseMethodTitle(l10n, isDark),
                  const SizedBox(height: 20),
                  _buildShareOptions(context, l10n, isDark, isTablet),
                  const SizedBox(height: 32),
                  _buildOrDivider(l10n, isDark),
                  const SizedBox(height: 24),
                  _buildShareLinkSection(context, l10n, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          safeBack(context, '/dashboard');
        },
        icon: Icon(
          iosBackIcon(context),
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      title: Text(
        l10n.shareApp,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildChooseMethodTitle(AppLocalizations l10n, bool isDark) {
    return Text(
      l10n.chooseShareMethod,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildShareOptions(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isTablet,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isTablet) {
          return Row(
            children: [
              Expanded(
                child: ShareOptionCard(
                  icon: Icons.qr_code_2_rounded,
                  title: l10n.shareViaQrCode,
                  subtitle: l10n.shareViaQrCodeDesc,
                  gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/settings/share-app/qr');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShareOptionCard(
                  icon: Icons.android_rounded,
                  title: l10n.shareViaApk,
                  subtitle: l10n.shareViaApkDesc,
                  gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/settings/share-app/apk');
                  },
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            ShareOptionCard(
              icon: Icons.qr_code_2_rounded,
              title: l10n.shareViaQrCode,
              subtitle: l10n.shareViaQrCodeDesc,
              gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/settings/share-app/qr');
              },
            ),
            const SizedBox(height: 16),
            ShareOptionCard(
              icon: Icons.android_rounded,
              title: l10n.shareViaApk,
              subtitle: l10n.shareViaApkDesc,
              gradient: const [Color(0xFF10B981), Color(0xFF059669)],
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/settings/share-app/apk');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrDivider(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.orShareVia,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ],
    );
  }

  Widget _buildShareLinkSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    const downloadUrl = 'https://eduverse.app/download';

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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shareLink,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      downloadUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLinkButton(
                  icon: Icons.copy_rounded,
                  label: l10n.copyLink,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(const ClipboardData(text: downloadUrl));
                    _showSnackBar(context, l10n.linkCopied, isDark);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLinkButton(
                  icon: Icons.share_rounded,
                  label: l10n.shareLink,
                  isDark: isDark,
                  isPrimary: true,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await _shareLink(context, l10n);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary
          ? const Color(0xFF3B82F6)
          : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareLink(BuildContext context, AppLocalizations l10n) async {
    try {
      await Clipboard.setData(
        const ClipboardData(
          text:
              'Check out EduVerse - the AI-powered learning platform! Download it now: https://eduverse.app/download',
        ),
      );
      if (context.mounted) {
        _showSnackBar(
          context,
          l10n.linkCopied,
          context.watch<ThemeBloc>().state.isDark,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          l10n.shareError,
          context.watch<ThemeBloc>().state.isDark,
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
