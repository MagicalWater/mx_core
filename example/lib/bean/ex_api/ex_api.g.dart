// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ex_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExApiBean _$ExApiBeanFromJson(Map<String, dynamic> json) {
  return ExApiBean(
    code: translateInt(json['code']),
    data: translateString(json['data']),
  );
}

Map<String, dynamic> _$ExApiBeanToJson(ExApiBean instance) => <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
    };
