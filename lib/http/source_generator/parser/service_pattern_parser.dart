import 'package:analyzer/dart/element/element.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart' as code_builder;

import '../element_parser.dart';
import 'code_generator.dart';
import 'parser.dart';

/// 依照 client_mixin 所產出的方法進行調用的模板
class ServicePatternClassParser extends ApiParser {
  late CodeGenerator clientMixinClassCoder;

  void setClientMixinClassCoder(CodeGenerator generator) {
    clientMixinClassCoder = generator;
  }

  @override
  code_builder.Class generateApiClass({
    required String interfaceName,
    required String className,
    required List<code_builder.Method> methods,
  }) {
    // class 要放入一個變數
    // 變數類型是 api_class_parser 的 class 名稱
    return code_builder.Class((c) {
      c
        ..abstract = true
        ..name = className
        ..methods.addAll(methods)
        ..fields = ListBuilder([
          code_builder.Field((b) {
            b
              ..type = code_builder.refer(clientMixinClassCoder.codeClass!.name)
              ..name = _getClientMixinInstanceName()
              ..late = true;
          }),
        ]);
    });
  }

  /// mixin 會默認生成一個參數
  /// 參數即是 api_class_parser 所生成的類
  String _getClientMixinInstanceName() {
    return clientMixinClassCoder.codeClass!.name.substring(0, 1).toLowerCase() +
        clientMixinClassCoder.codeClass!.name.substring(1);
  }

  @override
  List<code_builder.Method> generateApiMethods(ClassElement element) {
    return element.methods.map((e) => _generateApiMethods(e)).toList();
  }

  /// 產出實作api methods
  code_builder.Method _generateApiMethods(MethodElement element) {
    // 首先取得 meta data
    var methodAnnotation = getApiMethodAnnotation(element);

    var method = toApiMethod(methodAnnotation);

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

    // 當 apiMethod 是 download 時
    // 加入一個可選參數 [ProgressCallback onReceiveProgress] 可用來監聽下載進度
    if (method == ApiMethodType.download) {
      optionalParams.add(code_builder.Parameter((p) {
        p
          ..type = code_builder.refer('ProgressCallback')
          ..name = 'onReceiveProgress'
          ..named = true;
      }));
    }

    return code_builder.Method((b) {
      b
        ..name = element.name
        ..requiredParameters.addAll(requiredParams)
        ..optionalParameters.addAll(optionalParams)
        ..body = _getMethodContent(element.name, element.parameters, method)
        ..returns = code_builder.refer(
          'Future<ServerResponse>',
          'package:mx_core/mx_core.dart',
        );
    });
  }

  /// 將參數轉換為 codeBuilder 添加方法參數的型態
  List<code_builder.Parameter> _convertToCodeBuilderParam(
      List<ParameterElement> element) {
    return element.map((e) {
      return code_builder.Parameter((p) {
        List<String> paramAnnotation = [];
        if (e.metadata.any((m) => m.isRequired)) {
          // 如果此參數是必選, 則需要加入 required 的 annotation
          paramAnnotation.add('required');
        }

        // 將 annotation 轉換為 codeExpression
        List<code_builder.CodeExpression> paramAnnotationCode = paramAnnotation
            .map((f) => code_builder.CodeExpression(code_builder.Code(f)))
            .toList();

        p
          ..annotations.addAll(paramAnnotationCode)
          ..type = code_builder.refer('${e.type.getDisplayString(withNullability: false)}?')
          ..name = e.name
          ..named = e.isNamed
          ..defaultTo = e.defaultValueCode == null
              ? null
              : code_builder.Code(e.defaultValueCode!);
      });
    }).toList();
  }

  @override
  String getClassSuffixName() {
    return "ServicePattern";
  }

  /// 自動編寫 method 內容
  code_builder.Code _getMethodContent(
    String methodName,
    List<ParameterElement> param,
    ApiMethodType method,
  ) {
    var text = "return ${_getClientMixinInstanceName()}.$methodName(";

    for (var p in param) {
      if (p.isOptionalNamed) {
        text += "${p.name}: ${p.name},";
      } else {
        text += "${p.name},";
      }
    }

    if (method == ApiMethodType.download) {
      text += ").connect(onReceiveProgress: onReceiveProgress);";
    } else {
      text += ").connect();";
    }
    return code_builder.Code(text);
  }
}
