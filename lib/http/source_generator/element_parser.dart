import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

/// api 的 method 類型列表
final methodList = [Get, Post, Put, Delete, Download];

/// api 的參數類型列表
final paramList = [Param, Header, Path, Body];

/// api 的 method 類型
enum ApiMethodType { get, post, delete, put, download }

/// Api 的參數類型
enum ApiParamType { queryParam, header, path, body }

/// Api 變數的類型
enum ApiFieldType { string, file, listString, listFileInfo }

/// 傳入 Method 的 ConstantReader (annotation)
/// 從將 meta 取得 Api 的 Method
ApiMethodType toApiMethod(ConstantReader annotation) {
  if (annotation.instanceOf(TypeChecker.fromRuntime(Get))) {
    return ApiMethodType.get;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Post))) {
    return ApiMethodType.post;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Delete))) {
    return ApiMethodType.delete;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Put))) {
    return ApiMethodType.put;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Download))) {
    return ApiMethodType.download;
  }
  return null;
}

/// 傳入 Param 的 ConstantReader (annotation)
/// 從 meta 取得 Api 的參數類型分類
ApiParamType toApiParam(ConstantReader annotation) {
  if (annotation.instanceOf(TypeChecker.fromRuntime(Param))) {
    return ApiParamType.queryParam;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Header))) {
    return ApiParamType.header;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Path))) {
    return ApiParamType.path;
  } else if (annotation.instanceOf(TypeChecker.fromRuntime(Body))) {
    return ApiParamType.body;
  }
  return null;
}

/// 傳入 [ParamElement]
/// 返回這個參數的 field type, 預設是 string
ApiFieldType getFieldType(ParameterElement element) {
  var name = element.type.name;
//  print("打印類型名稱 ${element.type.runtimeType}, ${element.type}, $name");
  if (name == 'FileInfo') {
    return ApiFieldType.file;
  } else if (name == 'List') {
    if (element.type.toString() == "List<FileInfo>") {
      return ApiFieldType.listFileInfo;
    }
    return ApiFieldType.listString;
  } else {
    return ApiFieldType.string;
  }
}

/// 傳入 [MethodElement], 取得 Method 的 meta data
/// 這邊取得的 annotation 只搜索 [methodList] 內的類型
ConstantReader getApiMethodAnnotation(MethodElement element) {
  return getAnnotation(element, methodList);
}

/// 傳入 [ParameterElement], 取得 Method 的 meta data
ConstantReader getParamAnnotation(ParameterElement element) {
  return getAnnotation(element, paramList);
}

/// 傳入 element 以及 尋找的類型列表
/// 返回 對應的 meta data
ConstantReader getAnnotation(Element element, List<Type> findList) {
  for (final type in findList) {
    // 初始化 TypeChecker, 將要搜索的 annotation 類型包進去
    final checker = TypeChecker.fromRuntime(type);

    // 使用 TypeChecker 在 MethodElement 裡面搜索對應 type 的物件
    final annotation = checker.firstAnnotationOf(
      element,
      throwOnUnresolved: false,
    );

    // 假如有搜索到的話, 直接返回, 並且包成 ConstantReader方便讀取
    if (annotation != null) return ConstantReader(annotation);
  }
  return null;
}
