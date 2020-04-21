import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mx_core/mx_core.dart';

import 'result.dart';

part 'axis_space.dart';

part 'horizontal.dart';

part 'remain.dart';

part 'vertical.dart';

/// 空間計算
class SpaceCompute {
  Axis direction;

  _RemainSpace remainSpace;

  SpaceCompute({
    int segmentCount,
    this.direction,
    double segmentWidth,
    double segmentHeight,
    double verticalSpace,
    double horizontalSpace,
  }) : remainSpace = _RemainSpace(
          segmentCount: segmentCount,
          direction: direction,
          segmentWidth: segmentWidth,
          segmentHeight: segmentHeight,
          verticalSpace: verticalSpace,
          horizontalSpace: horizontalSpace,
        );

  /// 計算空間分配
  // ignore: missing_return
  List<SpaceResult> compute(List<AlignChildInfo> childInfo) {
    switch (direction) {
      case Axis.horizontal:
        return _horizontalCompute(
          childInfo: childInfo,
        );
        break;
      case Axis.vertical:
        return _verticalCompute(
          childInfo: childInfo,
        );
        break;
    }
  }

  /// 橫向計算空間分配
  List<SpaceResult> _horizontalCompute({List<AlignChildInfo> childInfo}) {
    return childInfo.map((e) => remainSpace.getFreeSpace(e)).toList();
  }

  /// 直向計算空間分配
  List<SpaceResult> _verticalCompute({List<AlignChildInfo> childInfo}) {
    return childInfo.map((e) => remainSpace.getFreeSpace(e)).toList();
  }
}
