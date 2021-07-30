import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart' as codeBuilder;
import 'package:meta/meta.dart';

import 'code_generator.dart';

abstract class ApiParser {
  /// 介面名稱
  String? interfaceName;

  /// 生成的 api class 名稱
  String? apiClassName;

  /// 解析完成的 code 生成相關會儲存在此
  CodeGenerator codeGenerator = CodeGenerator();

  void parse(Element element) {
    if (element.kind == ElementKind.CLASS) {
      final classElement = element as ClassElement;

      interfaceName = classElement.name;
      apiClassName = getMainNameByInterface(interfaceName!);
      apiClassName = '${apiClassName!}${getClassSuffixName()}';

      var apiMethod = generateApiMethods(classElement);

      var apiClass = generateApiClass(
        interfaceName: interfaceName!,
        className: apiClassName!,
        methods: apiMethod,
      );

      // 將 method 放入 class
      codeGenerator.setClass(apiClass);

      // 將 class 放入 library
      codeGenerator.setLibrary(
          codeBuilder.Library((b) => b..body.add(codeGenerator.codeClass!)));
    }
  }

  /// 根據 interfaceName 取得要實作的字串名稱
  String getMainNameByInterface(String interfaceName) {
    if (interfaceName.endsWith('Interface')) {
      return interfaceName.substring(
          0, interfaceName.length - 'Interface'.length);
    } else {
      return interfaceName;
    }
  }

  /// 產生的類別尾端名稱
  String getClassSuffixName();

  /// 將解析完的 Library 轉為 格式化字串
  String getFormatText() {
    return codeGenerator.getFormatText()!;
  }

  /// 產出實作的 api methods
  @protected
  List<codeBuilder.Method> generateApiMethods(ClassElement element);

  @protected
  codeBuilder.Class generateApiClass({
    required String interfaceName,
    required String className,
    required List<codeBuilder.Method> methods,
  });
}
