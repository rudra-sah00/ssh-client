// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsModelImpl _$$SettingsModelImplFromJson(Map<String, dynamic> json) =>
    _$SettingsModelImpl(
      terminalFontSize: (json['terminalFontSize'] as num?)?.toDouble() ?? 14.0,
      keepAlive: json['keepAlive'] as bool? ?? true,
      keepAliveInterval: (json['keepAliveInterval'] as num?)?.toInt() ?? 30,
      connectionTimeout: (json['connectionTimeout'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$$SettingsModelImplToJson(_$SettingsModelImpl instance) =>
    <String, dynamic>{
      'terminalFontSize': instance.terminalFontSize,
      'keepAlive': instance.keepAlive,
      'keepAliveInterval': instance.keepAliveInterval,
      'connectionTimeout': instance.connectionTimeout,
    };
