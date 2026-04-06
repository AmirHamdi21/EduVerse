import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../generated_l10n/app_localizations.dart';
import '../../../widgets/shared/chat/shared_conversation_list.dart';
import '../../../widgets/ta/dashboard/ta_drawer.dart';
import '../../../widgets/ta/shared/ta_colors.dart';

class TAMessagesScreen extends StatefulWidget {
  const TAMessagesScreen({super.key});

  @override
  State<TAMessagesScreen> createState() => _TAMessagesScreenState();
}

class _TAMessagesScreenState extends State<TAMessagesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == AppThemeMode.dark;
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: TAColors.scaffoldColor(isDark),
          drawer: const TADrawer(currentRoute: '/ta/messages'),
          body: SafeArea(
            child: SharedConversationList(
              accentColor: const Color(0xFF4F46E5),
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
