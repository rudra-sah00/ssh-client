import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @Default('system') String themeMode,
    @Default(14.0) double terminalFontSize,
    @Default(true) bool keepAlive,
    @Default(30) int keepAliveInterval,
    @Default(30) int connectionTimeout,
    @Default(0) int maxSessionMinutes, // 0 = forever
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
