// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionModelImpl _$$ConnectionModelImplFromJson(
  Map<String, dynamic> json,
) => _$ConnectionModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  host: json['host'] as String,
  port: (json['port'] as num?)?.toInt() ?? 22,
  username: json['username'] as String,
  password: json['password'] as String?,
  privateKeyPath: json['privateKeyPath'] as String?,
  passphrase: json['passphrase'] as String?,
  useKeyAuth: json['useKeyAuth'] as bool? ?? false,
  lastConnected: json['lastConnected'] == null
      ? null
      : DateTime.parse(json['lastConnected'] as String),
  group: json['group'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$ConnectionModelImplToJson(
  _$ConnectionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'host': instance.host,
  'port': instance.port,
  'username': instance.username,
  'password': instance.password,
  'privateKeyPath': instance.privateKeyPath,
  'passphrase': instance.passphrase,
  'useKeyAuth': instance.useKeyAuth,
  'lastConnected': instance.lastConnected?.toIso8601String(),
  'group': instance.group,
  'tags': instance.tags,
};
