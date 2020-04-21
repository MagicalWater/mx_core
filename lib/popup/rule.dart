part of 'impl.dart';

/// 點擊規則
enum HitRule {
  /// 完全穿透
  through,

  /// 子元件不穿透, 其餘穿透
  childIntercept,

  /// 完全不穿透, 點擊事件完全攔截
  intercept,
}
