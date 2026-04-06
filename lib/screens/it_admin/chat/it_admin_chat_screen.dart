import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/it_admin/shared/it_drawer.dart';
import '../../../widgets/shared/chat/shared_conversation_list.dart';

class ITAdminChatScreen extends StatefulWidget {
  const ITAdminChatScreen({super.key});

  @override
  State<ITAdminChatScreen> createState() => _ITAdminChatScreenState();
}

class _ITAdminChatScreenState extends State<ITAdminChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          drawer: ITDrawer(currentRoute: '/it-admin/messages', isDark: isDark),
          body: SafeArea(
            child: SharedConversationList(
              accentColor: const Color(0xFF3B82F6),
              isDark: isDark,
              title: l10n.messages,
              leadingIcon: Icons.menu_rounded,
              onLeadingPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        );
      },
    );
  }
}
