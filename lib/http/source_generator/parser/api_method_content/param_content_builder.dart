import '../../element_parser.dart';
import 'builder.dart';

/// 參數添加抽象類
abstract class ParamContentBuilder<T> implements Builder {
  // 必要的 bodyFormData 的部分
  List<T> required = [];

  List<T> optional = [];

  /// 賦予常數暫存值的變數
  Map<String, String> constant = {};

  /// 添加一個常數類型的 body
  /// [BodyContent] 的 value 是帶入變數
  /// 因此若是沒有變數時, 需要由此方法賦予所有的常數一個變數
  void addConstant({String key, String value, String putName, ApiFieldType fieldType}) {
    constant[putName] = value;
    var content =
    getContent(key: key, fieldName: putName, fieldType: fieldType);
    required.add(content);
  }

  /// 添加一個必填的變數類型 body
  void addRequired({String key, String fieldName, ApiFieldType fieldType}) {
    var content =
    getContent(key: key, fieldName: fieldName, fieldType: fieldType);
    required.add(content);
  }

  /// 添加一個可選的變數類型 body
  void addOptional({String key, String fieldName, ApiFieldType fieldType}) {
    var content =
    getContent(key: key, fieldName: fieldName, fieldType: fieldType);
    optional.add(content);
  }

  T getContent({String key, String fieldName, ApiFieldType fieldType});
}