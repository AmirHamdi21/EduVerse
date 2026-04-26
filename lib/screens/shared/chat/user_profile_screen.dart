import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_models.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../models/chat/user_profile_context.dart';
import '../../../widgets/shared/chat/profile_header.dart';
import '../../../widgets/shared/chat/profile_info_section.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final user = _resolveUser(state, widget.userId);
          if (user == null) {
            return const Center(child: Text('User data not found.'));
          }

          final commonGroups = state.conversations
              .where(
                (conversation) =>
                    conversation.type == ConversationType.group &&
                    (conversation.participants.contains(widget.userId) ||
                        conversation.participantUsers.any(
                          (participant) => participant.userId == widget.userId,
                        )),
              )
              .toList(growable: false);

          final profile = UserProfileContext(
            userId: user.userId,
            firstName: _resolveFirstName(user),
            lastName: _resolveLastName(user),
            fullName: user.displayName,
            email: _resolveEmail(user),
            role: _resolveRole(user),
            isOnline: state.onlineUsers.contains(user.userId),
            lastSeen: state.userLastSeen[user.userId],
            commonGroups: commonGroups,
          );

          return ListView(
            children: [
              ProfileHeader(
                profile: profile,
                accentColor: Theme.of(context).colorScheme.primary,
              ),
              ProfileInfoSection(
                profile: profile,
                onSendMessage: () async {
                  final router = GoRouter.of(context);
                  final navigator = Navigator.of(context);
                  final chatBloc = context.read<ChatBloc>();

                  final conversationId = await router.push<int>(
                    '/messages/new',
                    extra: user,
                  );
                  if (!mounted ||
                      conversationId == null ||
                      conversationId <= 0) {
                    return;
                  }

                  chatBloc.add(SelectConversation(conversationId));
                  chatBloc.add(MarkRead(conversationId));
                  navigator.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  ChatUserModel? _resolveUser(ChatState state, int userId) {
    final cached = state.participantCache[userId];
    if (cached != null) {
      return cached;
    }

    for (final conversation in state.conversations) {
      if (conversation.directDisplayUser?.userId == userId) {
        return conversation.directDisplayUser;
      }

      final participant = conversation.participantUsers.firstWhere(
        (entry) => entry.userId == userId,
        orElse: () => const ChatUserModel(userId: -1),
      );
      if (participant.userId > 0) {
        return participant;
      }
    }

    return null;
  }

  String _resolveFirstName(ChatUserModel user) {
    final firstName = (user.firstName ?? '').trim();
    if (firstName.isNotEmpty) {
      return firstName;
    }

    final tokens = user.displayName
        .split(RegExp(r'\s+'))
        .where((entry) => entry.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return 'User';
    }

    return tokens.first;
  }

  String _resolveLastName(ChatUserModel user) {
    final lastName = (user.lastName ?? '').trim();
    if (lastName.isNotEmpty) {
      return lastName;
    }

    final tokens = user.displayName
        .split(RegExp(r'\s+'))
        .where((entry) => entry.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.length > 1) {
      return tokens.sublist(1).join(' ');
    }

    return '';
  }

  String _resolveEmail(ChatUserModel user) {
    final email = (user.email ?? '').trim();
    if (email.isNotEmpty) {
      return email;
    }

    return 'Unknown email';
  }

  String _resolveRole(ChatUserModel user) {
    final role = (user.role ?? '').trim();
    if (role.isNotEmpty) {
      return role;
    }

    return 'Member';
  }
}
