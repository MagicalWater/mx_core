import '../../annotation.dart';
import '../../element_parser.dart';
import 'param_content_builder.dart';

/// Body 的構建類
class BodyBuilder extends ParamContentBuilder<BodyContent> {
  late HttpBodyType bodyType;

  @override
  BodyContent getContent({
    String? key,
    required String fieldName,
    required ApiFieldType fieldType,
  }) {
    return BodyContent.keyValue(key, fieldName, fieldType);
  }

  void setBodyType(HttpBodyType type) {
    this.bodyType = type;
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

  String getContentText(BodyContent content, bool isRequired) {
    var text = '';

    var key = content.key;
    var field = content.fieldName;

    // 假如是可選, 則需要在開頭結尾加入
    // if ($field != null) {  }
    if (!isRequired) {
      text += "if ($field != null) {\n";
    }

    // 如果有 key, 才需要加入(raw 沒有 key)
    var keyText = '';
    if (key != null) {
      keyText = "key: \"$key\",";
      switch (content.fieldType) {
        case ApiFieldType.string:
          text += """
          content.addBody(${keyText}value: \"\$$field\",);
          """;
          break;
        case ApiFieldType.file:
          text += """
          content.addBody(${keyText}filename: \"\${$field.filename}\", filepath: \"\${$field.filepath}\",);
          """;
          break;
        case ApiFieldType.listString:
//          text += """
//          $field.forEach((e) => content.addBody(${keyText}value: e,));
//          """;
          text += """
          content.addBody(${keyText}value: $field,);
          """;
          break;
        case ApiFieldType.listFileInfo:
          // body 目前不支持添加陣列檔案
//          text += """
//          $field.forEach((e) => content.addBody(${keyText}filename: \"\${e.filename}\", filepath: \"\${e.filepath}\",));
//          """;
//          text += """
//          content.addBody(${keyText}filename: \"\${$field.filename}\", filepath: \"\${$field.filepath}\",);
//          """;
          break;
      }
    } else {
      text += """
      content.setBody(raw: \"\$$field\");
      """;
    }

    if (!isRequired) {
      text += "}";
    }

    return text;
  }
}

class BodyContent {
  String? key;
  String fieldName;

  // String filename;
  // String filepath;

  ApiFieldType fieldType;

  BodyContent.keyValue(this.key, this.fieldName, this.fieldType);

  BodyContent.raw(this.fieldName) : this.fieldType = ApiFieldType.string;
}
