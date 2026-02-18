import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminApiSettingsScreen extends StatefulWidget {
  const AdminApiSettingsScreen({super.key});

  @override
  State<AdminApiSettingsScreen> createState() => _AdminApiSettingsScreenState();
}

class _AdminApiSettingsScreenState extends State<AdminApiSettingsScreen> {
  final List<_ApiKey> _apiKeys = [
    _ApiKey(
      id: '1',
      name: 'Production API Key',
      key: 'pk_live_xxxxxxxxxxxxxxxxxxxxxx',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
      permissions: ['read', 'write'],
      isActive: true,
    ),
    _ApiKey(
      id: '2',
      name: 'Development API Key',
      key: 'pk_test_xxxxxxxxxxxxxxxxxxxxxx',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastUsed: DateTime.now().subtract(const Duration(days: 2)),
      permissions: ['read'],
      isActive: true,
    ),
    _ApiKey(
      id: '3',
      name: 'Mobile App Key',
      key: 'pk_mobile_xxxxxxxxxxxxxxxxxxxxxx',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastUsed: DateTime.now().subtract(const Duration(minutes: 30)),
      permissions: ['read', 'write', 'delete'],
      isActive: true,
    ),
  ];

  bool _apiEnabled = true;
  int _rateLimit = 1000;
  int _rateLimitWindow = 60;

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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateKeyDialog(context, isDark, l10n),
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.generateApiKey),
          ),
          body: SafeArea(
            child: Container(
              decoration: isDark
                  ? null
                  : BoxDecoration(gradient: AdminColors.lightBackgroundGradient),
              child: ListView(
                padding: responsive.contentPadding,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildStatusCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildRateLimitSection(isDark, l10n),
                  SizedBox(height: responsive.p16),
                  _buildApiKeysSection(isDark, l10n, responsive),
                  SizedBox(height: responsive.p80),
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
        l10n.apiManagement,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AdminColors.getTextColor(isDark),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showDocumentation(context, isDark, l10n),
          icon: Icon(
            Icons.menu_book_rounded,
            color: AdminColors.primary,
          ),
          tooltip: l10n.apiDocumentation,
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _apiEnabled
            ? AdminColors.primaryGradient
            : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade700]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_apiEnabled ? AdminColors.primary : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.api_rounded,
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
                      l10n.apiAccess,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _apiEnabled ? l10n.enabled : l10n.disabled,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _apiEnabled,
                onChanged: (v) => setState(() => _apiEnabled = v),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.vpn_key_rounded,
                  label: l10n.activeKeys,
                  value: '${_apiKeys.where((k) => k.isActive).length}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.bolt_rounded,
                  label: l10n.requestsToday,
                  value: '12,847',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.check_circle_rounded,
                  label: l10n.successRate,
                  value: '99.8%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRateLimitSection(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AdminColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.speed_rounded,
                    color: AdminColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.rateLimiting,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSliderItem(
            isDark: isDark,
            title: l10n.requestsPerWindow,
            value: _rateLimit.toDouble(),
            min: 100,
            max: 10000,
            divisions: 99,
            onChanged: (v) => setState(() => _rateLimit = v.round()),
            displayValue: '$_rateLimit ${l10n.requests}',
          ),
          const SizedBox(height: 16),
          _buildSliderItem(
            isDark: isDark,
            title: l10n.timeWindow,
            value: _rateLimitWindow.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            onChanged: (v) => setState(() => _rateLimitWindow = v.round()),
            displayValue: '$_rateLimitWindow ${l10n.minutes}',
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
    required bool isDark,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AdminColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AdminColors.primary,
            inactiveTrackColor: AdminColors.primary.withValues(alpha: 0.2),
            thumbColor: AdminColors.primary,
            overlayColor: AdminColors.primary.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeysSection(
      bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.apiKeys,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            Text(
              '${_apiKeys.length} ${l10n.keys}',
              style: TextStyle(
                fontSize: 14,
                color: AdminColors.getTextSecondaryColor(isDark),
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.p12),
        ..._apiKeys.map((key) => _buildApiKeyCard(key, isDark, l10n, responsive)),
      ],
    );
  }

  Widget _buildApiKeyCard(
      _ApiKey apiKey, bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.p12),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (apiKey.isActive
                                ? AdminColors.success
                                : Colors.grey)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.vpn_key_rounded,
                        color:
                            apiKey.isActive ? AdminColors.success : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apiKey.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.getTextColor(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.created}: ${_formatDate(apiKey.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AdminColors.getTextTertiaryColor(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: apiKey.isActive,
                      onChanged: (v) => setState(() => apiKey.isActive = v),
                      activeColor: AdminColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AdminColors.getBackgroundColor(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          apiKey.key,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: AdminColors.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: apiKey.key));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.copiedToClipboard),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AdminColors.success,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: Icon(Icons.copy_rounded,
                            size: 18, color: AdminColors.primary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: apiKey.permissions.map((p) {
                    Color color;
                    switch (p) {
                      case 'read':
                        color = AdminColors.success;
                        break;
                      case 'write':
                        color = AdminColors.primary;
                        break;
                      case 'delete':
                        color = AdminColors.error;
                        break;
                      default:
                        color = Colors.grey;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AdminColors.getDividerColor(isDark)),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _regenerateKey(apiKey, l10n),
                  icon: Icon(Icons.refresh_rounded,
                      size: 18, color: AdminColors.warning),
                  label: Text(l10n.regenerate,
                      style: TextStyle(color: AdminColors.warning)),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AdminColors.getDividerColor(isDark),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deleteKey(apiKey, l10n),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18, color: AdminColors.error),
                  label: Text(l10n.revoke,
                      style: TextStyle(color: AdminColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateKeyDialog(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    final nameController = TextEditingController();
    List<String> selectedPermissions = ['read'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.generateApiKey,
                style: TextStyle(
                  color: AdminColors.getTextColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.keyName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.permissions,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AdminColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['read', 'write', 'delete'].map((p) {
                  final isSelected = selectedPermissions.contains(p);
                  return FilterChip(
                    label: Text(p.toUpperCase()),
                    selected: isSelected,
                    onSelected: (v) {
                      setDialogState(() {
                        if (v) {
                          selectedPermissions.add(p);
                        } else {
                          selectedPermissions.remove(p);
                        }
                      });
                    },
                    selectedColor: AdminColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AdminColors.primary,
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel,
                  style: TextStyle(color: AdminColors.getTextSecondaryColor(isDark))),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _apiKeys.add(_ApiKey(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      key: 'pk_${DateTime.now().millisecondsSinceEpoch}_xxxx',
                      createdAt: DateTime.now(),
                      lastUsed: null,
                      permissions: selectedPermissions,
                      isActive: true,
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.apiKeyGenerated),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AdminColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.generate),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentation(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AdminColors.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AdminColors.getDividerColor(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.apiDocumentation,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AdminColors.getTextColor(isDark),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildDocSection(
                    isDark: isDark,
                    title: 'Base URL',
                    content: 'https://api.eduverse.com/v1',
                  ),
                  _buildDocSection(
                    isDark: isDark,
                    title: 'Authentication',
                    content:
                        'Include your API key in the Authorization header:\nAuthorization: Bearer YOUR_API_KEY',
                  ),
                  _buildDocSection(
                    isDark: isDark,
                    title: 'Endpoints',
                    content:
                        'GET /users - List all users\nGET /courses - List all courses\nPOST /enrollments - Create enrollment',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocSection({
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getBackgroundColor(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AdminColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: AdminColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _regenerateKey(_ApiKey apiKey, AppLocalizations l10n) {
    setState(() {
      apiKey.key = 'pk_${DateTime.now().millisecondsSinceEpoch}_new';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.apiKeyRegenerated),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteKey(_ApiKey apiKey, AppLocalizations l10n) {
    setState(() => _apiKeys.remove(apiKey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.apiKeyRevoked),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ApiKey {
  final String id;
  final String name;
  String key;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final List<String> permissions;
  bool isActive;

  _ApiKey({
    required this.id,
    required this.name,
    required this.key,
    required this.createdAt,
    this.lastUsed,
    required this.permissions,
    required this.isActive,
  });
}
