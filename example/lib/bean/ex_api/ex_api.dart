import 'package:json_annotation/json_annotation.dart';
import 'package:type_translator/type_translator.dart';
part 'ex_api.g.dart';

@JsonSerializable()
class ExApiBean {
  @JsonKey(fromJson: translateInt)
  int code;
  @JsonKey(fromJson: translateString)
  String data;

  ExApiBean({this.code, this.data});
  factory ExApiBean.fromJson(dynamic json) =>
      json != null ? _$ExApiBeanFromJson(json) : null;

  dynamic toJson() => _$ExApiBeanToJson(this);
}
