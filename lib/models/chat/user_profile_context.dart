import 'package:equatable/equatable.dart';

import '../../bloc/chat/chat_models.dart';

class UserProfileContext extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? role;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<ConversationModel> commonGroups;

  const UserProfileContext({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.role,
    required this.isOnline,
    this.lastSeen,
    this.commonGroups = const <ConversationModel>[],
  });

  String get initials {
    final leading = firstName.trim();
    final trailing = lastName.trim();

    if (leading.isNotEmpty && trailing.isNotEmpty) {
      return '${leading[0]}${trailing[0]}'.toUpperCase();
    }

    final tokens = fullName
        .split(RegExp(r'\s+'))
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return 'U';
    }

    if (tokens.length == 1) {
      final token = tokens.first;
      return token.length == 1
          ? token.toUpperCase()
          : token.substring(0, 2).toUpperCase();
    }

    return '${tokens.first[0]}${tokens[1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
    userId,
    firstName,
    lastName,
    fullName,
    email,
    role,
    isOnline,
    lastSeen,
    commonGroups,
  ];
}
