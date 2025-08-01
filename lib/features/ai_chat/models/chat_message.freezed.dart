// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  MessageSender get sender => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String content,
    MessageSender sender,
    DateTime timestamp,
    bool isLoading,
    bool hasError,
    String? errorMessage,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            sender:
                null == sender
                    ? _value.sender
                    : sender // ignore: cast_nullable_to_non_nullable
                        as MessageSender,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            hasError:
                null == hasError
                    ? _value.hasError
                    : hasError // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String content,
    MessageSender sender,
    DateTime timestamp,
    bool isLoading,
    bool hasError,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        sender:
            null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                    as MessageSender,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        hasError:
            null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final MessageSender sender;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, sender: $sender, timestamp: $timestamp, isLoading: $isLoading, hasError: $hasError, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    content,
    sender,
    timestamp,
    isLoading,
    hasError,
    errorMessage,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String content,
    required final MessageSender sender,
    required final DateTime timestamp,
    final bool isLoading,
    final bool hasError,
    final String? errorMessage,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  MessageSender get sender;
  @override
  DateTime get timestamp;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  String? get errorMessage;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) {
  return _ChatSession.fromJson(json);
}

/// @nodoc
mixin _$ChatSession {
  String get id => throw _privateConstructorUsedError;
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this ChatSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatSessionCopyWith<ChatSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSessionCopyWith<$Res> {
  factory $ChatSessionCopyWith(
    ChatSession value,
    $Res Function(ChatSession) then,
  ) = _$ChatSessionCopyWithImpl<$Res, ChatSession>;
  @useResult
  $Res call({
    String id,
    List<ChatMessage> messages,
    DateTime createdAt,
    DateTime? lastMessageAt,
    String title,
  });
}

/// @nodoc
class _$ChatSessionCopyWithImpl<$Res, $Val extends ChatSession>
    implements $ChatSessionCopyWith<$Res> {
  _$ChatSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? createdAt = null,
    Object? lastMessageAt = freezed,
    Object? title = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            messages:
                null == messages
                    ? _value.messages
                    : messages // ignore: cast_nullable_to_non_nullable
                        as List<ChatMessage>,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            lastMessageAt:
                freezed == lastMessageAt
                    ? _value.lastMessageAt
                    : lastMessageAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatSessionImplCopyWith<$Res>
    implements $ChatSessionCopyWith<$Res> {
  factory _$$ChatSessionImplCopyWith(
    _$ChatSessionImpl value,
    $Res Function(_$ChatSessionImpl) then,
  ) = __$$ChatSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<ChatMessage> messages,
    DateTime createdAt,
    DateTime? lastMessageAt,
    String title,
  });
}

/// @nodoc
class __$$ChatSessionImplCopyWithImpl<$Res>
    extends _$ChatSessionCopyWithImpl<$Res, _$ChatSessionImpl>
    implements _$$ChatSessionImplCopyWith<$Res> {
  __$$ChatSessionImplCopyWithImpl(
    _$ChatSessionImpl _value,
    $Res Function(_$ChatSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? createdAt = null,
    Object? lastMessageAt = freezed,
    Object? title = null,
  }) {
    return _then(
      _$ChatSessionImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        messages:
            null == messages
                ? _value._messages
                : messages // ignore: cast_nullable_to_non_nullable
                    as List<ChatMessage>,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        lastMessageAt:
            freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatSessionImpl implements _ChatSession {
  const _$ChatSessionImpl({
    required this.id,
    required final List<ChatMessage> messages,
    required this.createdAt,
    this.lastMessageAt,
    this.title = 'Family Planning Chat',
  }) : _messages = messages;

  factory _$ChatSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSessionImplFromJson(json);

  @override
  final String id;
  final List<ChatMessage> _messages;
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? lastMessageAt;
  @override
  @JsonKey()
  final String title;

  @override
  String toString() {
    return 'ChatSession(id: $id, messages: $messages, createdAt: $createdAt, lastMessageAt: $lastMessageAt, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_messages),
    createdAt,
    lastMessageAt,
    title,
  );

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      __$$ChatSessionImplCopyWithImpl<_$ChatSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSessionImplToJson(this);
  }
}

abstract class _ChatSession implements ChatSession {
  const factory _ChatSession({
    required final String id,
    required final List<ChatMessage> messages,
    required final DateTime createdAt,
    final DateTime? lastMessageAt,
    final String title,
  }) = _$ChatSessionImpl;

  factory _ChatSession.fromJson(Map<String, dynamic> json) =
      _$ChatSessionImpl.fromJson;

  @override
  String get id;
  @override
  List<ChatMessage> get messages;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastMessageAt;
  @override
  String get title;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
