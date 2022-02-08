import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/model/chart_state/indicator_chart_state.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/chart_state/volume_chart_state.dart';

/// 圖表占用高度設定
class ChartHeightRatioSetting {
  /// 主圖表固定高度
  final double? mainFixed;

  /// 主圖表高度比例
  final double? mainRatio;

  /// 買賣圖表固定高度
  final double? volumeFixed;

  /// 買賣圖表高度比例
  final double? volumeRatio;

  /// 其餘技術線圖表固定高度
  final double? indicatorFixed;

  /// 其餘技術線圖表高度比例
  final double? indicatorRatio;

  /// 下方日期占用高度
  final double bottomTimeFixed;

  /// 是否有設定主圖表高度
  bool get _isMainSetting => mainFixed != null || mainRatio != null;

  /// 是否有設定買賣圖表高度
  bool get _isVolumeSetting => volumeFixed != null || volumeRatio != null;

  /// 是否有設定技術圖表高度
  bool get _isIndicatorSetting =>
      indicatorFixed != null || indicatorRatio != null;

  /// 高度是否全為固定值
  bool isHeightFixed({
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
  }) {
    if (mainFixed == null) {
      return false;
    }
    if (volumeChartState != VolumeChartState.none && volumeFixed == null) {
      return false;
    }
    if (indicatorChartState != IndicatorChartState.none &&
        indicatorFixed == null) {
      return false;
    }
    return true;
  }

  /// 若高度全為固定值, 取得總高度
  /// 若不是全為固定值, 則回傳null
  double? getFixedHeight({
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
  }) {
    if (!isHeightFixed(
      volumeChartState: volumeChartState,
      indicatorChartState: indicatorChartState,
    )) {
      return null;
    }

    final mainHeight = mainFixed!;
    final volumeHeight =
        volumeChartState == VolumeChartState.none ? 0 : volumeFixed!;
    final indicatorHeight =
        indicatorChartState == IndicatorChartState.none ? 0 : indicatorFixed!;
    return mainHeight + volumeHeight + indicatorHeight + bottomTimeFixed;
  }

  const ChartHeightRatioSetting({
    this.mainFixed,
    this.mainRatio,
    this.volumeFixed,
    this.volumeRatio,
    this.indicatorFixed,
    this.indicatorRatio,
    this.bottomTimeFixed = 25,
  });

  /// 分配各個主題占用高度
  ChartHeightCampute<double> computeChartHeight({
    required double totalHeight,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
  }) {
    final remainTotalHeight = totalHeight - bottomTimeFixed;

    double? mainHeight, volumeHeight, indicatorHeight;
    if (_isMainSetting) {
      mainHeight =
          mainFixed ?? (mainRatio! * remainTotalHeight).floorToDouble();
    }

    if (volumeChartState == VolumeChartState.none) {
      volumeHeight = 0;
    } else if (_isVolumeSetting) {
      volumeHeight =
          volumeFixed ?? (volumeRatio! * remainTotalHeight).floorToDouble();
    }

    if (indicatorChartState == IndicatorChartState.none) {
      indicatorHeight = 0;
    } else if (_isIndicatorSetting) {
      indicatorHeight = indicatorFixed ??
          (indicatorRatio! * remainTotalHeight).floorToDouble();
    }

    mainHeight ??=
        remainTotalHeight - (volumeHeight ?? 0) - (indicatorHeight ?? 0);
    volumeHeight ??= remainTotalHeight - mainHeight - (indicatorHeight ?? 0);
    indicatorHeight ??= remainTotalHeight - mainHeight - volumeHeight;

    // print('高: $mainHeight, $volumeHeight, $indicatorHeight');

    return ChartHeightCampute<double>(
      main: mainHeight,
      volume: volumeHeight,
      indicator: indicatorHeight,
      bottomTime: bottomTimeFixed,
    );
  }
}

class ChartHeightCampute<T> {
  final T main;
  final T volume;
  final T indicator;
  final T bottomTime;

  ChartHeightCampute({
    required this.main,
    required this.volume,
    required this.indicator,
    required this.bottomTime,
  });
}

extension HeightToRect on ChartHeightCampute<double> {
  /// 將高轉換為Rect
  ChartHeightCampute<Rect> toRect(Size size) {
    final mainRect = Rect.fromLTRB(0, 0, size.width, main);
    final volumeRect = Rect.fromLTWH(0, main, size.width, volume);
    final indicatorRect =
        Rect.fromLTWH(0, volumeRect.bottom, size.width, indicator);
    final bottomTimeRect =
        Rect.fromLTWH(0, indicatorRect.bottom, size.width, bottomTime);
    return ChartHeightCampute<Rect>(
      main: mainRect,
      volume: volumeRect,
      indicator: indicatorRect,
      bottomTime: bottomTimeRect,
    );
  }
}
