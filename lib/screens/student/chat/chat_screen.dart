import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/shared/chat/shared_conversation_list.dart';

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
    );
  }
}
