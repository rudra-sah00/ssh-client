// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snippet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SnippetModelImpl _$$SnippetModelImplFromJson(Map<String, dynamic> json) =>
    _$SnippetModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      command: json['command'] as String,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$SnippetModelImplToJson(_$SnippetModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'command': instance.command,
      'description': instance.description,
    };
