import '../../annotation.dart';
import '../../element_parser.dart';
import 'body_builder.dart';
import 'builder.dart';
import 'header_builder.dart';
import 'init_builder.dart';
import 'query_param_builder.dart';

/// http content 的內容構建類
class HttpContentBuilder implements Builder {
  InitBuilder init = InitBuilder();
  BodyBuilder body = BodyBuilder();
  HeaderBuilder header = HeaderBuilder();
  QueryParamBuilder queryParam = QueryParamBuilder();

  /// 目前暫存變數名稱的 index
  int _currentVariableIndex = 0;

  /// 設定初始化屬性
  void settingInit({
    String? path,
    ApiMethodType? method,
    String? contentType,
    String? scheme,
    String? host,
    int? port,
  }) {
    init.setting(
      path: path,
      method: method,
      contentType: contentType,
      scheme: scheme,
      host: host,
      port: port,
    );
  }

  /// 設置 bodyType
  void setBodyType(HttpBodyType type) {
    body.setBodyType(type);
  }

  /// 添加 body
  void addBody({
    bool? required,
    String? key,
    String? fieldName,
    String? constantValue,
    required ApiFieldType fieldType,
  }) {
    if (fieldName != null) {
      if (required!) {
        body.addRequired(key: key, fieldName: fieldName, fieldType: fieldType);
      } else {
        body.addOptional(key: key, fieldName: fieldName, fieldType: fieldType);
      }
    } else if (constantValue != null) {
      var name = generateVariableName();
      body.addConstant(
        key: key,
        value: constantValue,
        putName: name,
        fieldType: fieldType,
      );
    }
  }

  /// 添加 header
  void addHeader({
    bool? required,
    required String key,
    String? fieldName,
    String? constantValue,
    required ApiFieldType fieldType,
  }) {
    if (fieldName != null) {
      if (required!) {
        header.addRequired(
            key: key, fieldName: fieldName, fieldType: fieldType);
      } else {
        header.addOptional(
            key: key, fieldName: fieldName, fieldType: fieldType);
      }
    } else if (constantValue != null) {
      header.addConstant(
        key: key,
        value: constantValue,
        putName: generateVariableName(),
        fieldType: fieldType,
      );
    }
  }

  /// 添加 query param
  void addQueryParam({
    bool? required,
    required String key,
    String? fieldName,
    String? constantValue,
    required ApiFieldType fieldType,
  }) {
    if (fieldName != null) {
      if (required!) {
        queryParam.addRequired(
            key: key, fieldName: fieldName, fieldType: fieldType);
      } else {
        queryParam.addOptional(
            key: key, fieldName: fieldName, fieldType: fieldType);
      }
    } else if (constantValue != null) {
      queryParam.addConstant(
        key: key,
        value: constantValue,
        putName: generateVariableName(),
        fieldType: fieldType,
      );
    }
  }

  /// 添加常數時要給定一個變數名稱
  /// 由此處生成一個變數名稱
  String generateVariableName() {
    _currentVariableIndex += 1;
    return "_temp$_currentVariableIndex";
  }

  @override
  String build() {
    var initText = init.build();
    var bodyText = body.build();
    var headerText = header.build();
    var queryParamText = queryParam.build();
    return """
    $initText
    $bodyText
    $headerText
    $queryParamText
    return content;
    """;
  }
}
