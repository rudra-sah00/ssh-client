// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) {
  return _SettingsModel.fromJson(json);
}

/// @nodoc
mixin _$SettingsModel {
  String get themeMode =>
      throw _privateConstructorUsedError; // 'system', 'light', 'dark'
  double get terminalFontSize => throw _privateConstructorUsedError;
  bool get keepAlive => throw _privateConstructorUsedError;
  int get keepAliveInterval => throw _privateConstructorUsedError;
  int get connectionTimeout => throw _privateConstructorUsedError;

  /// Serializes this SettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsModelCopyWith<SettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsModelCopyWith<$Res> {
  factory $SettingsModelCopyWith(
    SettingsModel value,
    $Res Function(SettingsModel) then,
  ) = _$SettingsModelCopyWithImpl<$Res, SettingsModel>;
  @useResult
  $Res call({
    String themeMode,
    double terminalFontSize,
    bool keepAlive,
    int keepAliveInterval,
    int connectionTimeout,
  });
}

/// @nodoc
class _$SettingsModelCopyWithImpl<$Res, $Val extends SettingsModel>
    implements $SettingsModelCopyWith<$Res> {
  _$SettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? terminalFontSize = null,
    Object? keepAlive = null,
    Object? keepAliveInterval = null,
    Object? connectionTimeout = null,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as String,
            terminalFontSize: null == terminalFontSize
                ? _value.terminalFontSize
                : terminalFontSize // ignore: cast_nullable_to_non_nullable
                      as double,
            keepAlive: null == keepAlive
                ? _value.keepAlive
                : keepAlive // ignore: cast_nullable_to_non_nullable
                      as bool,
            keepAliveInterval: null == keepAliveInterval
                ? _value.keepAliveInterval
                : keepAliveInterval // ignore: cast_nullable_to_non_nullable
                      as int,
            connectionTimeout: null == connectionTimeout
                ? _value.connectionTimeout
                : connectionTimeout // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsModelImplCopyWith<$Res>
    implements $SettingsModelCopyWith<$Res> {
  factory _$$SettingsModelImplCopyWith(
    _$SettingsModelImpl value,
    $Res Function(_$SettingsModelImpl) then,
  ) = __$$SettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String themeMode,
    double terminalFontSize,
    bool keepAlive,
    int keepAliveInterval,
    int connectionTimeout,
  });
}

/// @nodoc
class __$$SettingsModelImplCopyWithImpl<$Res>
    extends _$SettingsModelCopyWithImpl<$Res, _$SettingsModelImpl>
    implements _$$SettingsModelImplCopyWith<$Res> {
  __$$SettingsModelImplCopyWithImpl(
    _$SettingsModelImpl _value,
    $Res Function(_$SettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? terminalFontSize = null,
    Object? keepAlive = null,
    Object? keepAliveInterval = null,
    Object? connectionTimeout = null,
  }) {
    return _then(
      _$SettingsModelImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as String,
        terminalFontSize: null == terminalFontSize
            ? _value.terminalFontSize
            : terminalFontSize // ignore: cast_nullable_to_non_nullable
                  as double,
        keepAlive: null == keepAlive
            ? _value.keepAlive
            : keepAlive // ignore: cast_nullable_to_non_nullable
                  as bool,
        keepAliveInterval: null == keepAliveInterval
            ? _value.keepAliveInterval
            : keepAliveInterval // ignore: cast_nullable_to_non_nullable
                  as int,
        connectionTimeout: null == connectionTimeout
            ? _value.connectionTimeout
            : connectionTimeout // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SettingsModelImpl implements _SettingsModel {
  const _$SettingsModelImpl({
    this.themeMode = 'system',
    this.terminalFontSize = 14.0,
    this.keepAlive = true,
    this.keepAliveInterval = 30,
    this.connectionTimeout = 30,
  });

  factory _$SettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SettingsModelImplFromJson(json);

  @override
  @JsonKey()
  final String themeMode;
  // 'system', 'light', 'dark'
  @override
  @JsonKey()
  final double terminalFontSize;
  @override
  @JsonKey()
  final bool keepAlive;
  @override
  @JsonKey()
  final int keepAliveInterval;
  @override
  @JsonKey()
  final int connectionTimeout;

  @override
  String toString() {
    return 'SettingsModel(themeMode: $themeMode, terminalFontSize: $terminalFontSize, keepAlive: $keepAlive, keepAliveInterval: $keepAliveInterval, connectionTimeout: $connectionTimeout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsModelImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.terminalFontSize, terminalFontSize) ||
                other.terminalFontSize == terminalFontSize) &&
            (identical(other.keepAlive, keepAlive) ||
                other.keepAlive == keepAlive) &&
            (identical(other.keepAliveInterval, keepAliveInterval) ||
                other.keepAliveInterval == keepAliveInterval) &&
            (identical(other.connectionTimeout, connectionTimeout) ||
                other.connectionTimeout == connectionTimeout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    terminalFontSize,
    keepAlive,
    keepAliveInterval,
    connectionTimeout,
  );

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsModelImplCopyWith<_$SettingsModelImpl> get copyWith =>
      __$$SettingsModelImplCopyWithImpl<_$SettingsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SettingsModelImplToJson(this);
  }
}

abstract class _SettingsModel implements SettingsModel {
  const factory _SettingsModel({
    final String themeMode,
    final double terminalFontSize,
    final bool keepAlive,
    final int keepAliveInterval,
    final int connectionTimeout,
  }) = _$SettingsModelImpl;

  factory _SettingsModel.fromJson(Map<String, dynamic> json) =
      _$SettingsModelImpl.fromJson;

  @override
  String get themeMode; // 'system', 'light', 'dark'
  @override
  double get terminalFontSize;
  @override
  bool get keepAlive;
  @override
  int get keepAliveInterval;
  @override
  int get connectionTimeout;

  /// Create a copy of SettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsModelImplCopyWith<_$SettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
