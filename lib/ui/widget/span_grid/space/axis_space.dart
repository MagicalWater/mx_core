part of 'compute.dart';

abstract class _AlignSpace<T> implements Comparable<T> {
  /// 假如此空間可以容納 [info] 時, 取得將會佔用的空間, 否則返回 null
  T? getSpaceIfContain(AlignChildInfo info, double space);

  /// 從此空間切下一部分空間, 回傳剩餘的空間
  List<T> cut(T other);

  /// 將 space 轉為 rect
  Rect toRect();

  /// 比較兩個空間是否有重疊
  bool overlaps(T other);

  /// 取得兩個 空間 的交集
  T intersect(T other);

  /// 是否完全包含某個space
  bool contains(T other);
}
