import '../../element_parser.dart';
import 'param_content_builder.dart';

/// QueryParam 的構建類
class QueryParamBuilder extends ParamContentBuilder<QueryParamContent> {
  @override
  QueryParamContent getContent({
    String? key,
    required String fieldName,
    required ApiFieldType fieldType,
  }) {
    return QueryParamContent.keyValue(key!, fieldName, fieldType);
  }

  @override
  String build() {
    String text = '';

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

  String getContentText(QueryParamContent content, bool isRequired) {
    var text = '';

    var key = content.key;
    var field = content.fieldName;
    final isNullable = content.fieldType == ApiFieldType.nullable;

    // 假如是可選, 則需要在開頭結尾加入
    // if ($field != null) {  }
    if (isNullable) {
      text += "if ($field != null) {\n";
    }

    text += """
          content.addQueryParam("$key", value: $field);
          """;

    if (isNullable) {
      text += "}";
    }

    return text;
  }
}

class QueryParamContent {
  String key;
  String fieldName;
  ApiFieldType fieldType;

  QueryParamContent.keyValue(this.key, this.fieldName, this.fieldType);
}
