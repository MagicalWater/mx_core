import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart' as codeBuilder;

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
  List<codeBuilder.Method> generateApiMethods(ClassElement element) {
    // 取得 ClassElement 底下的所有 method, 開始進行分析以及建立 Method
    return element.methods.map((e) => _generateMethod(e)).toList();
  }

  @override
  codeBuilder.Class generateApiClass({
    String interfaceName,
    String className,
    List<codeBuilder.Method> methods,
  }) {
    return codeBuilder.Class((c) {
      c
        ..abstract = true
        ..name = className
        ..methods.addAll(methods)
        ..extend = codeBuilder.refer(
            "RequestBuilderBase", 'package:mx_core/mx_core.dart')
        ..implements = ListBuilder(
            [codeBuilder.refer(interfaceName, 'package:mx_core/mx_core.dart')]);
    });
  }

  codeBuilder.Method _generateMethod(MethodElement element) {
    // method 內容的構建器
    HttpContentBuilder contentBuilder = HttpContentBuilder();

    // 取得 method 的名稱
    var methodName = element.name;

    // 首先取得 meta data
    var methodAnnotation = getApiMethodAnnotation(element);

    // 取得 method 裡面必選的參數
    var requiredParam = element.parameters
        .where((e) => e.isRequiredPositional || e.isRequiredNamed)
        .toList();

    // 取得 method 裡面可選的參數
    var optionalParam = element.parameters.where((e) => e.isOptional).toList();

    // 取得以及設置初始化參數
    // 取得 meta data 使用的類型
    var method = toApiMethod(methodAnnotation);
    var path = methodAnnotation.peek('path').stringValue;
    var scheme = methodAnnotation.peek('scheme')?.stringValue;
    var host = methodAnnotation.peek('host')?.stringValue;
    var port = methodAnnotation.peek('port')?.intValue;
    var contentType = methodAnnotation
        .peek('contentType')
        ?.objectValue
        ?.getField('_value')
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
    HttpBodyType bodyType;
    var bodyTypePeek = methodAnnotation.peek('bodyType');
    if (bodyTypePeek != null) {
      var dartObj = bodyTypePeek.objectValue;
      // enum 判斷的方式只能透過 getField.split('.') 進行判斷
      if (dartObj.getField(HttpBodyType.formData.toString().split('.').last) !=
          null) {
        // 類型是 formDara
        bodyType = HttpBodyType.formData;
      } else if (dartObj.getField(
              HttpBodyType.formUrlencoded.toString().split('.').last) !=
          null) {
        // 類型是 formUrlencoded
        bodyType = HttpBodyType.formUrlencoded;
      } else if (dartObj
              .getField(HttpBodyType.raw.toString().split('.').last) !=
          null) {
        // 類型為 raw
        bodyType = HttpBodyType.raw;
      }

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
      constantHeader[k.toStringValue()] = v.toStringValue();
    });
    (methodAnnotation.peek('queryParams')?.mapValue ?? {}).forEach((k, v) {
      constantQueryParam[k.toStringValue()] = v.toStringValue();
    });

    var bodyPeek = methodAnnotation.peek('body');
    if (bodyPeek?.isString == true) {
      constantBody = bodyPeek.stringValue;
    } else if (bodyPeek?.isMap == true) {
      constantBody = Map<String, String>();
      (bodyPeek.mapValue ?? {}).forEach((k, v) {
        constantBody[k.toStringValue()] = v.toStringValue();
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
    _addParamToContentBuilder(
      builder: contentBuilder,
      urlPath: path,
      params: requiredParam,
      isRequired: true,
    );
    _addParamToContentBuilder(
      builder: contentBuilder,
      params: optionalParam,
      isRequired: false,
    );

    return codeBuilder.Method((b) {
      b
        ..annotations = ListBuilder([
          codeBuilder.CodeExpression(codeBuilder.Code('override')),
        ])
        ..name = methodName
        ..requiredParameters.addAll(_convertToCodeBuilderParam(requiredParam))
        ..optionalParameters.addAll(_convertToCodeBuilderParam(optionalParam))
        ..body = codeBuilder.Code(contentBuilder.build())
        ..returns =
            codeBuilder.refer('HttpContent', 'package:mx_core/mx_core.dart');
    });
  }

  /// 將參數轉換為 codeBuilder 添加方法參數的型態
  List<codeBuilder.Parameter> _convertToCodeBuilderParam(
      List<ParameterElement> element) {
    return element.map((e) {
      return codeBuilder.Parameter((p) {
        List<String> paramAnnotation = [];
        if (e.metadata.any((m) => m.isRequired)) {
          // 如果此參數是必選, 則需要加入 required 的 annotation
          paramAnnotation.add('required');
        }

        // 將 annotation 轉換為 codeExpression
        List<codeBuilder.CodeExpression> paramAnnotationCode = paramAnnotation
            .map((f) => codeBuilder.CodeExpression(codeBuilder.Code(f)))
            .toList();

        return p
          ..annotations.addAll(paramAnnotationCode)
          ..type = codeBuilder.refer(e.type.displayName)
          ..name = e.name
          ..named = e.isNamed
          ..defaultTo = e.defaultValueCode == null
              ? null
              : codeBuilder.Code(e.defaultValueCode);
      });
    }).toList();
  }

  /// 添加常數參數到 [v]
  void _addConstantQueryParam(
      {HttpContentBuilder builder, Map<String, String> queryParams}) {
    if (queryParams == null) return;
    queryParams.forEach((k, v) {
      builder.addQueryParam(
        key: k,
        constantValue: v,
        fieldType: ApiFieldType.string,
      );
    });
  }

  /// 添加常數header到 [builder]
  void _addConstantHeader(
      {HttpContentBuilder builder, Map<String, String> headers}) {
    if (headers == null) return;
    headers.forEach((k, v) {
      builder.addHeader(
        key: k,
        constantValue: v,
        fieldType: ApiFieldType.string,
      );
    });
  }

  /// 添加常數body到 [builder]
  void _addConstantBody({HttpContentBuilder builder, dynamic body}) {
    if (body == null) return;
    if (body is Map<String, String>) {
      body.forEach((k, v) {
        builder.addBody(
          key: k,
          constantValue: v,
          fieldType: ApiFieldType.string,
        );
      });
    } else if (body is String) {
      builder.addBody(constantValue: body, fieldType: ApiFieldType.string);
    }
  }

  /// 添加參數設定到 [HttpContentBuilder]
  void _addParamToContentBuilder({
    HttpContentBuilder builder,
    String urlPath,
    List<ParameterElement> params,
    bool isRequired,
  }) {
    // 遍歷所有的參數, 依據參數的類型, 加入到對應的 Builder
    params.forEach((e) {
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
          var key = paramAnnotation.peek('name')?.stringValue;
          builder.addQueryParam(
            required: isRequired,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
        case ApiParamType.header:
          var key = paramAnnotation.peek('name')?.stringValue;
          builder.addHeader(
            required: isRequired,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
        case ApiParamType.path:
          // path 不能放在可選
          if (isRequired) {
            var key = paramAnnotation.peek('name').stringValue;
            // 將路徑裡面的 {variable} 做替換
            urlPath = urlPath.replaceAll("{$key}", "\$$fieldName");
            builder.settingInit(path: urlPath);
          }
          break;
        case ApiParamType.body:
          // 取得 key
          var key = paramAnnotation.peek('name')?.stringValue;
          // 添加到body
          builder.addBody(
            required: isRequired,
            key: key,
            fieldName: fieldName,
            fieldType: fieldType,
          );
          break;
      }
    });
  }
}
