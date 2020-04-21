import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class CodeGenerator {
  /// 最後需要套用到的 code 生成的 method 列表
  List<Method> codeMethodList;

  Class codeClass;

  Library codeLibrary;

  void setMethod(List<Method> value) {
    this.codeMethodList = value;
  }

  void setClass(Class value) {
    codeClass = value;
  }

  void setLibrary(Library value) {
    codeLibrary = value;
  }

  /// 取得格式化字串
  String getFormatText() {
    // 若 DartEmitter 內參數帶入 Allocator
    // 則會自動加入 refer 的 url
    // Allocator.simplePrefixing() => 自動幫 url 使用 as

    if (codeLibrary != null) {
      final emitter = DartEmitter();
      String classString = "${codeLibrary.accept(emitter)}";
      return DartFormatter().format(classString);
    } else if (codeClass != null) {
      final emitter = DartEmitter();
      String classString = "${codeClass.accept(emitter)}";
      return DartFormatter().format(classString);
    }

    return null;
  }
}