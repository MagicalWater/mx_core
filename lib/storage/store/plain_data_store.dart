part of 'store.dart';

/// 明文的永久化儲存本地設定
/// 使用 [PlainStorage] 進行儲存
/// 對於 List 以及 Map, 暫時只支持 List<基本類型>, Map<String, 基本類型>
/// 基本類型 => int, double, String, bool
class PlainDataStore<T> extends DataStore<T> {
  PlainDataStore({
    @required String key,
    T defaultValue,
  }) : super(key: key, defaultValue: defaultValue);

  @override
  Future<void> write(T value) async {
    this._value = value;
    if (value == null) {
      return delete(deleteLocal: true);
    }
    if (value is int) {
      await SecureStorage.writeInt(key: key, value: value);
    } else if (value is double) {
      await SecureStorage.writeDouble(key: key, value: value);
    } else if (value is bool) {
      await SecureStorage.writeBool(key: key, value: value);
    } else if (value is String) {
      await SecureStorage.writeString(key: key, value: value);
    } else if (value is List<int>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<double>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<bool>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is List<String>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, int>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, double>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, bool>) {
      await SecureStorage.write(key: key, value: value);
    } else if (value is Map<String, String>) {
      await SecureStorage.write(key: key, value: value);
    } else {
      throw '警告, SecureStorage 尚只支持 int, double, bool, String, List<基本型態>, Map<String, 基本類型> 的型態, 當前型態: $T';
    }
  }

  @override
  Future<T> read() async {
    if (T == int) {
      _value = await SecureStorage.readInt(key: key) as T;
    } else if (T == double) {
      _value = await SecureStorage.readDouble(key: key) as T;
    } else if (T == bool) {
      _value = await SecureStorage.readBool(key: key) as T;
    } else if (T == String) {
      _value = await SecureStorage.readString(key: key) as T;
    } else if (List<int>() is T) {
      _value = await SecureStorage.readList<int>(key: key) as T;
    } else if (List<double>() is T) {
      _value = await SecureStorage.readList<double>(key: key) as T;
    } else if (List<bool>() is T) {
      _value = await SecureStorage.readList<bool>(key: key) as T;
    } else if (List<String>() is T) {
      _value = await SecureStorage.readList<String>(key: key) as T;
    } else if (Map<String, int>() is T) {
      _value = await SecureStorage.readMap<String, int>(key: key) as T;
    } else if (Map<String, double>() is T) {
      _value = await SecureStorage.readMap<String, double>(key: key) as T;
    } else if (Map<String, bool>() is T) {
      _value = await SecureStorage.readMap<String, bool>(key: key) as T;
    } else if (Map<String, String>() is T) {
      _value = await SecureStorage.readMap<String, String>(key: key) as T;
    } else {
      throw '警告, SecureStorage 尚只支持 int, double, bool, String, List<基本型態>, Map<String, 基本型態> 的型態, 當前型態: $T';
    }

    return value;
  }

  /// 刪除值
  /// [deleteLocal] - 是否也將本地儲存區的值刪除
  @override
  Future<void> delete({bool deleteLocal = false}) async {
    _value = null;
    if (deleteLocal) {
      await SecureStorage.delete(key: key);
    }
  }
}
