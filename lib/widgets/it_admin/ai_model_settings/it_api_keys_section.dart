import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../shared/it_colors.dart';

class ITAPIKeysSection extends StatefulWidget {
  final bool isDark;
  final String? apiKey;
  final bool autoRotateEnabled;
  final ValueChanged<String> onApiKeyChanged;
  final ValueChanged<bool> onAutoRotateChanged;
  final VoidCallback onRegenerateKey;

  const ITAPIKeysSection({
    super.key,
    required this.isDark,
    this.apiKey,
    required this.autoRotateEnabled,
    required this.onApiKeyChanged,
    required this.onAutoRotateChanged,
    required this.onRegenerateKey,
  });

  @override
  State<ITAPIKeysSection> createState() => _ITAPIKeysSectionState();
}

class _ITAPIKeysSectionState extends State<ITAPIKeysSection> {
  int _selectedTab = 0;
  bool _isKeyVisible = false;

  String get _maskedKey {
    if (widget.apiKey == null || widget.apiKey!.isEmpty) {
      return '••••••••••••••••••••••••••••••••';
    }
    if (_isKeyVisible) {
      return widget.apiKey!;
    }
    final key = widget.apiKey!;
    if (key.length <= 8) return '•' * key.length;
    return '${key.substring(0, 4)}${'•' * (key.length - 8)}${key.substring(key.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark ? ITColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: widget.isDark ? null : ITColors.cardShadow(widget.isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ITColors.teal.withValues(alpha: 0.2),
                      ITColors.primary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.key_rounded, color: ITColors.teal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Keys & Credentials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ITColors.textPrimaryColor(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Secure management of API authentication keys',
                      style: TextStyle(
                        fontSize: 12,
                        color: ITColors.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tab selector
          _buildTabSelector(),
          const SizedBox(height: 16),

          if (_selectedTab == 0) ...[
            // Main Key section
            _buildKeyDisplay(),
            const SizedBox(height: 16),
            _buildAutoRotateOption(),
          ] else ...[
            // Regenerate Key section
            _buildRegenerateSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab('Main Key', 0, Icons.vpn_key_rounded),
          _buildTab('Auto-Rotate', 1, Icons.autorenew_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (widget.isDark ? ITColors.primary : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && !widget.isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (widget.isDark ? Colors.white : ITColors.primary)
                    : ITColors.textSecondaryColor(widget.isDark),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? (widget.isDark ? Colors.white : ITColors.primary)
                      : ITColors.textSecondaryColor(widget.isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _maskedKey,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                color: ITColors.textPrimaryColor(widget.isDark),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isKeyVisible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: ITColors.textSecondaryColor(widget.isDark),
            ),
            onPressed: () => setState(() => _isKeyVisible = !_isKeyVisible),
            tooltip: _isKeyVisible ? 'Hide key' : 'Show key',
          ),
          IconButton(
            icon: Icon(Icons.copy_rounded, size: 20, color: ITColors.primary),
            onPressed: () {
              if (widget.apiKey != null) {
                Clipboard.setData(ClipboardData(text: widget.apiKey!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('API key copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            tooltip: 'Copy key',
          ),
        ],
      ),
    );
  }

  Widget _buildAutoRotateOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : ITColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 20, color: ITColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Rotate Keys',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ITColors.textPrimaryColor(widget.isDark),
                  ),
                ),
                Text(
                  'Automatically rotate keys every 30 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: ITColors.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.autoRotateEnabled,
            onChanged: widget.onAutoRotateChanged,
            activeColor: ITColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRegenerateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ITColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ITColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: ITColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Regenerating your API key will invalidate the current key. All services using this key will need to be updated.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ITColors.textPrimaryColor(widget.isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onRegenerateKey,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Regenerate Key'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ITColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
