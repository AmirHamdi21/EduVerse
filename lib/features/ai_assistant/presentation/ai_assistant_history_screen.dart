import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/shared/loading/skeleton_box.dart';
import '../domain/ai_assistant_models.dart';
import 'ai_assistant_cubit.dart';
import 'ai_assistant_role_theme.dart';
import 'ai_assistant_screen.dart';
import 'ai_assistant_state.dart';

enum AiAssistantHistoryLaunchMode { entry, picker }

class AiAssistantEntryScreen extends StatelessWidget {
  const AiAssistantEntryScreen({
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
    final roleTheme = AiAssistantRoleTheme.fromRole(role);
    return BlocProvider(
      create: (_) => AiAssistantCubit(
        role: role,
        userId: userId,
        userDisplayName: userDisplayName,
      )..initialize(),
      child: AiAssistantHistoryScreen(
        roleTheme: roleTheme,
        launchMode: AiAssistantHistoryLaunchMode.entry,
      ),
    );
  }
}

class AiAssistantHistoryScreen extends StatefulWidget {
  const AiAssistantHistoryScreen({
    super.key,
    required this.roleTheme,
    this.launchMode = AiAssistantHistoryLaunchMode.entry,
  });

  final AiAssistantRoleTheme roleTheme;
  final AiAssistantHistoryLaunchMode launchMode;

  @override
  State<AiAssistantHistoryScreen> createState() =>
      _AiAssistantHistoryScreenState();
}

class _AiAssistantHistoryScreenState extends State<AiAssistantHistoryScreen> {
  _HistoryBucketFilter _bucketFilter = _HistoryBucketFilter.all;
  AiProviderId? _providerFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.aiAssistantHistoryTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAgentPicker(context),
        backgroundColor: widget.roleTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.aiAssistantNewChat),
      ),
      body: BlocBuilder<AiAssistantCubit, AiAssistantState>(
        builder: (context, state) {
          if (state.isBootstrapping) {
            return _HistoryLoadingView(roleTheme: widget.roleTheme);
          }
          final filteredEntries = _filteredEntries(state.history);
          final pinnedEntries = filteredEntries
              .where((entry) => entry.isPinned)
              .toList(growable: false);
          final recentEntries = filteredEntries
              .where((entry) => !entry.isPinned)
              .toList(growable: false);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
            children: <Widget>[
              _HistoryHeroHeader(
                roleTheme: widget.roleTheme,
                totalChats: state.history.length,
                pinnedChats: state.history
                    .where((entry) => entry.isPinned)
                    .length,
                providersUsed: state.history
                    .map((entry) => entry.providerId)
                    .toSet()
                    .length,
                updatedToday: state.history.where((entry) {
                  final now = DateTime.now();
                  return entry.updatedAt.year == now.year &&
                      entry.updatedAt.month == now.month &&
                      entry.updatedAt.day == now.day;
                }).length,
              ),
              const SizedBox(height: 16),
              _HistoryFilterCard(
                roleTheme: widget.roleTheme,
                bucketFilter: _bucketFilter,
                providerFilter: _providerFilter,
                count: filteredEntries.length,
                onBucketChanged: (value) =>
                    setState(() => _bucketFilter = value),
                onProviderChanged: (value) =>
                    setState(() => _providerFilter = value),
              ),
              const SizedBox(height: 16),
              if (state.history.isEmpty)
                _EmptyHistoryCard(roleTheme: widget.roleTheme)
              else if (filteredEntries.isEmpty)
                _NoMatchesCard(roleTheme: widget.roleTheme)
              else ...<Widget>[
                if (_bucketFilter == _HistoryBucketFilter.all &&
                    pinnedEntries.isNotEmpty) ...<Widget>[
                  _SectionHeader(title: l10n.aiAssistantPinnedChats),
                  const SizedBox(height: 12),
                  ...pinnedEntries.map(_buildEntryTile),
                  const SizedBox(height: 8),
                ],
                if (_bucketFilter == _HistoryBucketFilter.all &&
                    recentEntries.isNotEmpty) ...<Widget>[
                  _SectionHeader(title: l10n.aiAssistantRecentChats),
                  const SizedBox(height: 12),
                  ...recentEntries.map(_buildEntryTile),
                ],
                if (_bucketFilter != _HistoryBucketFilter.all)
                  ...filteredEntries.map(_buildEntryTile),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEntryTile(AiConversationIndexEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _HistoryTile(
        entry: entry,
        roleTheme: widget.roleTheme,
        onTap: () => _openConversation(context, entry.id),
        onMore: () => _showActions(context, entry),
      ),
    );
  }

  List<AiConversationIndexEntry> _filteredEntries(
    List<AiConversationIndexEntry> entries,
  ) {
    final bucketFiltered = switch (_bucketFilter) {
      _HistoryBucketFilter.all => entries,
      _HistoryBucketFilter.pinned =>
        entries.where((entry) => entry.isPinned).toList(growable: false),
      _HistoryBucketFilter.recent =>
        entries.where((entry) => !entry.isPinned).toList(growable: false),
    };

    final providerFiltered = _providerFilter == null
        ? bucketFiltered
        : bucketFiltered
              .where((entry) => entry.providerId == _providerFilter)
              .toList(growable: false);

    final sorted = providerFiltered.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  Future<void> _openConversation(
    BuildContext context,
    String conversationId,
  ) async {
    final cubit = context.read<AiAssistantCubit>();
    await cubit.selectConversation(conversationId);
    if (!context.mounted) {
      return;
    }

    if (widget.launchMode == AiAssistantHistoryLaunchMode.picker) {
      Navigator.of(context).pop();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AiAssistantConversationScreen(role: cubit.state.role),
        ),
      ),
    );
  }

  Future<void> _showAgentPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AiAssistantCubit>();
    final options = _agentOptions(l10n);

    final selection = await showModalBottomSheet<_AgentOption>(
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
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                  const SizedBox(height: 16),
                  Text(
                    l10n.aiAssistantAgentPickerTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.aiAssistantAgentPickerSubtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Navigator.of(sheetContext).pop(option),
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: option.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: option.color.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: option.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: option.color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      option.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option.subtitle,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF64748B),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: option.color,
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
          ),
        );
      },
    );

    if (selection == null || !context.mounted) {
      return;
    }

    await cubit.createNewConversation(scope: selection.scope);
    if (!context.mounted) {
      return;
    }

    if (widget.launchMode == AiAssistantHistoryLaunchMode.picker) {
      Navigator.of(context).pop();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AiAssistantConversationScreen(role: cubit.state.role),
        ),
      ),
    );
  }

  List<_AgentOption> _agentOptions(AppLocalizations l10n) {
    return <_AgentOption>[
      _AgentOption(
        title: l10n.aiAssistantAgentGeneralTitle,
        subtitle: l10n.aiAssistantAgentGeneralSubtitle,
        scope: AiContextScope.general,
        icon: Icons.auto_awesome_rounded,
        color: widget.roleTheme.primary,
      ),
      _AgentOption(
        title: l10n.aiAssistantAgentStudyTitle,
        subtitle: l10n.aiAssistantAgentStudySubtitle,
        scope: AiContextScope.study,
        icon: Icons.school_rounded,
        color: const Color(0xFF10B981),
      ),
      _AgentOption(
        title: l10n.aiAssistantAgentDraftingTitle,
        subtitle: l10n.aiAssistantAgentDraftingSubtitle,
        scope: AiContextScope.drafting,
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _AgentOption(
        title: l10n.aiAssistantAgentGradingTitle,
        subtitle: l10n.aiAssistantAgentGradingSubtitle,
        scope: AiContextScope.grading,
        icon: Icons.grading_rounded,
        color: widget.roleTheme.secondary,
      ),
    ];
  }

  Future<void> _showActions(
    BuildContext context,
    AiConversationIndexEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AiAssistantCubit>();
    final action = await showModalBottomSheet<_HistoryAction>(
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: widget.roleTheme.headerGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _displayTitle(context, entry),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 140),
                              child: SingleChildScrollView(
                                child: Text(
                                  entry.preview?.trim().isNotEmpty == true
                                      ? entry.preview!
                                      : l10n.aiAssistantHistoryActionSubtitle,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF64748B),
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _HistorySheetActionTile(
                            icon: Icons.open_in_new_rounded,
                            label: l10n.aiAssistantOpenConversation,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(_HistoryAction.open),
                          ),
                          _HistorySheetActionTile(
                            icon: entry.isPinned
                                ? Icons.push_pin_outlined
                                : Icons.push_pin_rounded,
                            label: entry.isPinned
                                ? l10n.aiAssistantUnpinConversation
                                : l10n.aiAssistantPinConversation,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(_HistoryAction.pin),
                          ),
                          _HistorySheetActionTile(
                            icon: Icons.edit_outlined,
                            label: l10n.aiAssistantRenameConversation,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(_HistoryAction.rename),
                          ),
                          _HistorySheetActionTile(
                            icon: Icons.ios_share_rounded,
                            label: l10n.aiAssistantExportConversation,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(_HistoryAction.export),
                          ),
                          _HistorySheetActionTile(
                            icon: Icons.delete_outline_rounded,
                            label: l10n.aiAssistantDeleteConversation,
                            destructive: true,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(_HistoryAction.delete),
                          ),
                        ],
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

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case _HistoryAction.open:
        await _openConversation(context, entry.id);
        break;
      case _HistoryAction.pin:
        await cubit.togglePinned(entry.id);
        break;
      case _HistoryAction.rename:
        await _renameConversation(context, entry);
        break;
      case _HistoryAction.export:
        await cubit.exportConversationById(entry.id);
        break;
      case _HistoryAction.delete:
        await cubit.deleteConversation(entry.id);
        break;
      case null:
        break;
    }
  }

  Future<void> _renameConversation(
    BuildContext context,
    AiConversationIndexEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: _displayTitle(context, entry),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.aiAssistantRenameConversation),
          content: TextField(
            controller: controller,
            maxLength: 80,
            decoration: InputDecoration(
              hintText: l10n.aiAssistantConversationTitleHint,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (!context.mounted || result == null) {
      return;
    }
    await context.read<AiAssistantCubit>().renameConversation(entry.id, result);
  }

  String _displayTitle(BuildContext context, AiConversationIndexEntry entry) {
    final l10n = AppLocalizations.of(context);
    return entry.title == AiAssistantCubit.untitledConversationTitle
        ? l10n.aiAssistantUntitledConversation
        : entry.title;
  }
}

class _HistoryHeroHeader extends StatelessWidget {
  const _HistoryHeroHeader({
    required this.roleTheme,
    required this.totalChats,
    required this.pinnedChats,
    required this.providersUsed,
    required this.updatedToday,
  });

  final AiAssistantRoleTheme roleTheme;
  final int totalChats;
  final int pinnedChats;
  final int providersUsed;
  final int updatedToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: roleTheme.headerGradient,
        borderRadius: BorderRadius.circular(28),
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
            right: -24,
            top: -20,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.aiAssistantHistoryHeroTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.aiAssistantHistoryHeroSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useFourColumns = constraints.maxWidth >= 480;
                  return GridView.count(
                    crossAxisCount: useFourColumns ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 7,
                    crossAxisSpacing: 7,
                    childAspectRatio: useFourColumns ? 1.7 : 2.5,
                    children: <Widget>[
                      _HeroStatTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: l10n.aiAssistantHistoryStatTotal,
                        value: '$totalChats',
                      ),
                      _HeroStatTile(
                        icon: Icons.push_pin_rounded,
                        label: l10n.aiAssistantHistoryStatPinned,
                        value: '$pinnedChats',
                      ),
                      _HeroStatTile(
                        icon: Icons.hub_rounded,
                        label: l10n.aiAssistantHistoryStatProviders,
                        value: '$providersUsed',
                      ),
                      _HeroStatTile(
                        icon: Icons.today_rounded,
                        label: l10n.aiAssistantHistoryStatToday,
                        value: '$updatedToday',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterCard extends StatelessWidget {
  const _HistoryFilterCard({
    required this.roleTheme,
    required this.bucketFilter,
    required this.providerFilter,
    required this.count,
    required this.onBucketChanged,
    required this.onProviderChanged,
  });

  final AiAssistantRoleTheme roleTheme;
  final _HistoryBucketFilter bucketFilter;
  final AiProviderId? providerFilter;
  final int count;
  final ValueChanged<_HistoryBucketFilter> onBucketChanged;
  final ValueChanged<AiProviderId?> onProviderChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: roleTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count ${l10n.aiAssistantChatsLabel}',
              style: TextStyle(
                color: roleTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _FilterDropdown<_HistoryBucketFilter>(
                  label: l10n.aiAssistantHistoryViewLabel,
                  value: bucketFilter,
                  items: <DropdownMenuItem<_HistoryBucketFilter>>[
                    DropdownMenuItem(
                      value: _HistoryBucketFilter.all,
                      child: Text(l10n.aiAssistantHistoryFilterAllChats),
                    ),
                    DropdownMenuItem(
                      value: _HistoryBucketFilter.pinned,
                      child: Text(l10n.aiAssistantHistoryFilterPinnedOnly),
                    ),
                    DropdownMenuItem(
                      value: _HistoryBucketFilter.recent,
                      child: Text(l10n.aiAssistantHistoryFilterRecentOnly),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onBucketChanged(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown<AiProviderId?>(
                  label: l10n.aiAssistantHistoryProviderFilterLabel,
                  value: providerFilter,
                  items: <DropdownMenuItem<AiProviderId?>>[
                    DropdownMenuItem<AiProviderId?>(
                      value: null,
                      child: Text(l10n.aiAssistantHistoryAllProviders),
                    ),
                    ...AiProviderId.values.map(
                      (provider) => DropdownMenuItem<AiProviderId?>(
                        value: provider,
                        child: Text(_providerLabel(provider)),
                      ),
                    ),
                  ],
                  onChanged: onProviderChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    );
  }
}

class _HistoryLoadingView extends StatelessWidget {
  const _HistoryLoadingView({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            gradient: roleTheme.headerGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SkeletonBox(
                    isDark: false,
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SkeletonBox(
                          isDark: false,
                          width: 170,
                          height: 16,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 8),
                        SkeletonBox(
                          isDark: false,
                          width: double.infinity,
                          height: 12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 8),
                        SkeletonBox(
                          isDark: false,
                          width: 210,
                          height: 12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 7,
                crossAxisSpacing: 7,
                childAspectRatio: 2.95,
                children: List<Widget>.generate(
                  4,
                  (_) => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SkeletonBox(
                          isDark: false,
                          width: 16,
                          height: 16,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 6),
                        SkeletonBox(
                          isDark: false,
                          width: 24,
                          height: 12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 4),
                        SkeletonBox(
                          isDark: false,
                          width: 72,
                          height: 10,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: roleTheme.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: SkeletonBox(
                      isDark: isDark,
                      height: 52,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SkeletonBox(
                      isDark: isDark,
                      height: 52,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List<Widget>.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: roleTheme.primary.withValues(alpha: 0.10),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: roleTheme.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: roleTheme.headerGradient,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SkeletonBox(
                          isDark: isDark,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SkeletonBox(
                                isDark: isDark,
                                width: 150,
                                height: 16,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: 10),
                              SkeletonBox(
                                isDark: isDark,
                                width: double.infinity,
                                height: 12,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: 8),
                              SkeletonBox(
                                isDark: isDark,
                                width: 190,
                                height: 12,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  SkeletonBox(
                                    isDark: isDark,
                                    width: 68,
                                    height: 28,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  SkeletonBox(
                                    isDark: isDark,
                                    width: 120,
                                    height: 28,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SkeletonBox(
                          isDark: isDark,
                          width: 42,
                          height: 42,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.roleTheme,
    required this.onTap,
    required this.onMore,
  });

  final AiConversationIndexEntry entry;
  final AiAssistantRoleTheme roleTheme;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = entry.title == AiAssistantCubit.untitledConversationTitle
        ? l10n.aiAssistantUntitledConversation
        : entry.title;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: roleTheme.primary.withValues(alpha: 0.10),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: roleTheme.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: roleTheme.headerGradient,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: roleTheme.headerGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (entry.isPinned)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: roleTheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    l10n.aiAssistantPinConversation,
                                    style: TextStyle(
                                      color: roleTheme.primary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.preview?.trim().isNotEmpty == true
                                ? entry.preview!
                                : l10n.aiAssistantHistoryPreviewFallback,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              _MetaChip(
                                label: _providerLabel(entry.providerId),
                                color: roleTheme.primary,
                              ),
                              _MetaChip(
                                label: entry.modelId,
                                color: roleTheme.secondary,
                              ),
                              _MetaChip(
                                label: DateFormat(
                                  'MMM d • h:mm a',
                                ).format(entry.updatedAt),
                                color: const Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: roleTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onMore,
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(Icons.more_horiz_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: roleTheme.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: roleTheme.headerGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiAssistantHistoryEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiAssistantHistoryEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchesCard extends StatelessWidget {
  const _NoMatchesCard({required this.roleTheme});

  final AiAssistantRoleTheme roleTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: roleTheme.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: roleTheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.filter_alt_off_rounded,
              color: roleTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.aiAssistantHistoryNoMatchesTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiAssistantHistoryNoMatchesSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySheetActionTile extends StatelessWidget {
  const _HistorySheetActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF334155);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentOption {
  const _AgentOption({
    required this.title,
    required this.subtitle,
    required this.scope,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final AiContextScope scope;
  final IconData icon;
  final Color color;
}

enum _HistoryAction { open, pin, rename, export, delete }

enum _HistoryBucketFilter { all, pinned, recent }

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
