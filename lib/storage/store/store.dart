import '../storage.dart';

part 'plain_data_store.dart';

part 'secure_data_store.dart';

abstract class DataStore<T> {
  final String key;
  T? _value;

  T? get value => _value ?? _defaultValue;
  final T? _defaultValue;

  DataStore({
    required this.key,
    T? defaultValue,
  })  : assert(T == int ||
            T == double ||
            T == bool ||
            T == String ||
            <int>[] is T ||
            <double>[] is T ||
            <bool>[] is T ||
            <String>[] is T ||
            <String, int>{} is T ||
            <String, double>{} is T ||
            <String, bool>{} is T ||
            <String, String>{} is T),
        _defaultValue = defaultValue;

  Future<void> write(T value);

  Future<T?> read();

  /// 刪除值
  Future<void> delete({bool deleteLocal = false});
}
