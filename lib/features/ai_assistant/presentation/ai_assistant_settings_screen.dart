import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../data/ai_provider_defaults.dart';
import '../domain/ai_assistant_models.dart';
import 'ai_assistant_cubit.dart';
import 'ai_assistant_role_theme.dart';
import 'ai_assistant_state.dart';

class AiAssistantSettingsScreen extends StatelessWidget {
  const AiAssistantSettingsScreen({super.key, required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.aiAssistantSettingsTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showProviderHelp(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: BlocBuilder<AiAssistantCubit, AiAssistantState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              _SettingsCard(
                roleTheme: roleTheme,
                title: l10n.aiAssistantDefaultModelTitle,
                subtitle: l10n.aiAssistantDefaultModelSubtitle,
                child: Column(
                  children: <Widget>[
                    _ProviderDropdown(
                      current: state.settings.providerId,
                      availableModels: state.availableModels,
                      onChanged: (providerId) async {
                        final models = state.modelsForProvider(providerId);
                        final targetModel = models.isNotEmpty
                            ? models.first.modelId
                            : defaultModelsForProvider(
                                providerId,
                              ).first.modelId;
                        await context.read<AiAssistantCubit>().selectModel(
                          providerId: providerId,
                          modelId: targetModel,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ModelDropdown(
                      currentProvider: state.settings.providerId,
                      currentModelId: state.settings.modelId,
                      models: state.modelsForProvider(
                        state.settings.providerId,
                      ),
                      onChanged: (modelId) async {
                        await context.read<AiAssistantCubit>().selectModel(
                          providerId: state.settings.providerId,
                          modelId: modelId,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                roleTheme: roleTheme,
                title: l10n.aiAssistantResponseStyleTitle,
                subtitle: l10n.aiAssistantResponseStyleSubtitle,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: AiResponseStyle.values
                          .map(
                            (style) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: style != AiResponseStyle.values.last
                                      ? 10
                                      : 0,
                                ),
                                child: _ModernOptionChip(
                                  roleTheme: roleTheme,
                                  label: _styleLabel(l10n, style),
                                  icon: _styleIcon(style),
                                  selected: state.defaultResponseStyle == style,
                                  onTap: () => context
                                      .read<AiAssistantCubit>()
                                      .setResponseStyle(style),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                roleTheme: roleTheme,
                title: l10n.aiAssistantProvidersTitle,
                subtitle: l10n.aiAssistantProvidersSubtitle,
                child: Column(
                  children: AiProviderId.values
                      .map(
                        (providerId) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProviderCard(
                            providerId: providerId,
                            credentialState: state.credentialStateFor(
                              providerId,
                            ),
                            roleTheme: roleTheme,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                roleTheme: roleTheme,
                title: l10n.aiAssistantLocalDataTitle,
                subtitle: l10n.aiAssistantLocalDataSubtitle,
                child: Column(
                  children: <Widget>[
                    _SettingsActionRow(
                      roleTheme: roleTheme,
                      icon: Icons.restart_alt_rounded,
                      iconColor: roleTheme.primary,
                      title: l10n.aiAssistantRefreshModels,
                      subtitle: l10n.aiAssistantRefreshModelsSubtitle,
                      buttonLabel: l10n.aiAssistantRefresh,
                      onPressed: state.isLoadingModels
                          ? null
                          : () => context
                                .read<AiAssistantCubit>()
                                .refreshModels(),
                    ),
                    const Divider(height: 1),
                    _SettingsActionRow(
                      roleTheme: roleTheme,
                      icon: Icons.delete_sweep_rounded,
                      iconColor: Colors.red.shade400,
                      title: l10n.aiAssistantClearHistoryTitle,
                      subtitle: l10n.aiAssistantClearHistorySubtitle,
                      buttonLabel: l10n.aiAssistantClearHistoryAction,
                      isDestructive: true,
                      onPressed: () => _confirmClearHistory(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.aiAssistantClearHistoryAction),
        content: Text(l10n.aiAssistantClearHistoryConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.aiAssistantClearHistoryAction),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AiAssistantCubit>().clearAllHistory();
    }
  }

  Future<void> _showProviderHelp(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.aiAssistantProviderHelpTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.aiAssistantProviderHelpBody,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _styleLabel(AppLocalizations l10n, AiResponseStyle style) {
    switch (style) {
      case AiResponseStyle.concise:
        return l10n.aiAssistantStyleConcise;
      case AiResponseStyle.balanced:
        return l10n.aiAssistantStyleBalanced;
      case AiResponseStyle.detailed:
        return l10n.aiAssistantStyleDetailed;
    }
  }

  IconData _styleIcon(AiResponseStyle style) {
    switch (style) {
      case AiResponseStyle.concise:
        return Icons.short_text_rounded;
      case AiResponseStyle.balanced:
        return Icons.done_rounded;
      case AiResponseStyle.detailed:
        return Icons.subject_rounded;
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.roleTheme,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final AiAssistantRoleTheme roleTheme;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: roleTheme.primary.withValues(alpha: 0.10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: roleTheme.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProviderDropdown extends StatelessWidget {
  const _ProviderDropdown({
    required this.current,
    required this.availableModels,
    required this.onChanged,
  });

  final AiProviderId current;
  final List<AiModelDescriptor> availableModels;
  final ValueChanged<AiProviderId> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<AiProviderId>(
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.aiAssistantProviderLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      items: AiProviderId.values
          .map(
            (providerId) => DropdownMenuItem<AiProviderId>(
              value: providerId,
              child: Text(
                _providerLabel(providerId),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) => AiProviderId.values
          .map(
            (providerId) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _providerLabel(providerId),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (providerId) {
        if (providerId != null) {
          onChanged(providerId);
        }
      },
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.currentProvider,
    required this.currentModelId,
    required this.models,
    required this.onChanged,
  });

  final AiProviderId currentProvider;
  final String currentModelId;
  final List<AiModelDescriptor> models;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = models.isNotEmpty
        ? models
        : defaultModelsForProvider(currentProvider);
    return DropdownButtonFormField<String>(
      initialValue: items.any((model) => model.modelId == currentModelId)
          ? currentModelId
          : items.first.modelId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.aiAssistantModelLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      items: items
          .map(
            (model) => DropdownMenuItem<String>(
              value: model.modelId,
              child: Text(
                model.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) => items
          .map(
            (model) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                model.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.providerId,
    required this.credentialState,
    required this.roleTheme,
  });

  final AiProviderId providerId;
  final AiProviderCredentialState credentialState;
  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: roleTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: roleTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: roleTheme.headerGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _providerLabel(providerId),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _sourceLabel(l10n, credentialState.source),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: credentialState.useUserKey,
                onChanged: credentialState.hasUserKey
                    ? (enabled) => context
                          .read<AiAssistantCubit>()
                          .setUseExternalKey(providerId, enabled)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _AvailabilityChip(
                  label: credentialState.hasAppDefault
                      ? l10n.aiAssistantAppAccessAvailable
                      : l10n.aiAssistantAppAccessUnavailable,
                  color: credentialState.hasAppDefault
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AvailabilityChip(
                  label: credentialState.hasUserKey
                      ? l10n.aiAssistantPersonalKeyConfigured
                      : l10n.aiAssistantPersonalKeyMissing,
                  color: credentialState.hasUserKey
                      ? roleTheme.primary
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => _showKeyEditor(context),
                icon: Icon(
                  credentialState.hasUserKey
                      ? Icons.edit_outlined
                      : Icons.add_rounded,
                ),
                label: Text(
                  credentialState.hasUserKey
                      ? l10n.aiAssistantReplaceKey
                      : l10n.aiAssistantAddKey,
                ),
              ),
              const SizedBox(width: 12),
              if (credentialState.hasUserKey)
                OutlinedButton.icon(
                  onPressed: () => context
                      .read<AiAssistantCubit>()
                      .removeExternalKey(providerId),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.aiAssistantRemoveKey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showKeyEditor(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    var useKey = true;
    final result = await showModalBottomSheet<_KeyEditorResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              top: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  MediaQuery.of(dialogContext).viewInsets.bottom + 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111827) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: roleTheme.primary.withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: roleTheme.headerGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.key_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        l10n.aiAssistantExternalKeyDialogTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _providerLabel(providerId),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.aiAssistantExternalKeyHint,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: roleTheme.primary.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: l10n.aiAssistantExternalKeyHint,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: roleTheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: roleTheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        l10n.aiAssistantUseMyKey,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l10n.aiAssistantUseMyKeySubtitle,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : const Color(0xFF64748B),
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Switch(
                                  value: useKey,
                                  onChanged: (value) =>
                                      setState(() => useKey = value),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(50),
                                    side: BorderSide(
                                      color: roleTheme.primary.withValues(
                                        alpha: 0.22,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(l10n.cancel),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: roleTheme.headerGradient,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(
                                          _KeyEditorResult(
                                            keyValue: controller.text.trim(),
                                            enabled: useKey,
                                          ),
                                        ),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(50),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(l10n.save),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    if (result == null || result.keyValue.trim().isEmpty || !context.mounted) {
      return;
    }
    await context.read<AiAssistantCubit>().saveExternalKey(
      providerId,
      result.keyValue,
      enable: result.enabled,
    );
  }

  String _sourceLabel(AppLocalizations l10n, AiCredentialSource source) {
    switch (source) {
      case AiCredentialSource.appDefault:
        return l10n.aiAssistantCredentialSourceAppDefault;
      case AiCredentialSource.userProvided:
        return l10n.aiAssistantCredentialSourceUserKey;
      case AiCredentialSource.unavailable:
        return l10n.aiAssistantCredentialSourceUnavailable;
    }
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ModernOptionChip extends StatelessWidget {
  const _ModernOptionChip({
    required this.roleTheme,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final AiAssistantRoleTheme roleTheme;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? roleTheme.primary.withValues(alpha: 0.14)
              : roleTheme.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? roleTheme.primary.withValues(alpha: 0.24)
                : roleTheme.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: selected ? roleTheme.primary : roleTheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? roleTheme.primary : const Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.roleTheme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.isDestructive = false,
  });

  final AiAssistantRoleTheme roleTheme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDestructive ? const Color(0xFFEF4444) : roleTheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(
                  alpha: onPressed == null ? 0.08 : 0.14,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(
                    alpha: onPressed == null ? 0.10 : 0.18,
                  ),
                ),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: onPressed == null
                      ? accent.withValues(alpha: 0.55)
                      : accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyEditorResult {
  const _KeyEditorResult({required this.keyValue, required this.enabled});

  final String keyValue;
  final bool enabled;
}

String _providerLabel(AiProviderId providerId) {
  switch (providerId) {
    case AiProviderId.gemini:
      return 'Gemini';
    case AiProviderId.groq:
      return 'Groq';
    case AiProviderId.openRouter:
      return 'OpenRouter';
  }
}
