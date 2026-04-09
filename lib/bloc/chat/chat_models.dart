import 'package:equatable/equatable.dart';

enum ConversationType {
  direct,
  group;

  static ConversationType fromJsonValue(dynamic raw, {bool? isGroup}) {
    final normalized = raw?.toString().toLowerCase();
    if (normalized == 'group' || isGroup == true) {
      return ConversationType.group;
    }
    return ConversationType.direct;
  }

  String get jsonValue => name;
}

class ChatUserModel extends Equatable {
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;

  const ChatUserModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      userId: _parseInt(json['userId'] ?? json['id']),
      firstName: _parseStringOrNull(json['firstName']),
      lastName: _parseStringOrNull(json['lastName']),
      fullName: _parseStringOrNull(json['fullName']),
      email: _parseStringOrNull(json['email']),
    );
  }

  ChatUserModel copyWith({
    int? userId,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
  }) {
    return ChatUserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }

  String get displayName {
    final normalizedFullName = _normalizeNullableString(fullName);
    if (normalizedFullName != null) {
      return normalizedFullName;
    }

    final merged = _joinNonEmpty([firstName, lastName]);
    if (merged.isNotEmpty) {
      return merged;
    }

    return email ?? 'User $userId';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
    };
  }

  @override
  List<Object?> get props => [userId, firstName, lastName, fullName, email];
}

class ConversationModel extends Equatable {
  final int conversationId;
  final ConversationType type;
  final String? name;
  final List<int> participants;
  final List<ChatUserModel> participantUsers;
  final ChatUserModel? directDisplayUser;
  final String? lastMessage;
  final ChatMessageModel? lastMessageInfo;
  final int unreadCount;
  final DateTime? lastMessageAt;

  const ConversationModel({
    required this.conversationId,
    required this.type,
    this.name,
    this.participants = const [],
    this.participantUsers = const [],
    this.directDisplayUser,
    this.lastMessage,
    this.lastMessageInfo,
    this.unreadCount = 0,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participantsRaw = _asList(json['participants']);
    final participantUsers = _extractMapList(
      json['participantUsers'],
    ).map(ChatUserModel.fromJson).toList();

    final participants = participantsRaw
        .map((entry) {
          if (entry is Map) {
            final map = _asMap(entry);
            return _parseInt(map['userId'] ?? map['id']);
          }
          return _parseInt(entry);
        })
        .where((id) => id > 0)
        .toList();

    final directDisplayUserMap = _asMap(json['directDisplayUser']);
    final directDisplayUser = directDisplayUserMap.isEmpty
        ? null
        : ChatUserModel.fromJson(directDisplayUserMap);

    final parsedType = ConversationType.fromJsonValue(
      json['type'],
      isGroup: _parseBoolOrNull(json['isGroup']),
    );

    final rawLastMessage = json['lastMessage'];
    final lastMessageText = _firstNonEmptyString([
      _parseStringOrNull(_asMap(rawLastMessage)['text']),
      _parseStringOrNull(_asMap(rawLastMessage)['body']),
      _parseStringOrNull(_asMap(rawLastMessage)['content']),
      rawLastMessage is String ? _parseStringOrNull(rawLastMessage) : null,
    ]);

    final lastMessageInfo = _parseLastMessageInfo(
      json['lastMessageInfo'] ?? rawLastMessage,
      fallbackConversationId: _parseInt(json['conversationId'] ?? json['id']),
    );

    return ConversationModel(
      conversationId: _parseInt(json['conversationId'] ?? json['id']),
      type: parsedType,
      name: _firstNonEmptyString([
        _parseStringOrNull(json['name']),
        _parseStringOrNull(json['title']),
      ]),
      participants: participants,
      participantUsers: participantUsers,
      directDisplayUser: directDisplayUser,
      lastMessage: lastMessageText,
      lastMessageInfo: lastMessageInfo,
      unreadCount: _parseInt(json['unreadCount']),
      lastMessageAt:
          _parseDateTime(
            json['lastMessageAt'] ?? json['updatedAt'] ?? json['createdAt'],
          ) ??
          lastMessageInfo?.sentAt,
    );
  }

  ConversationModel copyWith({
    int? conversationId,
    ConversationType? type,
    String? name,
    List<int>? participants,
    List<ChatUserModel>? participantUsers,
    ChatUserModel? directDisplayUser,
    String? lastMessage,
    ChatMessageModel? lastMessageInfo,
    int? unreadCount,
    DateTime? lastMessageAt,
    bool clearDirectDisplayUser = false,
    bool clearLastMessage = false,
    bool clearLastMessageInfo = false,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      participantUsers: participantUsers ?? this.participantUsers,
      directDisplayUser: clearDirectDisplayUser
          ? null
          : directDisplayUser ?? this.directDisplayUser,
      lastMessage: clearLastMessage ? null : lastMessage ?? this.lastMessage,
      lastMessageInfo: clearLastMessageInfo
          ? null
          : lastMessageInfo ?? this.lastMessageInfo,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  String get id => conversationId.toString();

  String get title {
    final normalized = _normalizeNullableString(name);
    if (normalized != null) {
      return normalized;
    }
    return directDisplayUser?.displayName ?? 'Conversation $conversationId';
  }

  DateTime get updatedAt =>
      lastMessageAt ?? lastMessageInfo?.sentAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'type': type.jsonValue,
      if (name != null) 'name': name,
      'participants': participants,
      'participantUsers': participantUsers
          .map((participant) => participant.toJson())
          .toList(),
      if (directDisplayUser != null)
        'directDisplayUser': directDisplayUser!.toJson(),
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageInfo != null) 'lastMessageInfo': lastMessageInfo!.toJson(),
      'unreadCount': unreadCount,
      if (lastMessageAt != null)
        'lastMessageAt': lastMessageAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    conversationId,
    type,
    name,
    participants,
    participantUsers,
    directDisplayUser,
    lastMessage,
    lastMessageInfo,
    unreadCount,
    lastMessageAt,
  ];
}

class ChatMessageModel extends Equatable {
  static const String defaultDeletedText = 'This message was deleted';

  final int id;
  final String text;
  final int senderId;
  final String? senderName;
  final DateTime sentAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final String deletedText;
  final int? replyToId;
  final int conversationId;
  final String status;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    this.senderName,
    required this.sentAt,
    this.editedAt,
    this.isDeleted = false,
    this.deletedText = defaultDeletedText,
    this.replyToId,
    required this.conversationId,
    this.status = 'sent',
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderMap = _asMap(json['sender']);
    final isDeleted = _parseBool(json['isDeleted']);

    final deletedText =
        _firstNonEmptyString([
          _parseStringOrNull(json['deletedText']),
          _parseStringOrNull(json['deleteText']),
        ]) ??
        defaultDeletedText;

    final parsedText =
        _firstNonEmptyString([
          _parseStringOrNull(json['text']),
          _parseStringOrNull(json['body']),
          _parseStringOrNull(json['content']),
        ]) ??
        (isDeleted ? deletedText : '');

    final parsedSenderName = _firstNonEmptyString([
      _parseStringOrNull(json['senderName']),
      _joinNonEmpty([
        _parseStringOrNull(json['senderFirstName']),
        _parseStringOrNull(json['senderLastName']),
      ]),
      _parseStringOrNull(senderMap['fullName']),
      _joinNonEmpty([
        _parseStringOrNull(senderMap['firstName']),
        _parseStringOrNull(senderMap['lastName']),
      ]),
    ]);

    return ChatMessageModel(
      id: _parseInt(json['id'] ?? json['messageId']),
      text: parsedText,
      senderId: _parseInt(
        json['senderId'] ?? json['senderUserId'] ?? senderMap['userId'],
      ),
      senderName: parsedSenderName,
      sentAt:
          _parseDateTime(
            json['sentAt'] ?? json['createdAt'] ?? json['updatedAt'],
          ) ??
          DateTime.now().toUtc(),
      editedAt: _parseDateTime(json['editedAt']),
      isDeleted: isDeleted,
      deletedText: deletedText,
      replyToId: _parseIntOrNull(json['replyToId']),
      conversationId: _parseInt(json['conversationId']),
      status:
          _firstNonEmptyString([
            _parseStringOrNull(json['status']),
            isDeleted ? 'deleted' : null,
          ]) ??
          'sent',
    );
  }

  factory ChatMessageModel.fromSocketPayload(dynamic payload) {
    return ChatMessageModel.fromJson(_normalizeMessagePayload(payload));
  }

  ChatMessageModel copyWith({
    int? id,
    String? text,
    int? senderId,
    String? senderName,
    DateTime? sentAt,
    DateTime? editedAt,
    bool? isDeleted,
    String? deletedText,
    int? replyToId,
    int? conversationId,
    String? status,
    bool clearReplyToId = false,
    bool clearEditedAt = false,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      sentAt: sentAt ?? this.sentAt,
      editedAt: clearEditedAt ? null : editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedText: deletedText ?? this.deletedText,
      replyToId: clearReplyToId ? null : replyToId ?? this.replyToId,
      conversationId: conversationId ?? this.conversationId,
      status: status ?? this.status,
    );
  }

  bool get isFailed => status.toLowerCase() == 'failed';

  String get idAsString => id.toString();

  DateTime get timestamp => sentAt;

  String get content => text;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      'sentAt': sentAt.toIso8601String(),
      if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedText': deletedText,
      if (replyToId != null) 'replyToId': replyToId,
      'conversationId': conversationId,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
    id,
    text,
    senderId,
    senderName,
    sentAt,
    editedAt,
    isDeleted,
    deletedText,
    replyToId,
    conversationId,
    status,
  ];
}

class UserTypingEvent extends Equatable {
  final int conversationId;
  final int userId;
  final bool isTyping;

  const UserTypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  factory UserTypingEvent.fromJson(Map<String, dynamic> json) {
    return UserTypingEvent(
      conversationId: _parseInt(json['conversationId']),
      userId: _parseInt(json['userId']),
      isTyping: _parseBool(json['isTyping']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
    };
  }

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}

class MessageReadEvent extends Equatable {
  final int messageId;
  final int conversationId;
  final int userId;

  const MessageReadEvent({
    required this.messageId,
    required this.conversationId,
    required this.userId,
  });

  factory MessageReadEvent.fromJson(Map<String, dynamic> json) {
    return MessageReadEvent(
      messageId: _parseInt(json['messageId'] ?? json['id']),
      conversationId: _parseInt(json['conversationId']),
      userId: _parseInt(json['userId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [messageId, conversationId, userId];
}

Map<String, dynamic> _normalizeMessagePayload(dynamic payload) {
  final map = _unwrapPayload(payload);
  final normalized = _normalizeMessageMap(map);
  return normalized;
}

Map<String, dynamic> _normalizeMessageMap(Map<String, dynamic> map) {
  return {
    ...map,
    'id': _parseInt(map['id'] ?? map['messageId']),
    'conversationId': _parseInt(map['conversationId']),
    'senderId': _parseInt(map['senderId'] ?? map['senderUserId']),
    'text': _firstNonEmptyString([
      _parseStringOrNull(map['text']),
      _parseStringOrNull(map['body']),
      _parseStringOrNull(map['content']),
    ]),
  };
}

ChatMessageModel? _parseLastMessageInfo(
  dynamic value, {
  required int fallbackConversationId,
}) {
  final map = _asMap(value);
  if (map.isEmpty) {
    return null;
  }

  final normalized = {
    ...map,
    'conversationId': _parseInt(
      map['conversationId'] ?? fallbackConversationId,
      fallback: fallbackConversationId,
    ),
    'id': _parseInt(map['id'] ?? map['messageId']),
  };

  return ChatMessageModel.fromJson(normalized);
}

Map<String, dynamic> _unwrapPayload(dynamic payload) {
  final map = _asMap(payload);
  if (map['data'] is Map) {
    return _asMap(map['data']);
  }
  if (map['message'] is Map) {
    return _asMap(map['message']);
  }
  return map;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, dynamic val) {
      return MapEntry(key.toString(), val);
    });
  }
  return const {};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) {
    return value;
  }
  return const [];
}

List<Map<String, dynamic>> _extractMapList(dynamic value) {
  return _asList(value).map(_asMap).where((entry) => entry.isNotEmpty).toList();
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _parseIntOrNull(dynamic value) {
  final parsed = _parseInt(value, fallback: -1);
  if (parsed < 0) {
    return null;
  }
  return parsed;
}

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

bool? _parseBoolOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  return _parseBool(value);
}

DateTime? _parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}

String? _parseStringOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
  return value.toString();
}

String? _normalizeNullableString(String? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return null;
  }
  return normalized;
}

String _joinNonEmpty(List<String?> values) {
  final filtered = values
      .map(_normalizeNullableString)
      .whereType<String>()
      .toList();
  return filtered.join(' ').trim();
}

String? _firstNonEmptyString(List<String?> values) {
  for (final value in values) {
    final normalized = _normalizeNullableString(value);
    if (normalized != null) {
      return normalized;
    }
  }
  return null;
}
