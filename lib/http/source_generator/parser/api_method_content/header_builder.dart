import '../../element_parser.dart';
import 'param_content_builder.dart';

/// Header 的構建類
class HeaderBuilder extends ParamContentBuilder<HeaderContent> {
  @override
  HeaderContent getContent({
    String? key,
    required String fieldName,
    required ApiFieldType fieldType,
  }) {
    // header的key必定要有key值
    return HeaderContent.keyValue(key!, fieldName, fieldType);
  }

  @override
  String build() {
    String text = '';

    // 遍歷所有需要賦予變數值的常數
    constant.forEach((k, v) {
      text += 'var $k = \"$v\";';
    });

    // 遍歷必填設置 content
    required.forEach((e) {
      text += getContentText(e, true);
    });

    // 遍歷可選設置 content
    optional.forEach((e) {
      text += getContentText(e, false);
    });

    return text;
  }

  String getContentText(HeaderContent content, bool isRequired) {
    var text = '';

    var key = content.key;
    var field = content.fieldName;

    // 假如是可選, 則需要在開頭結尾加入
    // if ($field != null) {  }
    if (!isRequired) {
      text += "if ($field != null) {\n";
    }

    switch (content.fieldType) {
      case ApiFieldType.string:
        text += """
          content.addHeader(\"$key\", value: \"\$$field\");
          """;
        break;
      case ApiFieldType.listString:
//        text += """
//          $field.forEach((e) => content.addHeader(\"$key\", value: e));
//          """;
        text += """
          content.addHeader(\"$key\", value: $field);
          """;
        break;
      case ApiFieldType.file:
      // header 不能添加檔案, 所以不處理, 也不會進到此處
      case ApiFieldType.listFileInfo:
        // header 不能添加檔案, 所以不處理, 也不會進到此處
        break;
    }

    if (!isRequired) {
      text += "}";
    }

    return text;
  }
}

class HeaderContent {
  String key;
  String fieldName;
  ApiFieldType fieldType;

  HeaderContent.keyValue(this.key, this.fieldName, this.fieldType);
}
