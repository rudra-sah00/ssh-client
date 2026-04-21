import 'package:freezed_annotation/freezed_annotation.dart';

part 'connection_model.freezed.dart';
part 'connection_model.g.dart';

@freezed
class ConnectionModel with _$ConnectionModel {
  const factory ConnectionModel({
    required String id,
    required String name,
    required String host,
    @Default(22) int port,
    required String username,
    String? password,
    String? privateKeyPath,
    String? passphrase,
    @Default(false) bool useKeyAuth,
    DateTime? lastConnected,
    @Default('') String group,
    @Default([]) List<String> tags,
  }) = _ConnectionModel;

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$ConnectionModelFromJson(json);
}
