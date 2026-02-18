import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/admin/shared/admin_colors.dart';
import '../../../common/utils/responsive.dart';

class AdminWebhooksScreen extends StatefulWidget {
  const AdminWebhooksScreen({super.key});

  @override
  State<AdminWebhooksScreen> createState() => _AdminWebhooksScreenState();
}

class _AdminWebhooksScreenState extends State<AdminWebhooksScreen> {
  final List<_Webhook> _webhooks = [
    _Webhook(
      id: '1',
      name: 'Enrollment Webhook',
      url: 'https://api.example.com/webhooks/enrollment',
      events: ['user.enrolled', 'user.unenrolled'],
      isActive: true,
      lastTriggered: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _Webhook(
      id: '2',
      name: 'Grade Updates',
      url: 'https://api.example.com/webhooks/grades',
      events: ['grade.updated', 'grade.finalized'],
      isActive: true,
      lastTriggered: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    _Webhook(
      id: '3',
      name: 'Course Events',
      url: 'https://api.example.com/webhooks/courses',
      events: ['course.created', 'course.updated', 'course.deleted'],
      isActive: false,
      lastTriggered: null,
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddWebhookDialog(context, isDark, l10n),
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addWebhook),
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
                  _buildInfoCard(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  _buildStatsRow(isDark, l10n),
                  SizedBox(height: responsive.p24),
                  ..._webhooks.map((w) => _buildWebhookCard(w, isDark, l10n, responsive)),
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
        l10n.webhooks,
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
        border: Border.all(color: AdminColors.primary.withValues(alpha: 0.2)),
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
              Icons.webhook_rounded,
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
                  l10n.webhooksInfo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.webhooksDesc,
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

  Widget _buildStatsRow(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark: isDark,
            title: l10n.totalWebhooks,
            value: '${_webhooks.length}',
            icon: Icons.webhook_rounded,
            color: AdminColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark: isDark,
            title: l10n.activeWebhooks,
            value: '${_webhooks.where((w) => w.isActive).length}',
            icon: Icons.check_circle_rounded,
            color: AdminColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark: isDark,
            title: l10n.triggeredToday,
            value: '47',
            icon: Icons.bolt_rounded,
            color: AdminColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.getCardBorderColor(isDark)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AdminColors.getTextSecondaryColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookCard(
      _Webhook webhook, bool isDark, AppLocalizations l10n, ResponsiveUtil responsive) {
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
                        color: (webhook.isActive
                                ? AdminColors.success
                                : Colors.grey)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.webhook_rounded,
                        color: webhook.isActive
                            ? AdminColors.success
                            : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            webhook.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AdminColors.getTextColor(isDark),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (webhook.isActive
                                          ? AdminColors.success
                                          : Colors.grey)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  webhook.isActive
                                      ? l10n.active
                                      : l10n.inactive,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: webhook.isActive
                                        ? AdminColors.success
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              if (webhook.lastTriggered != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.lastTriggered}: ${_formatTime(webhook.lastTriggered!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.getTextTertiaryColor(
                                        isDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: webhook.isActive,
                      onChanged: (v) =>
                          setState(() => webhook.isActive = v),
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
                      Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: AdminColors.getTextTertiaryColor(isDark),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          webhook.url,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: AdminColors.getTextColor(isDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: webhook.url));
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
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: AdminColors.primary,
                        ),
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
                  children: webhook.events.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AdminColors.primary,
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
                  onPressed: () =>
                      _showEditWebhookDialog(context, webhook, isDark, l10n),
                  icon: Icon(Icons.edit_rounded,
                      size: 18, color: AdminColors.primary),
                  label: Text(l10n.edit,
                      style: TextStyle(color: AdminColors.primary)),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AdminColors.getDividerColor(isDark),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _testWebhook(webhook, l10n),
                  icon: Icon(Icons.send_rounded,
                      size: 18, color: AdminColors.warning),
                  label: Text(l10n.test,
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
                  onPressed: () => _deleteWebhook(webhook, l10n),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18, color: AdminColors.error),
                  label: Text(l10n.delete,
                      style: TextStyle(color: AdminColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showAddWebhookDialog(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.addWebhook,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.webhookName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: l10n.webhookUrl,
                hintText: 'https://...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              if (nameController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                setState(() {
                  _webhooks.add(_Webhook(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    url: urlController.text,
                    events: [],
                    isActive: true,
                    lastTriggered: null,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.webhookAdded),
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
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showEditWebhookDialog(
      BuildContext context, _Webhook webhook, bool isDark, AppLocalizations l10n) {
    final nameController = TextEditingController(text: webhook.name);
    final urlController = TextEditingController(text: webhook.url);

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
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.editWebhook,
              style: TextStyle(
                color: AdminColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.webhookName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: l10n.webhookUrl,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              setState(() {
                webhook.name = nameController.text;
                webhook.url = urlController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.webhookUpdated),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AdminColors.success,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _testWebhook(_Webhook webhook, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.webhookTestSent),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteWebhook(_Webhook webhook, AppLocalizations l10n) {
    setState(() => _webhooks.remove(webhook));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.webhookDeleted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AdminColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _Webhook {
  final String id;
  String name;
  String url;
  final List<String> events;
  bool isActive;
  final DateTime? lastTriggered;

  _Webhook({
    required this.id,
    required this.name,
    required this.url,
    required this.events,
    required this.isActive,
    this.lastTriggered,
  });
}
