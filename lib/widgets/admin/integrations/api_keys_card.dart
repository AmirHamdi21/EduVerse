import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../shared/admin_colors.dart';

class ApiKey {
  final String id;
  final String name;
  final String key;
  final String? description;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final DateTime? expiresAt;
  final bool isActive;
  final List<String> permissions;

  const ApiKey({
    required this.id,
    required this.name,
    required this.key,
    this.description,
    required this.createdAt,
    this.lastUsed,
    this.expiresAt,
    required this.isActive,
    required this.permissions,
  });
}

class ApiKeysCard extends StatefulWidget {
  final bool isDark;
  final List<ApiKey> apiKeys;
  final Function() onCreateKey;
  final Function(ApiKey) onEditKey;
  final Function(ApiKey) onDeleteKey;
  final Function(ApiKey) onRevokeKey;

  const ApiKeysCard({
    super.key,
    required this.isDark,
    required this.apiKeys,
    required this.onCreateKey,
    required this.onEditKey,
    required this.onDeleteKey,
    required this.onRevokeKey,
  });

  @override
  State<ApiKeysCard> createState() => _ApiKeysCardState();
}

class _ApiKeysCardState extends State<ApiKeysCard> {
  final Set<String> _revealedKeys = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.getCardBorderColor(widget.isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_rounded, color: AdminColors.secondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.apiKeys,
                  style: TextStyle(
                    color: AdminColors.getTextColor(widget.isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onCreateKey,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createNew),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.apiKeys.isEmpty)
            _buildEmptyState(l10n)
          else
            ...widget.apiKeys.map((key) => _buildApiKeyItem(key, l10n)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.vpn_key_off_rounded,
              color: AdminColors.getTextTertiaryColor(widget.isDark),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noApiKeys,
              style: TextStyle(
                color: AdminColors.getTextSecondaryColor(widget.isDark),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createApiKeyDescription,
              style: TextStyle(
                color: AdminColors.getTextTertiaryColor(widget.isDark),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyItem(ApiKey apiKey, AppLocalizations l10n) {
    final isRevealed = _revealedKeys.contains(apiKey.id);
    final isExpired =
        apiKey.expiresAt != null && apiKey.expiresAt!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? AdminColors.error.withValues(alpha: 0.3)
              : AdminColors.getCardBorderColor(
                  widget.isDark,
                ).withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        (apiKey.isActive && !isExpired
                                ? AdminColors.success
                                : AdminColors.error)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    apiKey.isActive && !isExpired
                        ? Icons.key_rounded
                        : Icons.key_off_rounded,
                    color: apiKey.isActive && !isExpired
                        ? AdminColors.success
                        : AdminColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            apiKey.name,
                            style: TextStyle(
                              color: AdminColors.getTextColor(widget.isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isExpired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AdminColors.error.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.expired,
                                style: TextStyle(
                                  color: AdminColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (apiKey.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          apiKey.description!,
                          style: TextStyle(
                            color: AdminColors.getTextSecondaryColor(
                              widget.isDark,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AdminColors.getTextSecondaryColor(widget.isDark),
                    size: 20,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        widget.onEditKey(apiKey);
                        break;
                      case 'revoke':
                        widget.onRevokeKey(apiKey);
                        break;
                      case 'delete':
                        widget.onDeleteKey(apiKey);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'revoke',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block_rounded,
                            size: 18,
                            color: AdminColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.revoke,
                            style: TextStyle(color: AdminColors.warning),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: AdminColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: TextStyle(color: AdminColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // API Key display
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isRevealed ? apiKey.key : _maskKey(apiKey.key),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AdminColors.getTextColor(widget.isDark),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isRevealed ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    color: AdminColors.getTextSecondaryColor(widget.isDark),
                    onPressed: () {
                      setState(() {
                        if (isRevealed) {
                          _revealedKeys.remove(apiKey.id);
                        } else {
                          _revealedKeys.add(apiKey.id);
                        }
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    color: AdminColors.getTextSecondaryColor(widget.isDark),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: apiKey.key));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.copiedToClipboard),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Permissions and metadata
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: apiKey.permissions
                  .map(
                    (perm) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        perm,
                        style: TextStyle(
                          color: AdminColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: AdminColors.getTextTertiaryColor(widget.isDark),
                ),
                const SizedBox(width: 4),
                Text(
                  '${l10n.created}: ${_formatDate(apiKey.createdAt)}',
                  style: TextStyle(
                    color: AdminColors.getTextTertiaryColor(widget.isDark),
                    fontSize: 10,
                  ),
                ),
                if (apiKey.lastUsed != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AdminColors.getTextTertiaryColor(widget.isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${l10n.lastUsed}: ${_formatDate(apiKey.lastUsed!)}',
                    style: TextStyle(
                      color: AdminColors.getTextTertiaryColor(widget.isDark),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 4)}${'•' * (key.length - 8)}${key.substring(key.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
