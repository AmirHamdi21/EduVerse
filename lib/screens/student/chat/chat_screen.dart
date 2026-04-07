import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/shared/chat/shared_conversation_list.dart';
import '../../../widgets/shared/chat/shared_new_chat_dialog.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SharedConversationList(
          accentColor: const Color(0xFF3B82F6),
          isDark: isDark,
          title: l10n.messages,
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewConversationDialog(context),
        tooltip: 'New Conversation',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    // Reset dialog state before showing
    context.read<ChatBloc>().add(const ChatNewConversationDialogReset());

    showDialog<int?>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ChatBloc>(),
        child: const SharedNewChatDialog(),
      ),
    ).then((conversationId) {
      if (conversationId != null) {
        // Navigate to the created/existing conversation
        // The navigation will be handled by the existing chat detail view mechanism
      }
    });
  }
}
