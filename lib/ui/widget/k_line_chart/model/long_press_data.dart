import 'package:mx_core/mx_core.dart';

/// 長按的資料
class LongPressData {
  /// 長按的k線資料
  final KLineData data;

  /// 長按的資料是否處於元件左側
  final bool isLongPressAtLeft;

  LongPressData({
    required this.data,
    required this.isLongPressAtLeft,
  });
}
