import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../bloc/theme/theme_bloc.dart';
import '../../../../generated_l10n/app_localizations.dart';
import '../../../../services/app_share_service.dart';
import '../../../../utils/navigation/safe_back.dart';

class QrCodeShareScreen extends StatefulWidget {
  const QrCodeShareScreen({super.key});

  @override
  State<QrCodeShareScreen> createState() => _QrCodeShareScreenState();
}

class _QrCodeShareScreenState extends State<QrCodeShareScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _qrKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSharing = false;
  bool _isSaving = false;
  double _qrSize = 220;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
              _buildQrCodeContainer(l10n, isDark),
              const SizedBox(height: 24),
              _buildQrSizeSlider(l10n, isDark),
              const SizedBox(height: 32),
              _buildInstructions(l10n, isDark),
              const SizedBox(height: 32),
              _buildActionButtons(context, l10n, isDark),
              const SizedBox(height: 24),
              _buildBackButton(context, l10n, isDark),
            ],
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
        l10n.qrCodeShareTitle,
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
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.scanToDownload,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.qrCodeShareSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQrCodeContainer(AppLocalizations l10n, bool isDark) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RepaintBoundary(
        key: _qrKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              QrImageView(
                data: AppShareService.downloadUrl,
                version: QrVersions.auto,
                size: _qrSize,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1E293B),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1E293B),
                ),
                embeddedImage: null,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'EduVerse',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrSizeSlider(AppLocalizations l10n, bool isDark) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.qrSize,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _qrSize = 220);
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  l10n.resetQr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _qrSize,
              min: 150,
              max: 300,
              onChanged: (value) {
                setState(() => _qrSize = value);
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.blue.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.blue[600],
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.qrCodeInstructions,
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

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_rounded,
            label: l10n.shareQrCode,
            isLoading: _isSharing,
            isDark: isDark,
            isPrimary: true,
            onTap: _shareQrCode,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.save_alt_rounded,
            label: l10n.saveQrCode,
            isLoading: _isSaving,
            isDark: isDark,
            onTap: _saveQrCode,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required bool isDark,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary
          ? const Color(0xFF6366F1)
          : (isDark ? const Color(0xFF1E293B) : Colors.white),
      borderRadius: BorderRadius.circular(14),
      elevation: isPrimary ? 4 : 0,
      shadowColor: isPrimary
          ? const Color(0xFF6366F1).withValues(alpha: 0.4)
          : Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isPrimary
                ? null
                : Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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

  Future<void> _shareQrCode() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await AppShareService.shareQrCode(_qrKey);
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).qrCodeShared, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).shareError, false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _saveQrCode() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final path = await AppShareService.saveQrCode(_qrKey);
      if (mounted) {
        if (path != null) {
          _showSnackBar(AppLocalizations.of(context).qrCodeSaved, true);
        } else {
          _showSnackBar(AppLocalizations.of(context).shareError, false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).shareError, false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
            Text(message),
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
