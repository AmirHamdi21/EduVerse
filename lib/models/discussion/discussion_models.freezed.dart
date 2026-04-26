// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiscussionThread _$DiscussionThreadFromJson(Map<String, dynamic> json) {
  return _DiscussionThread.fromJson(json);
}

/// @nodoc
mixin _$DiscussionThread {
  int get id => throw _privateConstructorUsedError;
  int? get courseId => throw _privateConstructorUsedError;
  int get createdBy => throw _privateConstructorUsedError;
  String get createdByName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isPinned => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get replyCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DiscussionThread to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionThreadCopyWith<DiscussionThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionThreadCopyWith<$Res> {
  factory $DiscussionThreadCopyWith(
    DiscussionThread value,
    $Res Function(DiscussionThread) then,
  ) = _$DiscussionThreadCopyWithImpl<$Res, DiscussionThread>;
  @useResult
  $Res call({
    int id,
    int? courseId,
    int createdBy,
    String createdByName,
    String title,
    String description,
    bool isPinned,
    bool isLocked,
    int viewCount,
    int replyCount,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$DiscussionThreadCopyWithImpl<$Res, $Val extends DiscussionThread>
    implements $DiscussionThreadCopyWith<$Res> {
  _$DiscussionThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = freezed,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? title = null,
    Object? description = null,
    Object? isPinned = null,
    Object? isLocked = null,
    Object? viewCount = null,
    Object? replyCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            courseId: freezed == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as int,
            createdByName: null == createdByName
                ? _value.createdByName
                : createdByName // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLocked: null == isLocked
                ? _value.isLocked
                : isLocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            replyCount: null == replyCount
                ? _value.replyCount
                : replyCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscussionThreadImplCopyWith<$Res>
    implements $DiscussionThreadCopyWith<$Res> {
  factory _$$DiscussionThreadImplCopyWith(
    _$DiscussionThreadImpl value,
    $Res Function(_$DiscussionThreadImpl) then,
  ) = __$$DiscussionThreadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? courseId,
    int createdBy,
    String createdByName,
    String title,
    String description,
    bool isPinned,
    bool isLocked,
    int viewCount,
    int replyCount,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DiscussionThreadImplCopyWithImpl<$Res>
    extends _$DiscussionThreadCopyWithImpl<$Res, _$DiscussionThreadImpl>
    implements _$$DiscussionThreadImplCopyWith<$Res> {
  __$$DiscussionThreadImplCopyWithImpl(
    _$DiscussionThreadImpl _value,
    $Res Function(_$DiscussionThreadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = freezed,
    Object? createdBy = null,
    Object? createdByName = null,
    Object? title = null,
    Object? description = null,
    Object? isPinned = null,
    Object? isLocked = null,
    Object? viewCount = null,
    Object? replyCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DiscussionThreadImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        courseId: freezed == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as int,
        createdByName: null == createdByName
            ? _value.createdByName
            : createdByName // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLocked: null == isLocked
            ? _value.isLocked
            : isLocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        replyCount: null == replyCount
            ? _value.replyCount
            : replyCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscussionThreadImpl implements _DiscussionThread {
  const _$DiscussionThreadImpl({
    required this.id,
    this.courseId,
    required this.createdBy,
    this.createdByName = '',
    required this.title,
    required this.description,
    this.isPinned = false,
    this.isLocked = false,
    this.viewCount = 0,
    this.replyCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$DiscussionThreadImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscussionThreadImplFromJson(json);

  @override
  final int id;
  @override
  final int? courseId;
  @override
  final int createdBy;
  @override
  @JsonKey()
  final String createdByName;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final bool isPinned;
  @override
  @JsonKey()
  final bool isLocked;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int replyCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DiscussionThread(id: $id, courseId: $courseId, createdBy: $createdBy, createdByName: $createdByName, title: $title, description: $description, isPinned: $isPinned, isLocked: $isLocked, viewCount: $viewCount, replyCount: $replyCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionThreadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    courseId,
    createdBy,
    createdByName,
    title,
    description,
    isPinned,
    isLocked,
    viewCount,
    replyCount,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DiscussionThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionThreadImplCopyWith<_$DiscussionThreadImpl> get copyWith =>
      __$$DiscussionThreadImplCopyWithImpl<_$DiscussionThreadImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscussionThreadImplToJson(this);
  }
}

abstract class _DiscussionThread implements DiscussionThread {
  const factory _DiscussionThread({
    required final int id,
    final int? courseId,
    required final int createdBy,
    final String createdByName,
    required final String title,
    required final String description,
    final bool isPinned,
    final bool isLocked,
    final int viewCount,
    final int replyCount,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$DiscussionThreadImpl;

  factory _DiscussionThread.fromJson(Map<String, dynamic> json) =
      _$DiscussionThreadImpl.fromJson;

  @override
  int get id;
  @override
  int? get courseId;
  @override
  int get createdBy;
  @override
  String get createdByName;
  @override
  String get title;
  @override
  String get description;
  @override
  bool get isPinned;
  @override
  bool get isLocked;
  @override
  int get viewCount;
  @override
  int get replyCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of DiscussionThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionThreadImplCopyWith<_$DiscussionThreadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscussionReply _$DiscussionReplyFromJson(Map<String, dynamic> json) {
  return _DiscussionReply.fromJson(json);
}

/// @nodoc
mixin _$DiscussionReply {
  int get id => throw _privateConstructorUsedError;
  int get threadId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get messageText => throw _privateConstructorUsedError;
  int? get parentMessageId => throw _privateConstructorUsedError;
  bool get isAnswer => throw _privateConstructorUsedError;
  bool get isEndorsed => throw _privateConstructorUsedError;
  int get upvoteCount => throw _privateConstructorUsedError;
  int? get endorsedBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DiscussionReply to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionReplyCopyWith<DiscussionReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionReplyCopyWith<$Res> {
  factory $DiscussionReplyCopyWith(
    DiscussionReply value,
    $Res Function(DiscussionReply) then,
  ) = _$DiscussionReplyCopyWithImpl<$Res, DiscussionReply>;
  @useResult
  $Res call({
    int id,
    int threadId,
    int userId,
    String userName,
    String messageText,
    int? parentMessageId,
    bool isAnswer,
    bool isEndorsed,
    int upvoteCount,
    int? endorsedBy,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$DiscussionReplyCopyWithImpl<$Res, $Val extends DiscussionReply>
    implements $DiscussionReplyCopyWith<$Res> {
  _$DiscussionReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? threadId = null,
    Object? userId = null,
    Object? userName = null,
    Object? messageText = null,
    Object? parentMessageId = freezed,
    Object? isAnswer = null,
    Object? isEndorsed = null,
    Object? upvoteCount = null,
    Object? endorsedBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            threadId: null == threadId
                ? _value.threadId
                : threadId // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            messageText: null == messageText
                ? _value.messageText
                : messageText // ignore: cast_nullable_to_non_nullable
                      as String,
            parentMessageId: freezed == parentMessageId
                ? _value.parentMessageId
                : parentMessageId // ignore: cast_nullable_to_non_nullable
                      as int?,
            isAnswer: null == isAnswer
                ? _value.isAnswer
                : isAnswer // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEndorsed: null == isEndorsed
                ? _value.isEndorsed
                : isEndorsed // ignore: cast_nullable_to_non_nullable
                      as bool,
            upvoteCount: null == upvoteCount
                ? _value.upvoteCount
                : upvoteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            endorsedBy: freezed == endorsedBy
                ? _value.endorsedBy
                : endorsedBy // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscussionReplyImplCopyWith<$Res>
    implements $DiscussionReplyCopyWith<$Res> {
  factory _$$DiscussionReplyImplCopyWith(
    _$DiscussionReplyImpl value,
    $Res Function(_$DiscussionReplyImpl) then,
  ) = __$$DiscussionReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int threadId,
    int userId,
    String userName,
    String messageText,
    int? parentMessageId,
    bool isAnswer,
    bool isEndorsed,
    int upvoteCount,
    int? endorsedBy,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DiscussionReplyImplCopyWithImpl<$Res>
    extends _$DiscussionReplyCopyWithImpl<$Res, _$DiscussionReplyImpl>
    implements _$$DiscussionReplyImplCopyWith<$Res> {
  __$$DiscussionReplyImplCopyWithImpl(
    _$DiscussionReplyImpl _value,
    $Res Function(_$DiscussionReplyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? threadId = null,
    Object? userId = null,
    Object? userName = null,
    Object? messageText = null,
    Object? parentMessageId = freezed,
    Object? isAnswer = null,
    Object? isEndorsed = null,
    Object? upvoteCount = null,
    Object? endorsedBy = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DiscussionReplyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        threadId: null == threadId
            ? _value.threadId
            : threadId // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        messageText: null == messageText
            ? _value.messageText
            : messageText // ignore: cast_nullable_to_non_nullable
                  as String,
        parentMessageId: freezed == parentMessageId
            ? _value.parentMessageId
            : parentMessageId // ignore: cast_nullable_to_non_nullable
                  as int?,
        isAnswer: null == isAnswer
            ? _value.isAnswer
            : isAnswer // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEndorsed: null == isEndorsed
            ? _value.isEndorsed
            : isEndorsed // ignore: cast_nullable_to_non_nullable
                  as bool,
        upvoteCount: null == upvoteCount
            ? _value.upvoteCount
            : upvoteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        endorsedBy: freezed == endorsedBy
            ? _value.endorsedBy
            : endorsedBy // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscussionReplyImpl implements _DiscussionReply {
  const _$DiscussionReplyImpl({
    required this.id,
    required this.threadId,
    required this.userId,
    this.userName = '',
    required this.messageText,
    this.parentMessageId,
    this.isAnswer = false,
    this.isEndorsed = false,
    this.upvoteCount = 0,
    this.endorsedBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$DiscussionReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscussionReplyImplFromJson(json);

  @override
  final int id;
  @override
  final int threadId;
  @override
  final int userId;
  @override
  @JsonKey()
  final String userName;
  @override
  final String messageText;
  @override
  final int? parentMessageId;
  @override
  @JsonKey()
  final bool isAnswer;
  @override
  @JsonKey()
  final bool isEndorsed;
  @override
  @JsonKey()
  final int upvoteCount;
  @override
  final int? endorsedBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DiscussionReply(id: $id, threadId: $threadId, userId: $userId, userName: $userName, messageText: $messageText, parentMessageId: $parentMessageId, isAnswer: $isAnswer, isEndorsed: $isEndorsed, upvoteCount: $upvoteCount, endorsedBy: $endorsedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionReplyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.threadId, threadId) ||
                other.threadId == threadId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.messageText, messageText) ||
                other.messageText == messageText) &&
            (identical(other.parentMessageId, parentMessageId) ||
                other.parentMessageId == parentMessageId) &&
            (identical(other.isAnswer, isAnswer) ||
                other.isAnswer == isAnswer) &&
            (identical(other.isEndorsed, isEndorsed) ||
                other.isEndorsed == isEndorsed) &&
            (identical(other.upvoteCount, upvoteCount) ||
                other.upvoteCount == upvoteCount) &&
            (identical(other.endorsedBy, endorsedBy) ||
                other.endorsedBy == endorsedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    threadId,
    userId,
    userName,
    messageText,
    parentMessageId,
    isAnswer,
    isEndorsed,
    upvoteCount,
    endorsedBy,
    createdAt,
    updatedAt,
  );

  /// Create a copy of DiscussionReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionReplyImplCopyWith<_$DiscussionReplyImpl> get copyWith =>
      __$$DiscussionReplyImplCopyWithImpl<_$DiscussionReplyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscussionReplyImplToJson(this);
  }
}

abstract class _DiscussionReply implements DiscussionReply {
  const factory _DiscussionReply({
    required final int id,
    required final int threadId,
    required final int userId,
    final String userName,
    required final String messageText,
    final int? parentMessageId,
    final bool isAnswer,
    final bool isEndorsed,
    final int upvoteCount,
    final int? endorsedBy,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$DiscussionReplyImpl;

  factory _DiscussionReply.fromJson(Map<String, dynamic> json) =
      _$DiscussionReplyImpl.fromJson;

  @override
  int get id;
  @override
  int get threadId;
  @override
  int get userId;
  @override
  String get userName;
  @override
  String get messageText;
  @override
  int? get parentMessageId;
  @override
  bool get isAnswer;
  @override
  bool get isEndorsed;
  @override
  int get upvoteCount;
  @override
  int? get endorsedBy;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of DiscussionReply
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionReplyImplCopyWith<_$DiscussionReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) {
  return _PaginationMeta.fromJson(json);
}

/// @nodoc
mixin _$PaginationMeta {
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this PaginationMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationMetaCopyWith<PaginationMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationMetaCopyWith<$Res> {
  factory $PaginationMetaCopyWith(
    PaginationMeta value,
    $Res Function(PaginationMeta) then,
  ) = _$PaginationMetaCopyWithImpl<$Res, PaginationMeta>;
  @useResult
  $Res call({int page, int limit, int total, bool hasMore});
}

/// @nodoc
class _$PaginationMetaCopyWithImpl<$Res, $Val extends PaginationMeta>
    implements $PaginationMetaCopyWith<$Res> {
  _$PaginationMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginationMetaImplCopyWith<$Res>
    implements $PaginationMetaCopyWith<$Res> {
  factory _$$PaginationMetaImplCopyWith(
    _$PaginationMetaImpl value,
    $Res Function(_$PaginationMetaImpl) then,
  ) = __$$PaginationMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int page, int limit, int total, bool hasMore});
}

/// @nodoc
class __$$PaginationMetaImplCopyWithImpl<$Res>
    extends _$PaginationMetaCopyWithImpl<$Res, _$PaginationMetaImpl>
    implements _$$PaginationMetaImplCopyWith<$Res> {
  __$$PaginationMetaImplCopyWithImpl(
    _$PaginationMetaImpl _value,
    $Res Function(_$PaginationMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$PaginationMetaImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationMetaImpl implements _PaginationMeta {
  const _$PaginationMetaImpl({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.hasMore = false,
  });

  factory _$PaginationMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationMetaImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final bool hasMore;

  @override
  String toString() {
    return 'PaginationMeta(page: $page, limit: $limit, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationMetaImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, page, limit, total, hasMore);

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationMetaImplCopyWith<_$PaginationMetaImpl> get copyWith =>
      __$$PaginationMetaImplCopyWithImpl<_$PaginationMetaImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationMetaImplToJson(this);
  }
}

abstract class _PaginationMeta implements PaginationMeta {
  const factory _PaginationMeta({
    final int page,
    final int limit,
    final int total,
    final bool hasMore,
  }) = _$PaginationMetaImpl;

  factory _PaginationMeta.fromJson(Map<String, dynamic> json) =
      _$PaginationMetaImpl.fromJson;

  @override
  int get page;
  @override
  int get limit;
  @override
  int get total;
  @override
  bool get hasMore;

  /// Create a copy of PaginationMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationMetaImplCopyWith<_$PaginationMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DiscussionThreadPage {
  List<DiscussionThread> get data => throw _privateConstructorUsedError;
  PaginationMeta get meta => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionThreadPageCopyWith<DiscussionThreadPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionThreadPageCopyWith<$Res> {
  factory $DiscussionThreadPageCopyWith(
    DiscussionThreadPage value,
    $Res Function(DiscussionThreadPage) then,
  ) = _$DiscussionThreadPageCopyWithImpl<$Res, DiscussionThreadPage>;
  @useResult
  $Res call({List<DiscussionThread> data, PaginationMeta meta});

  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$DiscussionThreadPageCopyWithImpl<
  $Res,
  $Val extends DiscussionThreadPage
>
    implements $DiscussionThreadPageCopyWith<$Res> {
  _$DiscussionThreadPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<DiscussionThread>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as PaginationMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationMetaCopyWith<$Res> get meta {
    return $PaginationMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscussionThreadPageImplCopyWith<$Res>
    implements $DiscussionThreadPageCopyWith<$Res> {
  factory _$$DiscussionThreadPageImplCopyWith(
    _$DiscussionThreadPageImpl value,
    $Res Function(_$DiscussionThreadPageImpl) then,
  ) = __$$DiscussionThreadPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DiscussionThread> data, PaginationMeta meta});

  @override
  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$DiscussionThreadPageImplCopyWithImpl<$Res>
    extends _$DiscussionThreadPageCopyWithImpl<$Res, _$DiscussionThreadPageImpl>
    implements _$$DiscussionThreadPageImplCopyWith<$Res> {
  __$$DiscussionThreadPageImplCopyWithImpl(
    _$DiscussionThreadPageImpl _value,
    $Res Function(_$DiscussionThreadPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _$DiscussionThreadPageImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<DiscussionThread>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as PaginationMeta,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionThreadPageImpl implements _DiscussionThreadPage {
  const _$DiscussionThreadPageImpl({
    final List<DiscussionThread> data = const <DiscussionThread>[],
    this.meta = const PaginationMeta(),
  }) : _data = data;

  final List<DiscussionThread> _data;
  @override
  @JsonKey()
  List<DiscussionThread> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey()
  final PaginationMeta meta;

  @override
  String toString() {
    return 'DiscussionThreadPage(data: $data, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionThreadPageImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.meta, meta) || other.meta == meta));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    meta,
  );

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionThreadPageImplCopyWith<_$DiscussionThreadPageImpl>
  get copyWith =>
      __$$DiscussionThreadPageImplCopyWithImpl<_$DiscussionThreadPageImpl>(
        this,
        _$identity,
      );
}

abstract class _DiscussionThreadPage implements DiscussionThreadPage {
  const factory _DiscussionThreadPage({
    final List<DiscussionThread> data,
    final PaginationMeta meta,
  }) = _$DiscussionThreadPageImpl;

  @override
  List<DiscussionThread> get data;
  @override
  PaginationMeta get meta;

  /// Create a copy of DiscussionThreadPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionThreadPageImplCopyWith<_$DiscussionThreadPageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DiscussionReplyPage {
  List<DiscussionReply> get data => throw _privateConstructorUsedError;
  PaginationMeta get meta => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionReplyPageCopyWith<DiscussionReplyPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionReplyPageCopyWith<$Res> {
  factory $DiscussionReplyPageCopyWith(
    DiscussionReplyPage value,
    $Res Function(DiscussionReplyPage) then,
  ) = _$DiscussionReplyPageCopyWithImpl<$Res, DiscussionReplyPage>;
  @useResult
  $Res call({List<DiscussionReply> data, PaginationMeta meta});

  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class _$DiscussionReplyPageCopyWithImpl<$Res, $Val extends DiscussionReplyPage>
    implements $DiscussionReplyPageCopyWith<$Res> {
  _$DiscussionReplyPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<DiscussionReply>,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as PaginationMeta,
          )
          as $Val,
    );
  }

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationMetaCopyWith<$Res> get meta {
    return $PaginationMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscussionReplyPageImplCopyWith<$Res>
    implements $DiscussionReplyPageCopyWith<$Res> {
  factory _$$DiscussionReplyPageImplCopyWith(
    _$DiscussionReplyPageImpl value,
    $Res Function(_$DiscussionReplyPageImpl) then,
  ) = __$$DiscussionReplyPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DiscussionReply> data, PaginationMeta meta});

  @override
  $PaginationMetaCopyWith<$Res> get meta;
}

/// @nodoc
class __$$DiscussionReplyPageImplCopyWithImpl<$Res>
    extends _$DiscussionReplyPageCopyWithImpl<$Res, _$DiscussionReplyPageImpl>
    implements _$$DiscussionReplyPageImplCopyWith<$Res> {
  __$$DiscussionReplyPageImplCopyWithImpl(
    _$DiscussionReplyPageImpl _value,
    $Res Function(_$DiscussionReplyPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? meta = null}) {
    return _then(
      _$DiscussionReplyPageImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<DiscussionReply>,
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as PaginationMeta,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionReplyPageImpl implements _DiscussionReplyPage {
  const _$DiscussionReplyPageImpl({
    final List<DiscussionReply> data = const <DiscussionReply>[],
    this.meta = const PaginationMeta(),
  }) : _data = data;

  final List<DiscussionReply> _data;
  @override
  @JsonKey()
  List<DiscussionReply> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey()
  final PaginationMeta meta;

  @override
  String toString() {
    return 'DiscussionReplyPage(data: $data, meta: $meta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionReplyPageImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.meta, meta) || other.meta == meta));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    meta,
  );

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionReplyPageImplCopyWith<_$DiscussionReplyPageImpl> get copyWith =>
      __$$DiscussionReplyPageImplCopyWithImpl<_$DiscussionReplyPageImpl>(
        this,
        _$identity,
      );
}

abstract class _DiscussionReplyPage implements DiscussionReplyPage {
  const factory _DiscussionReplyPage({
    final List<DiscussionReply> data,
    final PaginationMeta meta,
  }) = _$DiscussionReplyPageImpl;

  @override
  List<DiscussionReply> get data;
  @override
  PaginationMeta get meta;

  /// Create a copy of DiscussionReplyPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionReplyPageImplCopyWith<_$DiscussionReplyPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
