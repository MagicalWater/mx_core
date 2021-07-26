import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class CodeGenerator {
  Class? _codeClass;

  Library? _codeLibrary;

  Class? get codeClass => _codeClass;

  void setClass(Class value) {
    _codeClass = value;
  }

  void setLibrary(Library value) {
    _codeLibrary = value;
  }

  /// 取得格式化字串
  String? getFormatText() {
    // 若 DartEmitter 內參數帶入 Allocator
    // 則會自動加入 refer 的 url
    // Allocator.simplePrefixing() => 自動幫 url 使用 as

    if (_codeLibrary != null) {
      final emitter = DartEmitter();
      String classString = "${_codeLibrary!.accept(emitter)}";
      return DartFormatter().format(classString);
    } else if (_codeClass != null) {
      final emitter = DartEmitter();
      String classString = "${_codeClass!.accept(emitter)}";
      return DartFormatter().format(classString);
    }

    return null;
  }
}