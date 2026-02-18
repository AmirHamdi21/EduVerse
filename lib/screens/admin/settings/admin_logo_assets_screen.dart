import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminLogoAssetsScreen extends StatefulWidget {
  const AdminLogoAssetsScreen({super.key});

  @override
  State<AdminLogoAssetsScreen> createState() => _AdminLogoAssetsScreenState();
}

class _AdminLogoAssetsScreenState extends State<AdminLogoAssetsScreen> {
  final List<_Asset> _assets = [
    _Asset(
      id: '1',
      name: 'Primary Logo',
      type: 'Logo',
      size: '256x256',
      format: 'PNG',
      url: null,
    ),
    _Asset(
      id: '2',
      name: 'Dark Mode Logo',
      type: 'Logo',
      size: '256x256',
      format: 'PNG',
      url: null,
    ),
    _Asset(
      id: '3',
      name: 'Favicon',
      type: 'Icon',
      size: '32x32',
      format: 'ICO',
      url: null,
    ),
    _Asset(
      id: '4',
      name: 'App Icon',
      type: 'Icon',
      size: '512x512',
      format: 'PNG',
      url: null,
    ),
    _Asset(
      id: '5',
      name: 'Login Background',
      type: 'Background',
      size: '1920x1080',
      format: 'JPG',
      url: null,
    ),
    _Asset(
      id: '6',
      name: 'Email Header',
      type: 'Email',
      size: '600x150',
      format: 'PNG',
      url: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsive = context.responsive;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Scaffold(
          backgroundColor: AdminColors.getBackgroundColor(isDark),
          appBar: _buildAppBar(isDark, l10n),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildInfoCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.logos, isDark),
                  SizedBox(height: responsive.p12),
                  ..._assets
                      .where((a) => a.type == 'Logo')
                      .map((a) => _buildAssetCard(a, isDark, l10n, responsive)),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.icons, isDark),
                  SizedBox(height: responsive.p12),
                  ..._assets
                      .where((a) => a.type == 'Icon')
                      .map((a) => _buildAssetCard(a, isDark, l10n, responsive)),
                  SizedBox(height: responsive.p24),
                  _buildSectionTitle(l10n.backgrounds, isDark),
                  SizedBox(height: responsive.p12),
                  ..._assets
                      .where((a) => a.type == 'Background' || a.type == 'Email')
                      .map((a) => _buildAssetCard(a, isDark, l10n, responsive)),
                  SizedBox(height: responsive.p32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AdminColors.getBackgroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      title: Text(
        l10n.logoAssets,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AdminColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.assetGuidelinesTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.assetGuidelinesDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: AdminColors.getTextSecondaryColor(isDark),
                  ),
                ),
              ],
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
    );
  }

  Widget _buildAssetCard(
      _Asset asset, bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      padding: EdgeInsets.all(responsive.p16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AdminColors.getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AdminColors.getDividerColor(isDark),
                style: BorderStyle.solid,
              ),
            ),
            child: asset.url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      File(asset.url!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noImage,
                        style: TextStyle(
                          fontSize: 10,
                          color: AdminColors.getTextTertiaryColor(isDark),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTag(asset.size, isDark),
                    const SizedBox(width: 8),
                    _buildTag(asset.format, isDark),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  asset.url != null ? l10n.uploaded : l10n.notUploaded,
                  style: TextStyle(
                    fontSize: 12,
                    color: asset.url != null
                        ? AdminColors.success
                        : AdminColors.getTextTertiaryColor(isDark),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _showUploadDialog(context, asset, l10n, isDark),
                icon: Icon(
                  Icons.upload_rounded,
                  color: AdminColors.primary,
                ),
                tooltip: l10n.upload,
              ),
              if (asset.url != null)
                IconButton(
                  onPressed: () {
                    setState(() => asset.url = null);
                    _showSnackBar(l10n.assetRemoved);
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AdminColors.error,
                  ),
                  tooltip: l10n.remove,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AdminColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AdminColors.primary,
        ),
      ),
    );
  }

  void _showUploadDialog(
      BuildContext context, _Asset asset, AppLocalizations l10n, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.getCardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AdminColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.upload_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              '${l10n.upload} ${asset.name}',
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AdminColors.getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AdminColors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AdminColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dragAndDrop,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.orClickToBrowse,
                    style: TextStyle(
                      fontSize: 12,
                      color: AdminColors.getTextSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.recommendedSize}: ${asset.size} • ${asset.format}',
              style: TextStyle(
                fontSize: 12,
                color: AdminColors.getTextTertiaryColor(isDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => asset.url = 'uploaded');
              Navigator.pop(context);
              _showSnackBar(l10n.assetUploaded);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.upload),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Asset {
  final String id;
  final String name;
  final String type;
  final String size;
  final String format;
  String? url;

  _Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.format,
    this.url,
  });
}
