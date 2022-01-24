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
  final double bottomDateFixed;

  /// 主圖表的上方空格高度
  final double topSpaceFixed;

  /// 是否有設定主圖表高度
  bool get _isMainSetting => mainFixed != null || mainRatio != null;

  /// 是否有設定買賣圖表高度
  bool get _isVolumeSetting => volumeFixed != null || volumeRatio != null;

  /// 是否有設定技術圖表高度
  bool get _isIndicatorSetting =>
      indicatorFixed != null || indicatorRatio != null;

  ChartHeightRatioSetting({
    this.mainFixed,
    this.mainRatio,
    this.volumeFixed,
    this.volumeRatio,
    this.indicatorFixed,
    this.indicatorRatio,
    this.topSpaceFixed = 40,
    this.bottomDateFixed = 20,
  });

  /// 分配各個主題占用高度
  ChartHeightCampute computeChartHeight({
    required double totalHeight,
    required VolumeChartState volumeChartState,
    required IndicatorChartState indicatorChartState,
  }) {
    final remainTotalHeight = totalHeight - bottomDateFixed - topSpaceFixed;

    double? mainHeight, volumeHeight, indicatorHeight;
    if (_isMainSetting) {
      mainHeight = mainFixed ?? (mainRatio! * remainTotalHeight);
    }

    if (volumeChartState == VolumeChartState.none) {
      volumeHeight = 0;
    } else if (_isVolumeSetting) {
      volumeHeight = volumeFixed ?? (volumeRatio! * remainTotalHeight);
    }

    if (indicatorChartState != IndicatorChartState.none) {
      indicatorHeight = 0;
    } else if (_isIndicatorSetting) {
      indicatorHeight = indicatorFixed ?? (indicatorRatio! * remainTotalHeight);
    }

    mainHeight ??=
        remainTotalHeight - (volumeHeight ?? 0) - (indicatorHeight ?? 0);
    volumeHeight ??= remainTotalHeight - mainHeight - (indicatorHeight ?? 0);
    indicatorHeight ??= remainTotalHeight - mainHeight - volumeHeight;

    return ChartHeightCampute(
      mainHeight: mainHeight,
      volumeHeight: volumeHeight,
      indicatorHeight: indicatorHeight,
    );
  }
}

class ChartHeightCampute {
  final double mainHeight;
  final double volumeHeight;
  final double indicatorHeight;

  ChartHeightCampute({
    required this.mainHeight,
    required this.volumeHeight,
    required this.indicatorHeight,
  });
}
