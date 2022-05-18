import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';
import 'parser/api_class_parser.dart';

class ApiGenerator extends GeneratorForAnnotation<Api> {
  /// 產生 api class 的實作類
  ApiClassParser apiClassParser = ApiClassParser();

  /// 已經產生過的檔案, 不需要在 import
  final List<String> _importReady = [];

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // 來源檔案的完整路徑
    final sourceFullName = element.source!.fullName;

    // 來源檔案檔名
    final sourceShortName = element.source!.shortName;

    // api 實作類解析
    apiClassParser.parse(element);

    final apiText = apiClassParser.getFormatText();

    // 最後的檔案內容
    var finalText = apiText;

    // 如果尚未添加過 import, 則需要加入
    if (!_importReady.contains(sourceFullName)) {
      _importReady.add(sourceFullName);
      finalText = """
      ${getImportText(sourceShortName)}
      
      $finalText
      """;
    }

    return DartFormatter().format(finalText);
  }

  String getImportText(String sourceFile) {
    return """
    part of '$sourceFile';
    """;
  }
}

Builder apiBuilder(BuilderOptions options) =>
    LibraryBuilder(ApiGenerator(), generatedExtension: '.api.dart');
