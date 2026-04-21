// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConnectionModel _$ConnectionModelFromJson(Map<String, dynamic> json) {
  return _ConnectionModel.fromJson(json);
}

/// @nodoc
mixin _$ConnectionModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get host => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String? get privateKeyPath => throw _privateConstructorUsedError;
  String? get passphrase => throw _privateConstructorUsedError;
  bool get useKeyAuth => throw _privateConstructorUsedError;
  DateTime? get lastConnected => throw _privateConstructorUsedError;
  String get group => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this ConnectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionModelCopyWith<ConnectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionModelCopyWith<$Res> {
  factory $ConnectionModelCopyWith(
    ConnectionModel value,
    $Res Function(ConnectionModel) then,
  ) = _$ConnectionModelCopyWithImpl<$Res, ConnectionModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String host,
    int port,
    String username,
    String? password,
    String? privateKeyPath,
    String? passphrase,
    bool useKeyAuth,
    DateTime? lastConnected,
    String group,
    List<String> tags,
  });
}

/// @nodoc
class _$ConnectionModelCopyWithImpl<$Res, $Val extends ConnectionModel>
    implements $ConnectionModelCopyWith<$Res> {
  _$ConnectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? host = null,
    Object? port = null,
    Object? username = null,
    Object? password = freezed,
    Object? privateKeyPath = freezed,
    Object? passphrase = freezed,
    Object? useKeyAuth = null,
    Object? lastConnected = freezed,
    Object? group = null,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            host: null == host
                ? _value.host
                : host // ignore: cast_nullable_to_non_nullable
                      as String,
            port: null == port
                ? _value.port
                : port // ignore: cast_nullable_to_non_nullable
                      as int,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            privateKeyPath: freezed == privateKeyPath
                ? _value.privateKeyPath
                : privateKeyPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            passphrase: freezed == passphrase
                ? _value.passphrase
                : passphrase // ignore: cast_nullable_to_non_nullable
                      as String?,
            useKeyAuth: null == useKeyAuth
                ? _value.useKeyAuth
                : useKeyAuth // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastConnected: freezed == lastConnected
                ? _value.lastConnected
                : lastConnected // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionModelImplCopyWith<$Res>
    implements $ConnectionModelCopyWith<$Res> {
  factory _$$ConnectionModelImplCopyWith(
    _$ConnectionModelImpl value,
    $Res Function(_$ConnectionModelImpl) then,
  ) = __$$ConnectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String host,
    int port,
    String username,
    String? password,
    String? privateKeyPath,
    String? passphrase,
    bool useKeyAuth,
    DateTime? lastConnected,
    String group,
    List<String> tags,
  });
}

/// @nodoc
class __$$ConnectionModelImplCopyWithImpl<$Res>
    extends _$ConnectionModelCopyWithImpl<$Res, _$ConnectionModelImpl>
    implements _$$ConnectionModelImplCopyWith<$Res> {
  __$$ConnectionModelImplCopyWithImpl(
    _$ConnectionModelImpl _value,
    $Res Function(_$ConnectionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? host = null,
    Object? port = null,
    Object? username = null,
    Object? password = freezed,
    Object? privateKeyPath = freezed,
    Object? passphrase = freezed,
    Object? useKeyAuth = null,
    Object? lastConnected = freezed,
    Object? group = null,
    Object? tags = null,
  }) {
    return _then(
      _$ConnectionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        host: null == host
            ? _value.host
            : host // ignore: cast_nullable_to_non_nullable
                  as String,
        port: null == port
            ? _value.port
            : port // ignore: cast_nullable_to_non_nullable
                  as int,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        privateKeyPath: freezed == privateKeyPath
            ? _value.privateKeyPath
            : privateKeyPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        passphrase: freezed == passphrase
            ? _value.passphrase
            : passphrase // ignore: cast_nullable_to_non_nullable
                  as String?,
        useKeyAuth: null == useKeyAuth
            ? _value.useKeyAuth
            : useKeyAuth // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastConnected: freezed == lastConnected
            ? _value.lastConnected
            : lastConnected // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionModelImpl implements _ConnectionModel {
  const _$ConnectionModelImpl({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.password,
    this.privateKeyPath,
    this.passphrase,
    this.useKeyAuth = false,
    this.lastConnected,
    this.group = '',
    final List<String> tags = const [],
  }) : _tags = tags;

  factory _$ConnectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String host;
  @override
  @JsonKey()
  final int port;
  @override
  final String username;
  @override
  final String? password;
  @override
  final String? privateKeyPath;
  @override
  final String? passphrase;
  @override
  @JsonKey()
  final bool useKeyAuth;
  @override
  final DateTime? lastConnected;
  @override
  @JsonKey()
  final String group;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'ConnectionModel(id: $id, name: $name, host: $host, port: $port, username: $username, password: $password, privateKeyPath: $privateKeyPath, passphrase: $passphrase, useKeyAuth: $useKeyAuth, lastConnected: $lastConnected, group: $group, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.privateKeyPath, privateKeyPath) ||
                other.privateKeyPath == privateKeyPath) &&
            (identical(other.passphrase, passphrase) ||
                other.passphrase == passphrase) &&
            (identical(other.useKeyAuth, useKeyAuth) ||
                other.useKeyAuth == useKeyAuth) &&
            (identical(other.lastConnected, lastConnected) ||
                other.lastConnected == lastConnected) &&
            (identical(other.group, group) || other.group == group) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    host,
    port,
    username,
    password,
    privateKeyPath,
    passphrase,
    useKeyAuth,
    lastConnected,
    group,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of ConnectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionModelImplCopyWith<_$ConnectionModelImpl> get copyWith =>
      __$$ConnectionModelImplCopyWithImpl<_$ConnectionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionModelImplToJson(this);
  }
}

abstract class _ConnectionModel implements ConnectionModel {
  const factory _ConnectionModel({
    required final String id,
    required final String name,
    required final String host,
    final int port,
    required final String username,
    final String? password,
    final String? privateKeyPath,
    final String? passphrase,
    final bool useKeyAuth,
    final DateTime? lastConnected,
    final String group,
    final List<String> tags,
  }) = _$ConnectionModelImpl;

  factory _ConnectionModel.fromJson(Map<String, dynamic> json) =
      _$ConnectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get host;
  @override
  int get port;
  @override
  String get username;
  @override
  String? get password;
  @override
  String? get privateKeyPath;
  @override
  String? get passphrase;
  @override
  bool get useKeyAuth;
  @override
  DateTime? get lastConnected;
  @override
  String get group;
  @override
  List<String> get tags;

  /// Create a copy of ConnectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionModelImplCopyWith<_$ConnectionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
