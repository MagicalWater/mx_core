import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart' as codeBuilder;

import 'code_generator.dart';
import 'parser.dart';

/// 產出 api 類
class ClientMixinClassParser extends ApiParser {
  late CodeGenerator apiClassCoder;

  void setApiClassCoder(CodeGenerator generator) {
    this.apiClassCoder = generator;
  }

  @override
  codeBuilder.Class generateApiClass({
    required String interfaceName,
    required String className,
    required List<codeBuilder.Method> methods,
  }) {
    // class 要放入一個變數
    // 變數類型是 api_class_parser 的 class 名稱
    return codeBuilder.Class((c) {
      c
        ..abstract = true
        ..name = className
        ..methods.addAll(methods)
        ..fields = ListBuilder([
          codeBuilder.Field((b) {
            b
              ..type = codeBuilder.refer(apiClassCoder.codeClass!.name)
              ..name = _getApiInstanceName()
              ..late = true;
          }),
        ])
        ..implements = ListBuilder([codeBuilder.refer(interfaceName)]);
    });
  }

  /// mixin 會默認生成一個參數
  /// 參數即是 api_class_parser 所生成的類
  String _getApiInstanceName() {
    return apiClassCoder.codeClass!.name.substring(0, 1).toLowerCase() +
        apiClassCoder.codeClass!.name.substring(1);
  }

  @override
  List<codeBuilder.Method> generateApiMethods(ClassElement element) {
    return element.methods.map((e) => _generateApiMethods(e)).toList();
  }

  /// 產出實作api methods
  codeBuilder.Method _generateApiMethods(MethodElement element) {
    // 取得 method 裡面必選的參數
    var requiredParam = element.parameters
        .where((e) => e.isRequiredPositional || e.isRequiredNamed)
        .toList();

    // 取得 method 裡面可選的參數
    var optionalParam = element.parameters.where((e) => e.isOptional).toList();

    // 將必要的參數轉為生成code的類
    var requiredParams = _convertToCodeBuilderParam(requiredParam);

    // 將必要的參數轉為生成code的類
    var optionalParams = _convertToCodeBuilderParam(optionalParam);

    return codeBuilder.Method((b) {
      b
        ..name = element.name
        ..requiredParameters.addAll(requiredParams)
        ..optionalParameters.addAll(optionalParams)
        ..body = _getMethodContent(element.name, element.parameters)
        ..returns =
            codeBuilder.refer('HttpContent', 'package:mx_core/mx_core.dart')
        ..annotations = ListBuilder([
          codeBuilder.CodeExpression(codeBuilder.Code('override')),
        ]);
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

        p
          ..annotations.addAll(paramAnnotationCode)
          ..type = codeBuilder
              .refer('${e.type.getDisplayString(withNullability: false)}?')
          ..name = e.name
          ..named = e.isNamed
          ..defaultTo = e.defaultValueCode == null
              ? null
              : codeBuilder.Code(e.defaultValueCode!);
      });
    }).toList();
  }

  @override
  String getClassSuffixName() {
    return "ClientMixin";
  }

  /// 自動編寫 method 內容
  codeBuilder.Code _getMethodContent(
    String methodName,
    List<ParameterElement> param,
  ) {
    var text = "return ${_getApiInstanceName()}.$methodName(";

    param.forEach((p) {
      if (p.isOptionalNamed) {
        text += "${p.name}: ${p.name},";
      } else {
        text += "${p.name},";
      }
    });

    text += ");";
    return codeBuilder.Code(text);
  }
}
