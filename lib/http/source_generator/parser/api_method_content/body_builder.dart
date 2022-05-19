import '../../annotation.dart';
import '../../element_parser.dart';
import 'param_content_builder.dart';

/// Body 的構建類
class BodyBuilder extends ParamContentBuilder<BodyContent> {
  HttpBodyType? bodyType;

  @override
  BodyContent getContent({
    String? key,
    required String fieldName,
    required ApiFieldType fieldType,
  }) {
    return BodyContent.keyValue(key, fieldName, fieldType);
  }

  void setBodyType(HttpBodyType? type) {
    bodyType = type;
  }

  @override
  String build() {
    String text = '';

    // 如果有 bodyType, 則需要設置
    if (bodyType != null) {
      text += "content.bodyType = ${bodyType.toString()};";
    }

    // 遍歷所有需要賦予變數值的常數
    constant.forEach((k, v) {
      text += 'const $k = "$v";';
    });

    // 遍歷必填設置 content
    for (var e in required) {
      text += getContentText(e, true);
    }

    // 遍歷可選設置 content
    for (var e in optional) {
      text += getContentText(e, false);
    }
    return text;
  }

  String getContentText(BodyContent content, bool isRequired) {
    var text = '';

    var key = content.key;
    var field = content.fieldName;
    final isNullable = content.fieldType == ApiFieldType.nullable;

    // 假如是可選, 則需要在開頭結尾加入
    // if ($field != null) {  }
    if (isNullable) {
      text += "if ($field != null) {\n";
    }

    // 如果有 key, 才需要加入(raw 沒有 key)
    var keyText = '';
    if (key != null) {
      keyText = "key: \"$key\",";
      text += """
          content.addBody(${keyText}value: $field,);
          """;
    } else {
      text += """
      content.setBody(raw: $field.toString());
      """;
    }

    if (isNullable) {
      text += "}";
    }

    return text;
  }
}

class BodyContent {
  String? key;
  String fieldName;
  ApiFieldType fieldType;

  BodyContent.keyValue(this.key, this.fieldName, this.fieldType);

  BodyContent.raw(this.fieldName) : fieldType = ApiFieldType.nonNull;
}
