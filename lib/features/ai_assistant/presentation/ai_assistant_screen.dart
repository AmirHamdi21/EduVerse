import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../utils/navigation/safe_back.dart';
import '../../../widgets/shared/modern_action_sheet.dart';
import '../data/ai_provider_defaults.dart';
import '../domain/ai_assistant_models.dart';
import 'ai_assistant_cubit.dart';
import 'ai_assistant_history_screen.dart';
import 'ai_assistant_role_theme.dart';
import 'ai_assistant_settings_screen.dart';
import 'ai_assistant_state.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({
    super.key,
    required this.role,
    required this.userId,
    required this.userDisplayName,
  });

  final AiAssistantRole role;
  final int userId;
  final String userDisplayName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiAssistantCubit(
        role: role,
        userId: userId,
        userDisplayName: userDisplayName,
      )..initialize(),
      child: AiAssistantConversationScreen(role: role),
    );
  }
}

class AiAssistantConversationScreen extends StatelessWidget {
  const AiAssistantConversationScreen({super.key, required this.role});

  final AiAssistantRole role;

  @override
  Widget build(BuildContext context) => _AiAssistantView(role: role);
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView({required this.role});

  final AiAssistantRole role;

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleTheme = AiAssistantRoleTheme.fromRole(widget.role);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<AiAssistantCubit, AiAssistantState>(
      listenWhen: (previous, current) =>
          previous.infoMessage != current.infoMessage ||
          previous.errorMessage != current.errorMessage ||
          previous.draftSeed != current.draftSeed ||
          previous.activeConversation?.messages.length !=
              current.activeConversation?.messages.length,
      listener: (context, state) {
        if (state.infoMessage != null && state.infoMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          context.read<AiAssistantCubit>().clearTransientMessages();
        } else if (state.errorMessage != null &&
            state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              content: Text(state.errorMessage!),
            ),
          );
          context.read<AiAssistantCubit>().clearTransientMessages();
        }

        if (state.draftSeed != null) {
          _composerController.text = state.draftSeed!;
          _composerController.selection = TextSelection.collapsed(
            offset: _composerController.text.length,
          );
          _focusNode.requestFocus();
          context.read<AiAssistantCubit>().clearDraftSeed();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        final width = MediaQuery.sizeOf(context).width;
        final useWideLayout = width >= 1040;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF020617)
              : const Color(0xFFF7FAFF),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF020617) : const Color(0xFFF7FAFF),
              gradient: isDark ? null : roleTheme.softGradient,
            ),
            child: SafeArea(
              child: state.isBootstrapping
                  ? _AssistantLoadingView(roleTheme: roleTheme)
                  : Row(
                      children: <Widget>[
                        if (useWideLayout)
                          SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                              child: _HistoryRail(roleTheme: roleTheme),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              useWideLayout ? 8 : 0,
                              useWideLayout ? 16 : 0,
                              useWideLayout ? 16 : 0,
                              useWideLayout ? 16 : 0,
                            ),
                            child: _AssistantShell(
                              roleTheme: roleTheme,
                              composerController: _composerController,
                              focusNode: _focusNode,
                              scrollController: _scrollController,
                            ),
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }
}

class _AssistantShell extends StatelessWidget {
  const _AssistantShell({
    required this.roleTheme,
    required this.composerController,
    required this.focusNode,
    required this.scrollController,
  });

  final AiAssistantRoleTheme roleTheme;
  final TextEditingController composerController;
  final FocusNode focusNode;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AiAssistantCubit, AiAssistantState>(
      builder: (context, state) {
        final conversation = state.activeConversation;
        return Column(
          children: <Widget>[
            _AssistantHeader(roleTheme: roleTheme),
            if (state.isOffline)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: _StatusBanner(
                  color: const Color(0xFFF59E0B),
                  icon: Icons.wifi_off_rounded,
                  label: l10n.aiAssistantOfflineBanner,
                ),
              ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: -42,
                    top: 40,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        color: roleTheme.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -56,
                    bottom: 30,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        color: roleTheme.secondary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  if (conversation == null || conversation.messages.isEmpty)
                    _AssistantWelcome(roleTheme: roleTheme)
                  else
                    ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                      itemCount: conversation.messages.length,
                      itemBuilder: (context, index) {
                        final message = conversation.messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AiMessageBubble(
                            roleTheme: roleTheme,
                            message: message,
                            modelLabel: state.settings.modelId,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: roleTheme.primary.withValues(alpha: 0.10),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: roleTheme.primary.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: composerController,
                            focusNode: focusNode,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(context),
                            decoration: InputDecoration(
                              hintText: l10n.aiAssistantComposerHint,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ),
                        _ComposerIconButton(
                          roleTheme: roleTheme,
                          icon: Icons.auto_awesome_rounded,
                          tooltip: l10n.aiAssistantPromptShortcuts,
                          onPressed: () => _showAiToolsSheet(context),
                        ),
                        const SizedBox(width: 6),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: roleTheme.headerGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              onPressed: state.isSending
                                  ? context
                                        .read<AiAssistantCubit>()
                                        .stopGenerating
                                  : () => _send(context),
                              icon: Icon(
                                state.isSending
                                    ? Icons.stop_rounded
                                    : Icons.send_rounded,
                                color: Colors.white,
                              ),
                              tooltip: state.isSending
                                  ? l10n.aiAssistantStopGenerating
                                  : l10n.aiAssistantSend,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _send(BuildContext context) {
    context.read<AiAssistantCubit>().sendMessage(composerController.text);
    composerController.clear();
  }

  Future<void> _showAiToolsSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final state = context.read<AiAssistantCubit>().state;
    final selection = await showModernActionSheet<_AiToolsAction>(
      context,
      title: l10n.aiAssistantPromptShortcuts,
      subtitle: l10n.aiAssistantToolsMenuSubtitle,
      accentColor: roleTheme.primary,
      actions: <ModernActionItem<_AiToolsAction>>[
        ModernActionItem<_AiToolsAction>(
          value: _AiToolsAction.scope,
          label: l10n.aiAssistantToolsConversationMode,
          icon: Icons.tune_rounded,
          description: l10n.aiAssistantToolsConversationModeSubtitle,
          color: roleTheme.primary,
        ),
        ModernActionItem<_AiToolsAction>(
          value: _AiToolsAction.prompts,
          label: l10n.aiAssistantToolsQuickPrompts,
          icon: Icons.auto_awesome_rounded,
          description: l10n.aiAssistantPromptShortcutsSubtitle,
          color: roleTheme.secondary,
        ),
      ],
    );
    if (selection == null || !context.mounted) {
      return;
    }
    switch (selection) {
      case _AiToolsAction.scope:
        await _showConversationModeSheet(context);
        break;
      case _AiToolsAction.prompts:
        await _showPromptShortcutSheet(context, state);
        break;
    }
  }

  Future<void> _showPromptShortcutSheet(
    BuildContext context,
    AiAssistantState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final actions = _quickActionsForRole(l10n, state.role, roleTheme);
    final selection = await showModernActionSheet<_QuickAction>(
      context,
      title: l10n.aiAssistantToolsQuickPrompts,
      subtitle: l10n.aiAssistantPromptShortcutsSubtitle,
      accentColor: roleTheme.primary,
      actions: actions
          .map(
            (action) => ModernActionItem<_QuickAction>(
              value: action,
              label: action.label,
              icon: action.icon,
              description: action.prompt,
              color: action.color,
            ),
          )
          .toList(growable: false),
    );
    if (selection == null || !context.mounted) {
      return;
    }
    context.read<AiAssistantCubit>().sendMessage(selection.prompt);
  }

  Future<void> _showConversationModeSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final state = context.read<AiAssistantCubit>().state;
    final selection = await showModernActionSheet<AiContextScope>(
      context,
      title: l10n.aiAssistantToolsConversationMode,
      subtitle: l10n.aiAssistantToolsConversationModeSubtitle,
      accentColor: roleTheme.primary,
      actions: AiContextScope.values
          .map(
            (scope) => ModernActionItem<AiContextScope>(
              value: scope,
              label: _scopeLabel(l10n, scope),
              icon: _scopeIcon(scope),
              description: state.settings.scope == scope
                  ? l10n.aiAssistantToolsCurrentMode
                  : null,
              color: state.settings.scope == scope
                  ? roleTheme.primary
                  : roleTheme.secondary,
            ),
          )
          .toList(growable: false),
    );
    if (selection == null || !context.mounted) {
      return;
    }
    await context.read<AiAssistantCubit>().setContextScope(selection);
  }

  IconData _scopeIcon(AiContextScope scope) {
    switch (scope) {
      case AiContextScope.general:
        return Icons.done_rounded;
      case AiContextScope.study:
        return Icons.school_rounded;
      case AiContextScope.drafting:
        return Icons.edit_note_rounded;
      case AiContextScope.grading:
        return Icons.grading_rounded;
    }
  }

  String _scopeLabel(AppLocalizations l10n, AiContextScope scope) {
    switch (scope) {
      case AiContextScope.general:
        return l10n.aiAssistantScopeGeneral;
      case AiContextScope.study:
        return l10n.aiAssistantScopeStudy;
      case AiContextScope.drafting:
        return l10n.aiAssistantScopeDrafting;
      case AiContextScope.grading:
        return l10n.aiAssistantScopeGrading;
    }
  }
}

class _HistoryRail extends StatelessWidget {
  const _HistoryRail({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: roleTheme.primary.withValues(alpha: 0.10)),
      ),
      child: BlocBuilder<AiAssistantCubit, AiAssistantState>(
        builder: (context, state) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.aiAssistantHistoryTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: context
                          .read<AiAssistantCubit>()
                          .createNewConversation,
                      icon: Icon(Icons.add_rounded, color: roleTheme.primary),
                      tooltip: l10n.aiAssistantNewChat,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            l10n.aiAssistantHistoryEmptySubtitle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final entry = state.history[index];
                          final isSelected =
                              entry.id == state.activeConversation?.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context
                                  .read<AiAssistantCubit>()
                                  .selectConversation(entry.id),
                              child: Ink(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? roleTheme.primary.withValues(
                                          alpha: 0.12,
                                        )
                                      : roleTheme.surfaceTint.withValues(
                                          alpha: 0.45,
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? roleTheme.primary.withValues(
                                            alpha: 0.30,
                                          )
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      entry.title ==
                                              AiAssistantCubit
                                                  .untitledConversationTitle
                                          ? l10n.aiAssistantUntitledConversation
                                          : entry.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.preview?.trim().isNotEmpty == true
                                          ? entry.preview!
                                          : l10n.aiAssistantHistoryPreviewFallback,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AiAssistantCubit, AiAssistantState>(
      builder: (context, state) {
        final conversation = state.activeConversation;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              gradient: roleTheme.headerGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: roleTheme.primary.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -12,
                  top: -18,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _HeaderButton(
                          icon: iosBackIcon(context),
                          onPressed: () => safeBack(context, _fallbackRoute),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                l10n.aiAssistantTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_providerLabel(state.settings.providerId)} • ${state.settings.modelId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.90),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _HeaderButton(
                          icon: Icons.history_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AiAssistantCubit>(),
                                child: AiAssistantHistoryScreen(
                                  roleTheme: roleTheme,
                                  launchMode:
                                      AiAssistantHistoryLaunchMode.picker,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _HeaderButton(
                          icon: Icons.tune_rounded,
                          onPressed: () => _showModelPicker(context),
                        ),
                        const SizedBox(width: 6),
                        _HeaderButton(
                          icon: Icons.settings_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AiAssistantCubit>(),
                                child: AiAssistantSettingsScreen(
                                  roleTheme: roleTheme,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        _HeaderChip(
                          icon: Icons.hub_rounded,
                          label: _providerLabel(state.settings.providerId),
                        ),
                        _HeaderChip(
                          icon: Icons.bolt_rounded,
                          label: _scopeLabel(l10n, state.settings.scope),
                        ),
                        _HeaderChip(
                          icon: Icons.rule_rounded,
                          label: _styleLabel(l10n, state.defaultResponseStyle),
                        ),
                        if (conversation != null)
                          _HeaderChip(
                            icon: Icons.chat_bubble_outline_rounded,
                            label:
                                '${conversation.messages.length} ${l10n.aiAssistantMessagesLabel}',
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showModelPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AiAssistantCubit>();
    final state = cubit.state;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 560),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.aiAssistantChooseModelTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(l10n.aiAssistantChooseModelSubtitle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      children: AiProviderId.values
                          .map((providerId) {
                            final models =
                                state.modelsForProvider(providerId).isNotEmpty
                                ? state.modelsForProvider(providerId)
                                : defaultModelsForProvider(providerId);
                            final credentialState = state.credentialStateFor(
                              providerId,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: roleTheme.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
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
                                    const SizedBox(height: 4),
                                    Text(
                                      credentialState.isAvailable
                                          ? l10n.aiAssistantProviderReady
                                          : l10n.aiAssistantProviderUnavailable,
                                    ),
                                    const SizedBox(height: 12),
                                    ...models.map(
                                      (model) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          onTap: credentialState.isAvailable
                                              ? () async {
                                                  await cubit.selectModel(
                                                    providerId: providerId,
                                                    modelId: model.modelId,
                                                  );
                                                  if (sheetContext.mounted) {
                                                    Navigator.of(
                                                      sheetContext,
                                                    ).pop();
                                                  }
                                                }
                                              : null,
                                          child: Ink(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  state.settings.providerId ==
                                                          providerId &&
                                                      state.settings.modelId ==
                                                          model.modelId
                                                  ? roleTheme.primary
                                                        .withValues(alpha: 0.14)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color:
                                                    state.settings.providerId ==
                                                            providerId &&
                                                        state
                                                                .settings
                                                                .modelId ==
                                                            model.modelId
                                                    ? roleTheme.primary
                                                    : Colors.grey.withValues(
                                                        alpha: 0.18,
                                                      ),
                                              ),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        model.label,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        model.modelId,
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Colors.white70
                                                              : const Color(
                                                                  0xFF64748B,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (model.isFreeTier)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF10B981,
                                                      ).withValues(alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      l10n.aiAssistantFreeTierBadge,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(growable: false),
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

  String _scopeLabel(AppLocalizations l10n, AiContextScope scope) {
    switch (scope) {
      case AiContextScope.general:
        return l10n.aiAssistantScopeGeneral;
      case AiContextScope.study:
        return l10n.aiAssistantScopeStudy;
      case AiContextScope.drafting:
        return l10n.aiAssistantScopeDrafting;
      case AiContextScope.grading:
        return l10n.aiAssistantScopeGrading;
    }
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

  String get _fallbackRoute {
    return switch (roleTheme.role) {
      AiAssistantRole.student => '/dashboard',
      AiAssistantRole.instructor => '/instructor/dashboard',
      AiAssistantRole.ta => '/ta/dashboard',
    };
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.roleTheme,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AiAssistantRoleTheme roleTheme;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: roleTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: roleTheme.primary, size: 20),
          ),
        ),
      ),
    );
  }
}

enum _AiToolsAction { scope, prompts }

class _AssistantWelcome extends StatelessWidget {
  const _AssistantWelcome({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: roleTheme.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: roleTheme.headerGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.aiAssistantWelcomeTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.aiAssistantWelcomeSubtitle,
                textAlign: TextAlign.center,
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
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({
    required this.roleTheme,
    required this.message,
    required this.modelLabel,
  });

  final AiAssistantRoleTheme roleTheme;
  final AiMessage message;
  final String modelLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.author == AiMessageAuthorType.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser
        ? roleTheme.primary
        : isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white;
    final textColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: GestureDetector(
          onLongPress: () => _showActions(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isUser
                    ? Colors.transparent
                    : roleTheme.primary.withValues(alpha: 0.10),
              ),
              boxShadow: <BoxShadow>[
                if (!isUser)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: roleTheme.headerGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          modelLabel,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isUser || !_shouldRenderMarkdown)
                  Text(
                    _messageBody(context),
                    style: TextStyle(
                      color: textColor,
                      height: 1.52,
                      fontSize: 15,
                    ),
                  )
                else
                  MarkdownBody(
                    data: _messageBody(context),
                    selectable: true,
                    softLineBreak: true,
                    listItemCrossAxisAlignment:
                        MarkdownListItemCrossAxisAlignment.start,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: textColor,
                        height: 1.58,
                        fontSize: 15,
                      ),
                      strong: TextStyle(
                        color: textColor,
                        height: 1.58,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      em: TextStyle(
                        color: textColor,
                        height: 1.58,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                      listBullet: TextStyle(
                        color: roleTheme.primary,
                        height: 1.55,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      blockquote: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.82)
                            : const Color(0xFF334155),
                        height: 1.55,
                        fontSize: 15,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: roleTheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: roleTheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.all(12),
                      codeblockDecoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: roleTheme.primary.withValues(alpha: 0.10),
                        ),
                      ),
                      code: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      h1: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        height: 1.28,
                        fontWeight: FontWeight.w800,
                      ),
                      h2: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                      h3: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                      horizontalRuleDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: roleTheme.primary.withValues(alpha: 0.14),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      DateFormat.jm(
                        Localizations.localeOf(context).languageCode,
                      ).format(message.createdAt.toLocal()),
                      style: TextStyle(
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.80)
                            : (isDark
                                  ? Colors.white60
                                  : const Color(0xFF94A3B8)),
                        fontSize: 12,
                      ),
                    ),
                    if (!isUser) ...<Widget>[
                      const SizedBox(width: 8),
                      _MessageStatusChip(
                        roleTheme: roleTheme,
                        message: message,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (message.status == AiMessageStatus.generating) {
      return l10n.aiAssistantGeneratingMessage;
    }
    if (message.status == AiMessageStatus.cancelled) {
      return l10n.aiAssistantCancelledMessage;
    }
    if (message.status == AiMessageStatus.error &&
        message.content.trim().isEmpty) {
      return l10n.aiAssistantFailedMessage;
    }
    return message.content.trim();
  }

  bool get _shouldRenderMarkdown {
    if (message.isUser) {
      return false;
    }
    final content = message.content;
    return content.contains('**') ||
        content.contains('```') ||
        RegExp(r'(^|\n)\s*[-*]\s+').hasMatch(content) ||
        RegExp(r'(^|\n)\s*\d+\.\s+').hasMatch(content) ||
        RegExp(r'(^|\n)\s*#{1,6}\s+').hasMatch(content);
  }

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AiAssistantCubit>();
    final actions = <ModernActionItem<_MessageAction>>[
      ModernActionItem<_MessageAction>(
        value: _MessageAction.copy,
        label: l10n.aiAssistantCopyMessage,
        icon: Icons.copy_rounded,
      ),
      if (!message.isUser)
        ModernActionItem<_MessageAction>(
          value: _MessageAction.regenerate,
          label: l10n.aiAssistantRegenerateResponse,
          icon: Icons.refresh_rounded,
          description: l10n.aiAssistantRegenerateResponseSubtitle,
        ),
      if (message.isUser)
        ModernActionItem<_MessageAction>(
          value: _MessageAction.editAndResend,
          label: l10n.aiAssistantEditAndResend,
          icon: Icons.edit_rounded,
        ),
      if (!message.isUser)
        ModernActionItem<_MessageAction>(
          value: _MessageAction.share,
          label: l10n.aiAssistantShareResponse,
          icon: Icons.ios_share_rounded,
        ),
      ModernActionItem<_MessageAction>(
        value: _MessageAction.delete,
        label: l10n.aiAssistantDeleteMessage,
        icon: Icons.delete_outline_rounded,
        destructive: true,
      ),
      ModernActionItem<_MessageAction>(
        value: _MessageAction.deleteFromHere,
        label: l10n.aiAssistantDeleteFromHere,
        icon: Icons.content_cut_rounded,
        destructive: true,
      ),
    ];

    final result = await showModernActionSheet<_MessageAction>(
      context,
      title: message.isUser
          ? l10n.aiAssistantYourMessage
          : l10n.aiAssistantModelMessage,
      subtitle: message.isUser
          ? (message.content.trim().isEmpty ? _messageBody(context) : null)
          : null,
      accentColor: roleTheme.primary,
      actions: actions,
    );
    switch (result) {
      case _MessageAction.copy:
        await Clipboard.setData(ClipboardData(text: message.content));
        break;
      case _MessageAction.regenerate:
        await cubit.regenerateResponse(message.id);
        break;
      case _MessageAction.editAndResend:
        await cubit.editAndResendFromMessage(message.id);
        break;
      case _MessageAction.share:
        await Share.share(message.content);
        break;
      case _MessageAction.delete:
        await cubit.deleteMessage(message.id);
        break;
      case _MessageAction.deleteFromHere:
        await cubit.deleteFromMessage(message.id);
        break;
      case null:
        break;
    }
  }
}

class _MessageStatusChip extends StatelessWidget {
  const _MessageStatusChip({required this.roleTheme, required this.message});

  final AiAssistantRoleTheme roleTheme;
  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = switch (message.status) {
      AiMessageStatus.ready => const Color(0xFF10B981),
      AiMessageStatus.generating => roleTheme.primary,
      AiMessageStatus.error => const Color(0xFFEF4444),
      AiMessageStatus.cancelled => const Color(0xFFF59E0B),
    };
    final label = switch (message.status) {
      AiMessageStatus.ready => l10n.aiAssistantStatusReady,
      AiMessageStatus.generating => l10n.aiAssistantStatusGenerating,
      AiMessageStatus.error => l10n.aiAssistantStatusFailed,
      AiMessageStatus.cancelled => l10n.aiAssistantStatusCancelled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantLoadingView extends StatelessWidget {
  const _AssistantLoadingView({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          height: 126,
          decoration: BoxDecoration(
            gradient: roleTheme.headerGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: _LoadingShimmer(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Row(
                    children: <Widget>[
                      _LoadingBar(width: 38, height: 38),
                      SizedBox(width: 10),
                      Expanded(
                        child: _LoadingBar(width: double.infinity, height: 16),
                      ),
                      SizedBox(width: 10),
                      _LoadingBar(width: 38, height: 38),
                      SizedBox(width: 8),
                      _LoadingBar(width: 38, height: 38),
                    ],
                  ),
                  SizedBox(height: 12),
                  _LoadingBar(width: 220, height: 12),
                  SizedBox(height: 8),
                  _LoadingBar(width: 180, height: 12),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      _LoadingPill(width: 94),
                      SizedBox(width: 8),
                      _LoadingPill(width: 92),
                      SizedBox(width: 8),
                      _LoadingPill(width: 88),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: roleTheme.primary.withValues(alpha: 0.08),
                ),
              ),
              child: const _LoadingShimmer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _LoadingBar(width: 110, height: 14),
                        SizedBox(width: 10),
                        _LoadingBar(width: 80, height: 14),
                      ],
                    ),
                    SizedBox(height: 16),
                    _LoadingBar(width: double.infinity, height: 14),
                    SizedBox(height: 10),
                    _LoadingBar(width: double.infinity, height: 14),
                    SizedBox(height: 10),
                    _LoadingBar(width: 240, height: 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer({required this.child});

  final Widget child;

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + (2 * _controller.value), -0.3),
              end: Alignment(1 + (2 * _controller.value), 0.3),
              colors: const <Color>[
                Color(0xFFE5E7EB),
                Color(0xFFF8FAFC),
                Color(0xFFE5E7EB),
              ],
              stops: const <double>[0.1, 0.35, 0.6],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _LoadingPill extends StatelessWidget {
  const _LoadingPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.prompt,
    required this.icon,
    required this.color,
  });

  final String label;
  final String prompt;
  final IconData icon;
  final Color color;
}

List<_QuickAction> _quickActionsForRole(
  AppLocalizations l10n,
  AiAssistantRole role,
  AiAssistantRoleTheme roleTheme,
) {
  switch (role) {
    case AiAssistantRole.student:
      return <_QuickAction>[
        _QuickAction(
          label: l10n.aiAssistantActionExplain,
          prompt: l10n.aiAssistantPromptExplain,
          icon: Icons.lightbulb_outline_rounded,
          color: roleTheme.primary,
        ),
        _QuickAction(
          label: l10n.aiAssistantActionSummarize,
          prompt: l10n.aiAssistantPromptSummarize,
          icon: Icons.summarize_rounded,
          color: const Color(0xFF10B981),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionStudyPlan,
          prompt: l10n.aiAssistantPromptStudyPlan,
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFFF59E0B),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionPractice,
          prompt: l10n.aiAssistantPromptPracticeQuestions,
          icon: Icons.quiz_rounded,
          color: const Color(0xFF8B5CF6),
        ),
      ];
    case AiAssistantRole.instructor:
      return <_QuickAction>[
        _QuickAction(
          label: l10n.aiAssistantActionAnnouncement,
          prompt: l10n.aiAssistantPromptAnnouncement,
          icon: Icons.campaign_outlined,
          color: roleTheme.primary,
        ),
        _QuickAction(
          label: l10n.aiAssistantActionRubric,
          prompt: l10n.aiAssistantPromptRubric,
          icon: Icons.rule_folder_outlined,
          color: const Color(0xFF10B981),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionFeedback,
          prompt: l10n.aiAssistantPromptFeedback,
          icon: Icons.rate_review_outlined,
          color: const Color(0xFFF97316),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionLesson,
          prompt: l10n.aiAssistantPromptLessonIdeas,
          icon: Icons.auto_stories_outlined,
          color: const Color(0xFF8B5CF6),
        ),
      ];
    case AiAssistantRole.ta:
      return <_QuickAction>[
        _QuickAction(
          label: l10n.aiAssistantActionGradingHelp,
          prompt: l10n.aiAssistantPromptGradingHelp,
          icon: Icons.grading_rounded,
          color: roleTheme.primary,
        ),
        _QuickAction(
          label: l10n.aiAssistantActionClarify,
          prompt: l10n.aiAssistantPromptClarification,
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF10B981),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionRecap,
          prompt: l10n.aiAssistantPromptRecap,
          icon: Icons.notes_rounded,
          color: const Color(0xFFF59E0B),
        ),
        _QuickAction(
          label: l10n.aiAssistantActionOfficeHours,
          prompt: l10n.aiAssistantPromptOfficeHours,
          icon: Icons.schedule_rounded,
          color: const Color(0xFF3B82F6),
        ),
      ];
  }
}

enum _MessageAction {
  copy,
  regenerate,
  editAndResend,
  share,
  delete,
  deleteFromHere,
}
