import 'package:flutter/material.dart';
import '../shared/it_colors.dart';
import 'it_integration_barrel.dart';

class ITIntegrationConfigDialog extends StatefulWidget {
  final bool isDark;
  final IntegrationProvider integration;
  final Function(ConnectionSettings) onSave;

  const ITIntegrationConfigDialog({
    super.key,
    required this.isDark,
    required this.integration,
    required this.onSave,
  });

  @override
  State<ITIntegrationConfigDialog> createState() =>
      _ITIntegrationConfigDialogState();
}

class _ITIntegrationConfigDialogState extends State<ITIntegrationConfigDialog> {
  late TextEditingController _apiKeyController;
  late TextEditingController _endpointController;
  late TextEditingController _clientIdController;
  late TextEditingController _clientSecretController;
  late bool _autoSync;
  late int _syncInterval;
  late int _rateLimitPerMinute;
  late int _timeout;
  bool _showApiKey = false;
  bool _showClientSecret = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.integration.connectionSettings;
    _apiKeyController = TextEditingController(text: settings?.apiKey ?? '');
    _endpointController = TextEditingController(
      text: settings?.apiEndpoint ?? '',
    );
    _clientIdController = TextEditingController(text: settings?.clientId ?? '');
    _clientSecretController = TextEditingController(
      text: settings?.clientSecret ?? '',
    );
    _autoSync = settings?.autoSync ?? true;
    _syncInterval = settings?.syncInterval ?? 15;
    _rateLimitPerMinute = settings?.rateLimitPerMinute ?? 100;
    _timeout = settings?.timeout ?? 30;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.isDark ? ITColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: ITColors.headerGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.integration.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure ${widget.integration.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Update connection settings',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Authentication section
                    _buildSectionTitle('Authentication'),
                    const SizedBox(height: 12),
                    if (widget.integration.hasApiKey)
                      _buildSecureTextField(
                        controller: _apiKeyController,
                        label: 'API Key',
                        hint: 'Enter your API key',
                        isVisible: _showApiKey,
                        onToggleVisibility: () {
                          setState(() => _showApiKey = !_showApiKey);
                        },
                      ),
                    if (widget.integration.hasOAuth) ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _clientIdController,
                        label: 'Client ID',
                        hint: 'Enter OAuth client ID',
                      ),
                      const SizedBox(height: 12),
                      _buildSecureTextField(
                        controller: _clientSecretController,
                        label: 'Client Secret',
                        hint: 'Enter OAuth client secret',
                        isVisible: _showClientSecret,
                        onToggleVisibility: () {
                          setState(
                            () => _showClientSecret = !_showClientSecret,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Connection settings section
                    _buildSectionTitle('Connection Settings'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _endpointController,
                      label: 'API Endpoint',
                      hint: 'https://api.example.com/v1',
                    ),
                    const SizedBox(height: 16),
                    // Auto sync toggle
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : ITColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : ITColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Auto Sync',
                                style: TextStyle(
                                  color: ITColors.textPrimaryColor(
                                    widget.isDark,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Switch.adaptive(
                                value: _autoSync,
                                onChanged: (value) {
                                  setState(() => _autoSync = value);
                                },
                                activeThumbColor: ITColors.success,
                                activeTrackColor: ITColors.success.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ],
                          ),

                          // const SizedBox(height: 2),
                          Text(
                            'Automatically sync data at intervals',
                            style: TextStyle(
                              color: ITColors.textTertiaryColor(widget.isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_autoSync) ...[
                      const SizedBox(height: 16),
                      _buildSliderSetting(
                        label: 'Sync Interval',
                        value: _syncInterval.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        suffix: 'min',
                        onChanged: (value) {
                          setState(() => _syncInterval = value.toInt());
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Rate limiting section
                    _buildSectionTitle('Rate Limiting'),
                    const SizedBox(height: 12),
                    _buildSliderSetting(
                      label: 'Requests per Minute',
                      value: _rateLimitPerMinute.toDouble(),
                      min: 10,
                      max: 500,
                      divisions: 49,
                      suffix: 'req/min',
                      onChanged: (value) {
                        setState(() => _rateLimitPerMinute = value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSliderSetting(
                      label: 'Request Timeout',
                      value: _timeout.toDouble(),
                      min: 10,
                      max: 120,
                      divisions: 22,
                      suffix: 'sec',
                      onChanged: (value) {
                        setState(() => _timeout = value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : ITColors.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : ITColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: ITColors.textPrimaryColor(widget.isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ITColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: ITColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: ITColors.textPrimaryColor(widget.isDark),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ITColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: ITColors.textPrimaryColor(widget.isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ITColors.textTertiaryColor(widget.isDark),
              fontSize: 14,
            ),
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : ITColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecureTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ITColors.textSecondaryColor(widget.isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(
            color: ITColors.textPrimaryColor(widget.isDark),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: ITColors.textTertiaryColor(widget.isDark),
              fontSize: 14,
            ),
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : ITColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : ITColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ITColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: ITColors.textTertiaryColor(widget.isDark),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : ITColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : ITColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ITColors.textPrimaryColor(widget.isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ITColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()} $suffix',
                  style: TextStyle(
                    color: ITColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ITColors.primary,
              inactiveTrackColor: ITColors.primary.withValues(alpha: 0.2),
              thumbColor: ITColors.primary,
              overlayColor: ITColors.primary.withValues(alpha: 0.1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()} $suffix',
                style: TextStyle(
                  color: ITColors.textTertiaryColor(widget.isDark),
                  fontSize: 11,
                ),
              ),
              Text(
                '${max.toInt()} $suffix',
                style: TextStyle(
                  color: ITColors.textTertiaryColor(widget.isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final settings = ConnectionSettings(
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
      apiEndpoint: _endpointController.text.isNotEmpty
          ? _endpointController.text
          : null,
      clientId: _clientIdController.text.isNotEmpty
          ? _clientIdController.text
          : null,
      clientSecret: _clientSecretController.text.isNotEmpty
          ? _clientSecretController.text
          : null,
      autoSync: _autoSync,
      syncInterval: _syncInterval,
      rateLimitPerMinute: _rateLimitPerMinute,
      timeout: _timeout,
    );
    widget.onSave(settings);
    Navigator.pop(context);
  }
}
