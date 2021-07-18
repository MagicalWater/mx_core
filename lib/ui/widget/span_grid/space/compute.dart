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
  Axis get direction => remainSpace.direction;

  _RemainSpace remainSpace;

  SpaceCompute({
    required int segmentCount,
    required Axis direction,
    required double segmentWidth,
    required double segmentHeight,
    required double verticalSpace,
    required double horizontalSpace,
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
  List<SpaceResult> _horizontalCompute(
      {required List<AlignChildInfo> childInfo}) {
    return childInfo.map((e) => remainSpace.getFreeSpace(e)).toList();
  }

  /// 直向計算空間分配
  List<SpaceResult> _verticalCompute(
      {required List<AlignChildInfo> childInfo}) {
    return childInfo.map((e) => remainSpace.getFreeSpace(e)).toList();
  }
}
