import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';
import 'parser/api_class_parser.dart';
import 'parser/client_mixin_class_parser.dart';
import 'parser/service_pattern_parser.dart';

class ApiGenerator extends GeneratorForAnnotation<Api> {
  /// 產生 api class 的實作類
  ApiClassParser apiClassParser = ApiClassParser();

  /// 產生 mixin class 的實作類
  ClientMixinClassParser clientMixinParser = ClientMixinClassParser();

  /// 產生 service class 的模板類
  ServicePatternClassParser servicePatternParser = ServicePatternClassParser();

  /// 已經產生過的檔案, 不需要在 import
  List<String> _importReady = [];

  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // 來源檔案的完整路徑
    final sourceFullName = element.source!.fullName;

    // 來源檔案檔名
    final sourceShortName = element.source!.shortName;

    // api 實作類解析
    apiClassParser.parse(element);

    // 將 api 解析的結果送入 client Mixin 方便往下解析
    clientMixinParser.setApiClassCoder(apiClassParser.codeGenerator);

    // client mixin 開始解析
    clientMixinParser.parse(element);

    // 將 client mixin 解析結果送入 service pattern 往下解析
    servicePatternParser
        .setClientMixinClassCoder(clientMixinParser.codeGenerator);

    // service 開始解析生成
    servicePatternParser.parse(element);

    var apiText = apiClassParser.getFormatText();

    var clientText = clientMixinParser.getFormatText();
    var serviceText = servicePatternParser.getFormatText();

    // 最後的檔案內容
    var finalText = """
    $apiText
    $clientText
    $serviceText
    """;

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
