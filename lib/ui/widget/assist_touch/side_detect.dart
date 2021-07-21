part of 'assist_touch.dart';

/// 邊界檢測
class _SideDetect {
  Offset center;

  /// 主按鈕半徑
  double mainRadius;

  /// 子按鈕半徑
  double actionRadius;

  /// 展開的半徑
  double expandRadius;

  /// 裝載整個物件的size
  Size containerSize;

  /// 預留邊界的space
  double sideSpace;

  _SideDetect({
    required this.center,
    required this.mainRadius,
    required this.actionRadius,
    required this.expandRadius,
    required this.containerSize,
    required this.sideSpace,
  });

  /// 檢測是否超出邊界
  _SideDetectResult detect(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return _up();
      case AxisDirection.right:
        return _right();
      case AxisDirection.down:
        return _down();
      case AxisDirection.left:
        return _left();
    }
  }

  /// 檢測右邊是否超出邊界
  _SideDetectResult _right() {
    var result = _SideDetectResult();

    result.outside =
        center.dx + actionRadius + expandRadius > containerSize.width;

    if (result.outside) {
//      print("右邊超出邊界");
      var innerX = containerSize.width - center.dx - actionRadius - sideSpace;
      var theta = acos(innerX / expandRadius) * 180 / pi;
      var begin = theta;
      var end = 360 - begin;
      result.begin = begin;
      result.end = end;
    }

    return result;
  }

  /// 檢測下方是否超出邊界
  _SideDetectResult _down() {
    var result = _SideDetectResult();

    result.outside =
        center.dy + actionRadius + expandRadius > containerSize.height;

    if (result.outside) {
//      print("下方超出邊界");
      var innerY = containerSize.height - center.dy - actionRadius - sideSpace;
      var theta = acos(innerY / expandRadius) * 180 / pi;
      var begin = 180 + (90 - theta);
      var end = begin + theta * 2;
      result.begin = begin;
      result.end = end;
    }

    return result;
  }

  /// 檢測左方是否超出邊屆
  _SideDetectResult _left() {
    var result = _SideDetectResult();

    result.outside = center.dx - expandRadius - actionRadius < 0;

    if (result.outside) {
//      print("左方超出邊界");
      var innerX = center.dx - actionRadius - sideSpace;
      var theta = acos(innerX / expandRadius) * 180 / pi;
      var begin = 180 - (theta);
      var end = 360 - begin;
      result.begin = begin;
      result.end = end;
    }

    return result;
  }

  /// 檢測上方是否超出邊屆
  _SideDetectResult _up() {
    var result = _SideDetectResult();

    result.outside = center.dy - expandRadius - actionRadius < 0;

    if (result.outside) {
//      print("上方超出邊界");
      var innerY = center.dy - actionRadius - sideSpace;
      var theta = acos(innerY / expandRadius) * 180 / pi;
      var begin = 90 - theta;
      var end = begin + theta * 2;
      result.begin = begin;
      result.end = end;
    }

    return result;
  }
}

class _SideDetectResult {
  bool outside = false;
  double begin = 0;
  double end = 0;

  _SideDetectResult();
}
