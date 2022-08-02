import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart' as code_builder;

import '../annotation.dart';
import '../element_parser.dart';
import 'api_method_content/http_content_builder.dart';
import 'parser.dart';

/// 產出 api 類
class ApiClassParser extends ApiParser {
  @override
  String getClassSuffixName() {
    return "Api";
  }

  /// 產出實作的 api methods
  @override
  List<code_builder.Method> generateApiMethods(ClassElement element) {
    // 取得 ClassElement 底下的所有 method, 開始進行分析以及建立 Method
    return element.methods.map((e) => _generateMethod(e)).toList();
  }

  @override
  code_builder.Class generateApiClass({
    required String interfaceName,
    required String className,
    required List<code_builder.Method> methods,
  }) {
    return code_builder.Class((c) {
      c
        ..abstract = true
        ..name = className
        ..methods.addAll(methods)
        ..extend = code_builder.refer(
            "RequestBuilderBase", 'package:mx_core/mx_core.dart')
        ..implements = ListBuilder([
          code_builder.refer(interfaceName, 'package:mx_core/mx_core.dart')
        ]);
    });
  }

  code_builder.Method _generateMethod(MethodElement element) {
    // method 內容的構建器
    HttpContentBuilder contentBuilder = HttpContentBuilder();

    // 取得 method 的名稱
    var methodName = element.name;

    // 首先取得 meta data
    var methodAnnotation = getApiMethodAnnotation(element);

    // 取得 method 裡面必選的參數(擁有名稱的必選參數不在此處)
    var requiredParam =
        element.parameters.where((e) => e.isRequiredPositional).toList();

    // 取得 method 裡面可選或者擁有名稱的參數
    var optionalParam = element.parameters
        .where((e) => e.isOptional || e.isRequiredNamed)
        .toList();

    // 取得以及設置初始化參數
    // 取得 meta data 使用的類型
    var method = toApiMethod(methodAnnotation);
    var path = methodAnnotation.peek('path')!.stringValue;
    var scheme = methodAnnotation.peek('scheme')?.stringValue;
    var host = methodAnnotation.peek('host')?.stringValue;
    var port = methodAnnotation.peek('port')?.intValue;
    var contentType = methodAnnotation
        .peek('contentType')
        ?.objectValue
        .getField('_value')
        ?.toStringValue();

    contentBuilder.settingInit(
      path: path,
      method: method,
      contentType: contentType,
      scheme: scheme,
      host: host,
      port: port,
    );

    // 解析取得 bodyType
    HttpBodyType? bodyType;
    var bodyTypePeek = methodAnnotation.peek('bodyType');
    if (bodyTypePeek != null) {
      var dartObj = bodyTypePeek.objectValue;
      final name = dartObj.getField('_name')?.toStringValue();
      final formDataString = HttpBodyType.formData.toString().split('.').last;
      final formUrlencodedString =
          HttpBodyType.formUrlencoded.toString().split('.').last;
      final rawStrng = HttpBodyType.raw.toString().split('.').last;
      // enum 判斷的方式只能透過 getField.split('.') 進行判斷
      if (name == formDataString) {
        // 類型是 formDara
        bodyType = HttpBodyType.formData;
      } else if (name == formUrlencodedString) {
        // 類型是 formUrlencoded
        bodyType = HttpBodyType.formUrlencoded;
      } else if (name == rawStrng) {
        // 類型為 raw
        bodyType = HttpBodyType.raw;
      }

      // 實際上可以設置的為enum
      // 因此在經過上方的if else判斷後, bodyType 必定有值

      // 將 bodyType 設置到 builder
      contentBuilder.setBodyType(bodyType);
    }

    // 常數 header
    Map<String, String> constantHeader = {};
    // 常數 queryParam
    Map<String, String> constantQueryParam = {};
    // 常數 body
    dynamic constantBody;

    // 解析常數參數 (header/body/queryparam)
    (methodAnnotation.peek('headers')?.mapValue ?? {}).forEach((k, v) {
      var keyString = k?.toStringValue();
      var valueString = v?.toStringValue();
      if (keyString != null && valueString != null) {
        constantHeader[keyString] = valueString;
      }
    });
    (methodAnnotation.peek('queryParams')?.mapValue ?? {}).forEach((k, v) {
      var keyString = k?.toStringValue();
      var valueString = v?.toStringValue();
      if (keyString != null && valueString != null) {
        constantQueryParam[keyString] = valueString;
      }
    });

    var bodyPeek = methodAnnotation.peek('body');
    if (bodyPeek?.isString == true) {
      constantBody = bodyPeek!.stringValue;
    } else if (bodyPeek?.isMap == true) {
      constantBody = <String, String>{};
      (bodyPeek!.mapValue).forEach((k, v) {
        var keyString = k?.toStringValue();
        var valueString = v?.toStringValue();
        if (keyString != null && valueString != null) {
          constantBody[keyString] = valueString;
        }
      });
    }

    // 添加常數參數
    _addConstantQueryParam(
        builder: contentBuilder, queryParams: constantQueryParam);

    // 添加常數header
    _addConstantHeader(builder: contentBuilder, headers: constantHeader);

    // 添加常數body
    _addConstantBody(builder: contentBuilder, body: constantBody);

    // 添加必選/可選參數到 content Builder
    path = _addParamToContentBuilder(
      builder: contentBuilder,
      urlPath: path,
      params: requiredParam,
      isRequiredRange: true,
    );
    path = _addParamToContentBuilder(
      builder: contentBuilder,
      urlPath: path,
      params: optionalParam,
      isRequiredRange: false,
    );

    return code_builder.Method((b) {
      b
        ..annotations = ListBuilder([
          const code_builder.CodeExpression(code_builder.Code('override')),
        ])
        ..name = methodName
        ..requiredParameters
            .addAll(_convertToCodeBuilderParam(requiredParam, false))
        ..optionalParameters
            .addAll(_convertToCodeBuilderParam(optionalParam, true))
        ..body = code_builder.Code(contentBuilder.build())
        ..returns =
            code_builder.refer('HttpContent', 'package:mx_core/mx_core.dart');
    });
  }

  /// 將參數轉換為 codeBuilder 添加方法參數的型態
  List<code_builder.Parameter> _convertToCodeBuilderParam(
    List<ParameterElement> element,
    bool isOptional,
  ) {
    return element.map((e) {
      return code_builder.Parameter((p) {
        List<String> paramAnnotation = [];
        // if (e.metadata.any((m) => m.isRequired)) {
        //   // 如果此參數是必選, 則需要加入 required 的 annotation
        //   paramAnnotation.add('required');
        // }

        // 將 annotation 轉換為 codeExpression
        List<code_builder.CodeExpression> paramAnnotationCode = paramAnnotation
            .map((f) => code_builder.CodeExpression(code_builder.Code(f)))
            .toList();

        // print('取得類型名稱: ${e.type.getDisplayString(withNullability: true)}');
        p
          ..annotations.addAll(paramAnnotationCode)
          ..type =
              code_builder.refer(e.type.getDisplayString(withNullability: true))
          ..name = e.name
          ..named = e.isNamed
          ..required = isOptional ? e.isRequired : false
          ..defaultTo = e.defaultValueCode == null
              ? null
              : code_builder.Code(e.defaultValueCode!);
      });
    }).toList();
  }

  /// 添加常數參數到 [v]
  void _addConstantQueryParam(
      {required HttpContentBuilder builder, Map<String, String>? queryParams}) {
    if (queryParams == null || queryParams.isEmpty) return;
    queryParams.forEach((k, v) {
      builder.addQueryParam(
        key: k,
        constantValue: v,
        fieldType: ApiFieldType.nonNull,
      );
    });
  }

  /// 添加常數header到 [builder]
  void _addConstantHeader(
      {required HttpContentBuilder builder, Map<String, String>? headers}) {
    if (headers == null || headers.isEmpty) return;
    headers.forEach((k, v) {
      builder.addHeader(
        key: k,
        constantValue: v,
        fieldType: ApiFieldType.nonNull,
      );
    });
  }

  /// 添加常數body到 [builder]
  void _addConstantBody({required HttpContentBuilder builder, dynamic body}) {
    if (body == null) return;
    if (body is Map<String, String>) {
      body.forEach((k, v) {
        builder.addBody(
          key: k,
          constantValue: v,
          fieldType: ApiFieldType.nonNull,
        );
      });
    } else if (body is String) {
      // 是 raw string
      builder.addBody(constantValue: body, fieldType: ApiFieldType.nonNull);
    }
  }

  /// 添加參數設定到 [HttpContentBuilder]
  /// [isRequiredRange] - 是否為必填區塊的參數
  /// 回傳新的urlPath (無論是否有變更都回傳)
  String _addParamToContentBuilder({
    required HttpContentBuilder builder,
    required String urlPath,
    required List<ParameterElement> params,
    required bool isRequiredRange,
  }) {
    String currentPath = urlPath;

    // 遍歷所有的參數, 依據參數的類型, 加入到對應的 Builder
    for (var e in params) {
      // 取得參數的 meta data
      var paramAnnotation = getParamAnnotation(e);

      // 就可以從 meta data 取得參數的類型
      var paramType = toApiParam(paramAnnotation);

      // 變數名稱
      var fieldName = e.name;

      // 變數類型
      var fieldType = getFieldType(e);

      switch (paramType) {
        case ApiParamType.queryParam:
          var key = paramAnnotation.peek('name')!.stringValue;
          builder.addQueryParam(
            required: isRequiredRange,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
        case ApiParamType.header:
          var key = paramAnnotation.peek('name')!.stringValue;
          builder.addHeader(
            required: isRequiredRange,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
        case ApiParamType.path:
          // 將路徑裡面的 {variable} 做替換
          if (fieldType == ApiFieldType.nonNull) {
            var key = paramAnnotation.peek('name')!.stringValue;
            currentPath = currentPath.replaceAll("{$key}", "\$$fieldName");
            builder.settingInit(path: currentPath);
          } else {
            var key = paramAnnotation.peek('name')!.stringValue;
            currentPath = currentPath.replaceAll("{$key}", "\${$fieldName ?? ''}");
            builder.settingInit(path: currentPath);
          }
          break;
        case ApiParamType.body:
          // 取得 key
          var key = paramAnnotation.peek('name')?.stringValue;
          // 添加到body
          builder.addBody(
            required: isRequiredRange,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
      }
    }

    return currentPath;
  }
}
