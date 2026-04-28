// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      person1: json['person1'] as String? ?? 'Jonathan',
      person2: json['person2'] as String? ?? 'Louise',
      accentHex: json['accentHex'] as String? ?? '#c07b39',
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'person1': instance.person1,
      'person2': instance.person2,
      'accentHex': instance.accentHex,
    };
