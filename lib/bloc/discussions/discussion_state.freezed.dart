// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DiscussionState {
  DiscussionStatus get status => throw _privateConstructorUsedError;
  List<DiscussionThread> get threads => throw _privateConstructorUsedError;
  DiscussionThread? get selectedThread => throw _privateConstructorUsedError;
  List<DiscussionReply> get replies => throw _privateConstructorUsedError;
  bool get isPaginatingThreads => throw _privateConstructorUsedError;
  bool get isPaginatingReplies => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get canModerate => throw _privateConstructorUsedError;
  int? get currentCourseId => throw _privateConstructorUsedError;
  int? get currentUserId => throw _privateConstructorUsedError;
  int get currentThreadPage => throw _privateConstructorUsedError;
  int get currentReplyPage => throw _privateConstructorUsedError;
  bool get hasMoreThreads => throw _privateConstructorUsedError;
  bool get hasMoreReplies => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionStateCopyWith<DiscussionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionStateCopyWith<$Res> {
  factory $DiscussionStateCopyWith(
    DiscussionState value,
    $Res Function(DiscussionState) then,
  ) = _$DiscussionStateCopyWithImpl<$Res, DiscussionState>;
  @useResult
  $Res call({
    DiscussionStatus status,
    List<DiscussionThread> threads,
    DiscussionThread? selectedThread,
    List<DiscussionReply> replies,
    bool isPaginatingThreads,
    bool isPaginatingReplies,
    bool isSubmitting,
    bool canModerate,
    int? currentCourseId,
    int? currentUserId,
    int currentThreadPage,
    int currentReplyPage,
    bool hasMoreThreads,
    bool hasMoreReplies,
    String? errorMessage,
  });

  $DiscussionThreadCopyWith<$Res>? get selectedThread;
}

/// @nodoc
class _$DiscussionStateCopyWithImpl<$Res, $Val extends DiscussionState>
    implements $DiscussionStateCopyWith<$Res> {
  _$DiscussionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? threads = null,
    Object? selectedThread = freezed,
    Object? replies = null,
    Object? isPaginatingThreads = null,
    Object? isPaginatingReplies = null,
    Object? isSubmitting = null,
    Object? canModerate = null,
    Object? currentCourseId = freezed,
    Object? currentUserId = freezed,
    Object? currentThreadPage = null,
    Object? currentReplyPage = null,
    Object? hasMoreThreads = null,
    Object? hasMoreReplies = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DiscussionStatus,
            threads: null == threads
                ? _value.threads
                : threads // ignore: cast_nullable_to_non_nullable
                      as List<DiscussionThread>,
            selectedThread: freezed == selectedThread
                ? _value.selectedThread
                : selectedThread // ignore: cast_nullable_to_non_nullable
                      as DiscussionThread?,
            replies: null == replies
                ? _value.replies
                : replies // ignore: cast_nullable_to_non_nullable
                      as List<DiscussionReply>,
            isPaginatingThreads: null == isPaginatingThreads
                ? _value.isPaginatingThreads
                : isPaginatingThreads // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPaginatingReplies: null == isPaginatingReplies
                ? _value.isPaginatingReplies
                : isPaginatingReplies // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            canModerate: null == canModerate
                ? _value.canModerate
                : canModerate // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentCourseId: freezed == currentCourseId
                ? _value.currentCourseId
                : currentCourseId // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentUserId: freezed == currentUserId
                ? _value.currentUserId
                : currentUserId // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentThreadPage: null == currentThreadPage
                ? _value.currentThreadPage
                : currentThreadPage // ignore: cast_nullable_to_non_nullable
                      as int,
            currentReplyPage: null == currentReplyPage
                ? _value.currentReplyPage
                : currentReplyPage // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMoreThreads: null == hasMoreThreads
                ? _value.hasMoreThreads
                : hasMoreThreads // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasMoreReplies: null == hasMoreReplies
                ? _value.hasMoreReplies
                : hasMoreReplies // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiscussionThreadCopyWith<$Res>? get selectedThread {
    if (_value.selectedThread == null) {
      return null;
    }

    return $DiscussionThreadCopyWith<$Res>(_value.selectedThread!, (value) {
      return _then(_value.copyWith(selectedThread: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscussionStateImplCopyWith<$Res>
    implements $DiscussionStateCopyWith<$Res> {
  factory _$$DiscussionStateImplCopyWith(
    _$DiscussionStateImpl value,
    $Res Function(_$DiscussionStateImpl) then,
  ) = __$$DiscussionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DiscussionStatus status,
    List<DiscussionThread> threads,
    DiscussionThread? selectedThread,
    List<DiscussionReply> replies,
    bool isPaginatingThreads,
    bool isPaginatingReplies,
    bool isSubmitting,
    bool canModerate,
    int? currentCourseId,
    int? currentUserId,
    int currentThreadPage,
    int currentReplyPage,
    bool hasMoreThreads,
    bool hasMoreReplies,
    String? errorMessage,
  });

  @override
  $DiscussionThreadCopyWith<$Res>? get selectedThread;
}

/// @nodoc
class __$$DiscussionStateImplCopyWithImpl<$Res>
    extends _$DiscussionStateCopyWithImpl<$Res, _$DiscussionStateImpl>
    implements _$$DiscussionStateImplCopyWith<$Res> {
  __$$DiscussionStateImplCopyWithImpl(
    _$DiscussionStateImpl _value,
    $Res Function(_$DiscussionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? threads = null,
    Object? selectedThread = freezed,
    Object? replies = null,
    Object? isPaginatingThreads = null,
    Object? isPaginatingReplies = null,
    Object? isSubmitting = null,
    Object? canModerate = null,
    Object? currentCourseId = freezed,
    Object? currentUserId = freezed,
    Object? currentThreadPage = null,
    Object? currentReplyPage = null,
    Object? hasMoreThreads = null,
    Object? hasMoreReplies = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$DiscussionStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DiscussionStatus,
        threads: null == threads
            ? _value._threads
            : threads // ignore: cast_nullable_to_non_nullable
                  as List<DiscussionThread>,
        selectedThread: freezed == selectedThread
            ? _value.selectedThread
            : selectedThread // ignore: cast_nullable_to_non_nullable
                  as DiscussionThread?,
        replies: null == replies
            ? _value._replies
            : replies // ignore: cast_nullable_to_non_nullable
                  as List<DiscussionReply>,
        isPaginatingThreads: null == isPaginatingThreads
            ? _value.isPaginatingThreads
            : isPaginatingThreads // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPaginatingReplies: null == isPaginatingReplies
            ? _value.isPaginatingReplies
            : isPaginatingReplies // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        canModerate: null == canModerate
            ? _value.canModerate
            : canModerate // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentCourseId: freezed == currentCourseId
            ? _value.currentCourseId
            : currentCourseId // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentUserId: freezed == currentUserId
            ? _value.currentUserId
            : currentUserId // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentThreadPage: null == currentThreadPage
            ? _value.currentThreadPage
            : currentThreadPage // ignore: cast_nullable_to_non_nullable
                  as int,
        currentReplyPage: null == currentReplyPage
            ? _value.currentReplyPage
            : currentReplyPage // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMoreThreads: null == hasMoreThreads
            ? _value.hasMoreThreads
            : hasMoreThreads // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasMoreReplies: null == hasMoreReplies
            ? _value.hasMoreReplies
            : hasMoreReplies // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DiscussionStateImpl implements _DiscussionState {
  const _$DiscussionStateImpl({
    this.status = DiscussionStatus.initial,
    final List<DiscussionThread> threads = const <DiscussionThread>[],
    this.selectedThread,
    final List<DiscussionReply> replies = const <DiscussionReply>[],
    this.isPaginatingThreads = false,
    this.isPaginatingReplies = false,
    this.isSubmitting = false,
    this.canModerate = false,
    this.currentCourseId,
    this.currentUserId,
    this.currentThreadPage = 1,
    this.currentReplyPage = 1,
    this.hasMoreThreads = true,
    this.hasMoreReplies = true,
    this.errorMessage,
  }) : _threads = threads,
       _replies = replies;

  @override
  @JsonKey()
  final DiscussionStatus status;
  final List<DiscussionThread> _threads;
  @override
  @JsonKey()
  List<DiscussionThread> get threads {
    if (_threads is EqualUnmodifiableListView) return _threads;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_threads);
  }

  @override
  final DiscussionThread? selectedThread;
  final List<DiscussionReply> _replies;
  @override
  @JsonKey()
  List<DiscussionReply> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  @JsonKey()
  final bool isPaginatingThreads;
  @override
  @JsonKey()
  final bool isPaginatingReplies;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool canModerate;
  @override
  final int? currentCourseId;
  @override
  final int? currentUserId;
  @override
  @JsonKey()
  final int currentThreadPage;
  @override
  @JsonKey()
  final int currentReplyPage;
  @override
  @JsonKey()
  final bool hasMoreThreads;
  @override
  @JsonKey()
  final bool hasMoreReplies;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'DiscussionState(status: $status, threads: $threads, selectedThread: $selectedThread, replies: $replies, isPaginatingThreads: $isPaginatingThreads, isPaginatingReplies: $isPaginatingReplies, isSubmitting: $isSubmitting, canModerate: $canModerate, currentCourseId: $currentCourseId, currentUserId: $currentUserId, currentThreadPage: $currentThreadPage, currentReplyPage: $currentReplyPage, hasMoreThreads: $hasMoreThreads, hasMoreReplies: $hasMoreReplies, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._threads, _threads) &&
            (identical(other.selectedThread, selectedThread) ||
                other.selectedThread == selectedThread) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.isPaginatingThreads, isPaginatingThreads) ||
                other.isPaginatingThreads == isPaginatingThreads) &&
            (identical(other.isPaginatingReplies, isPaginatingReplies) ||
                other.isPaginatingReplies == isPaginatingReplies) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.canModerate, canModerate) ||
                other.canModerate == canModerate) &&
            (identical(other.currentCourseId, currentCourseId) ||
                other.currentCourseId == currentCourseId) &&
            (identical(other.currentUserId, currentUserId) ||
                other.currentUserId == currentUserId) &&
            (identical(other.currentThreadPage, currentThreadPage) ||
                other.currentThreadPage == currentThreadPage) &&
            (identical(other.currentReplyPage, currentReplyPage) ||
                other.currentReplyPage == currentReplyPage) &&
            (identical(other.hasMoreThreads, hasMoreThreads) ||
                other.hasMoreThreads == hasMoreThreads) &&
            (identical(other.hasMoreReplies, hasMoreReplies) ||
                other.hasMoreReplies == hasMoreReplies) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    const DeepCollectionEquality().hash(_threads),
    selectedThread,
    const DeepCollectionEquality().hash(_replies),
    isPaginatingThreads,
    isPaginatingReplies,
    isSubmitting,
    canModerate,
    currentCourseId,
    currentUserId,
    currentThreadPage,
    currentReplyPage,
    hasMoreThreads,
    hasMoreReplies,
    errorMessage,
  );

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionStateImplCopyWith<_$DiscussionStateImpl> get copyWith =>
      __$$DiscussionStateImplCopyWithImpl<_$DiscussionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DiscussionState implements DiscussionState {
  const factory _DiscussionState({
    final DiscussionStatus status,
    final List<DiscussionThread> threads,
    final DiscussionThread? selectedThread,
    final List<DiscussionReply> replies,
    final bool isPaginatingThreads,
    final bool isPaginatingReplies,
    final bool isSubmitting,
    final bool canModerate,
    final int? currentCourseId,
    final int? currentUserId,
    final int currentThreadPage,
    final int currentReplyPage,
    final bool hasMoreThreads,
    final bool hasMoreReplies,
    final String? errorMessage,
  }) = _$DiscussionStateImpl;

  @override
  DiscussionStatus get status;
  @override
  List<DiscussionThread> get threads;
  @override
  DiscussionThread? get selectedThread;
  @override
  List<DiscussionReply> get replies;
  @override
  bool get isPaginatingThreads;
  @override
  bool get isPaginatingReplies;
  @override
  bool get isSubmitting;
  @override
  bool get canModerate;
  @override
  int? get currentCourseId;
  @override
  int? get currentUserId;
  @override
  int get currentThreadPage;
  @override
  int get currentReplyPage;
  @override
  bool get hasMoreThreads;
  @override
  bool get hasMoreReplies;
  @override
  String? get errorMessage;

  /// Create a copy of DiscussionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionStateImplCopyWith<_$DiscussionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
