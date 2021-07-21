part of 'assist_touch.dart';

/// 外框類型
enum _RangeType {
  /// 外框不連續
  no,

  /// 外框為一個完整的圓形
  fullCircle,

  /// 外框兩條線是連續的
  begin1end2,
}

/// 按鈕的擴展外環為一個圓形
/// 此類為表示外誆的連續線條
/// [begin[0]] ~ [end[0]] 以及 [begin[1]] ~ [end[1]]
/// 當外框圓形為一個完整的圓形, [begin] 以及 [end] 的長度只會有1
/// 當外框有被切斷時, [begin] 以及 [end] 長度為2
class _CircleRange {
  List<double> begin;
  List<double> end;

  /// 取得此外框範圍類型
  _RangeType get rangeType {
    /// 兩段空間是否連續
    if (begin.length == 2) {
      if (begin[0] == 0 && end[1] == 360) {
        return _RangeType.begin1end2;
      }
      return _RangeType.no;
    } else {
      if (begin[0] == 0 && end[0] == 360) {
        return _RangeType.fullCircle;
      }
      return _RangeType.no;
    }
  }

  /// 取得此外環總長度
  double get totalRange {
    if (begin.length == 2) {
      return getRange(0) + getRange(1);
    } else {
      return getRange(0);
    }
  }

  _CircleRange._({required this.begin, required this.end});

  /// [center] - 主按鈕的中心點
  /// [mainRadius] - 主按鈕半徑
  /// [actionRadius] - 子按鈕半徑
  /// [expandRadius] - 展開半徑
  /// [containerSize] - 裝載整個物件的 size
  /// [sideSpace] - 距離邊界的空間
  factory _CircleRange({
    required Offset center,
    required double mainRadius,
    required double actionRadius,
    required double expandRadius,
    required Size containerSize,
    required double sideSpace,
  }) {
    // 檢測四個方向是否超出邊界
    var sideOutsideDetect = _SideDetect(
      center: center,
      mainRadius: mainRadius,
      actionRadius: actionRadius,
      expandRadius: expandRadius,
      containerSize: containerSize,
      sideSpace: sideSpace,
    );

    // 取得四個方向的檢測結果
    var right = sideOutsideDetect.detect(AxisDirection.right);
    var top = sideOutsideDetect.detect(AxisDirection.up);
    var left = sideOutsideDetect.detect(AxisDirection.left);
    var bottom = sideOutsideDetect.detect(AxisDirection.down);

    // 右方超出邊界
    if (right.outside) {
      double begin;
      double end;
      if (top.outside) {
        // 右方跟上方皆超出邊界
        begin = top.end;
        end = right.end;
      } else if (bottom.outside) {
        // 右方跟下方皆超出邊界
        begin = right.begin;
        end = bottom.begin;
      } else {
        // 只有右方超出邊界
        begin = right.begin;
        end = right.end;
      }
//      print("最終: $begin, $end");
      return _CircleRange._(begin: [begin], end: [end]);
    }

    // 上方超出邊界
    if (top.outside) {
      if (left.outside) {
        // 上方跟左方超出邊界
        var begin1 = 0.0;
        var end1 = top.begin;
        var begin2 = left.end;
        var end2 = 360.0;
        return _CircleRange._(begin: [begin1, begin2], end: [end1, end2]);
      } else {
        // 只有上方超出邊界
        var begin1 = 0.0;
        var end1 = top.begin;
        var begin2 = top.end;
        var end2 = 360.0;
        return _CircleRange._(begin: [begin1, begin2], end: [end1, end2]);
      }
    }

    // 左方超出邊界
    if (left.outside) {
      if (bottom.outside) {
        // 左方跟下方超出邊界
        var begin1 = 0.0;
        var end1 = left.begin;
        var begin2 = bottom.end;
        var end2 = 360.0;
        return _CircleRange._(begin: [begin1, begin2], end: [end1, end2]);
      } else {
        // 只有左方超出邊界
        var begin1 = 0.0;
        var end1 = left.begin;
        var begin2 = left.end;
        var end2 = 360.0;
        return _CircleRange._(begin: [begin1, begin2], end: [end1, end2]);
      }
    }

    // 下方超出邊界
    if (bottom.outside) {
      var begin1 = 0.0;
      var end1 = bottom.begin;
      var begin2 = bottom.end;
      var end2 = 360.0;
      return _CircleRange._(begin: [begin1, begin2], end: [end1, end2]);
    }

    // 沒有任何一邊超出邊界, 是一個完整的圓
    return _CircleRange._(begin: [0], end: [360]);
  }

  /// 取得第 [index] 的線條範圍
  double getRange(int index) {
    if (index >= end.length || index >= begin.length) {
      print("此範圍線條只有 ${begin.length} 段, 無法取得第 $index 的範圍");
      return 0;
    } else {
      return end[index] - begin[index];
    }
  }

  /// [splitCount] - 此外框要分割的數量
  /// [sortIndex] - 排序的index
  /// 返回當此範圍分割成[splitCount]段時, 這個排序的index的角度
  double getTheta(int splitCount, sortIndex) {
    if (begin.length == 2) {
      var single = totalRange / (splitCount - 1);
      var multiple = single * sortIndex;
      // 代表有兩段
      if (multiple > end[0]) {
        var remain = 360 - (multiple - end[0]);
        return remain;
      } else {
        return end[0] - multiple;
      }
    } else {
      if (rangeType == _RangeType.fullCircle) {
        var single = totalRange / (splitCount);
        var multiple = single * sortIndex;
        return begin[0] + multiple;
      } else {
        var single = totalRange / (splitCount - 1);
        var multiple = single * sortIndex;
        return begin[0] + multiple;
      }
    }
  }

  /// 打印出範圍
  @override
  String toString() {
    if (begin.length == 2) {
      return "範圍: [0] - ${begin[0]} ~ ${end[0]}, [1] - ${begin[1]} ~ ${end[1]}";
    } else {
      return "範圍: [0] - ${begin[0]} ~ ${end[0]}";
    }
  }
}
