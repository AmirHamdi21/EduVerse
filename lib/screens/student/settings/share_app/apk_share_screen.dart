import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../services/app_share_service.dart';
import '../../../../utils/navigation/safe_back.dart';

class ApkShareScreen extends StatefulWidget {
  const ApkShareScreen({super.key});

  @override
  State<ApkShareScreen> createState() => _ApkShareScreenState();
}

class _ApkShareScreenState extends State<ApkShareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSharing = false;
  String _apkSize = '~50 MB';
  bool _isAndroid = false;

  @override
  void initState() {
    super.initState();
    _isAndroid = Platform.isAndroid;
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
    _loadApkSize();
  }

  Future<void> _loadApkSize() async {
    final size = await AppShareService.getApkSize();
    if (mounted) {
      setState(() => _apkSize = size);
    }
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
                horizontal: isTablet ? size.width * 0.15 : 24,
                vertical: 24,
              ),
              child: Column(
                children: [
                  _buildHeader(l10n, isDark),
                  const SizedBox(height: 32),
                  if (!_isAndroid) ...[
                    _buildPlatformWarning(l10n, isDark),
                    const SizedBox(height: 24),
                  ],
                  _buildApkInfoCard(l10n, isDark),
                  const SizedBox(height: 24),
                  _buildInstructions(l10n, isDark),
                  const SizedBox(height: 24),
                  _buildInstallationNote(l10n, isDark),
                  const SizedBox(height: 32),
                  _buildShareButton(context, l10n, isDark),
                  const SizedBox(height: 16),
                  _buildAlternativeSection(context, l10n, isDark),
                  const SizedBox(height: 24),
                  _buildBackButton(context, l10n, isDark),
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
        l10n.apkShareTitle,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.android_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.shareViaApk,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.apkShareSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlatformWarning(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.androidOnly,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApkInfoCard(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_zip_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EduVerse.apk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.apkSize}: $_apkSize',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.verified_rounded,
                  label: 'v1.0.0',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.android_rounded,
                  label: l10n.requiresAndroid,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.green[600],
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.apkShareInstructions,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallationNote(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.08)
            : Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.installationNote,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.amber[300] : Colors.amber[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _isAndroid
            ? const Color(0xFF10B981)
            : (isDark ? Colors.grey[700] : Colors.grey[400]),
        borderRadius: BorderRadius.circular(16),
        elevation: _isAndroid ? 4 : 0,
        shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
        child: InkWell(
          onTap: _isAndroid && !_isSharing ? _shareApk : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSharing)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSharing ? l10n.preparingApk : l10n.shareApkFile,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAlternativeButton(
                icon: Icons.qr_code_2_rounded,
                label: l10n.shareViaQrCode,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                  context.push('/settings/share-app/qr');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlternativeButton(
                icon: Icons.link_rounded,
                label: l10n.shareLink,
                isDark: isDark,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await AppShareService.shareDownloadLink();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlternativeButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return TextButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        safeBack(context, '/dashboard');
      },
      icon: Icon(
        iosBackIcon(context),
        size: 18,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      label: Text(
        l10n.backToOptions,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }

  Future<void> _shareApk() async {
    if (_isSharing || !_isAndroid) return;

    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await AppShareService.shareAppApk();
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (result.status.name == 'success' ||
            result.status.name == 'dismissed') {
          _showSnackBar(l10n.apkShared, true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).apkShareFailed, false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    final isDark = context.read<ThemeBloc>().state.isDark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess
            ? Colors.green[600]
            : (isDark ? const Color(0xFF1E293B) : Colors.red[600]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
