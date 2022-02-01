import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/kdj_chart/ui_style/kdj_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/macd_chart/macd_chart_render_impl.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/rsi_chart/ui_style/rsi_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/volume_chart/ui_style/volume_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/wr_chart/ui_style/wr_chart_ui_style.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/main_chart_render.dart';

import 'ui_style/k_line_chart_ui_style.dart';

/// 顯示的資料
abstract class DataViewer {
  /// 視圖中, 顯示的第一個以及最後一個data的index
  abstract int startDataIndex, endDataIndex;

  /// 當前x軸縮放
  double get scaleX;

  /// 長按的y軸位置
  double? get longPressY;

  /// 圖表資料
  abstract final List<KLineData> datas;

  /// 圖表通用ui風格
  abstract final KLineChartUiStyle chartUiStyle;

  /// 主圖表ui風格
  abstract final MainChartUiStyle mainChartUiStyle;

  /// 成交量圖表ui風格
  abstract final VolumeChartUiStyle volumeChartUiStyle;

  /// macd圖表ui風格
  abstract final MACDChartUiStyle macdChartUiStyle;

  /// rsi圖表ui風格
  abstract final RSIChartUiStyle rsiChartUiStyle;

  /// wr圖表ui風格
  abstract final WRChartUiStyle wrChartUiStyle;

  /// kdj圖表ui風格
  abstract final KDJChartUiStyle kdjChartUiStyle;

  /// 主圖表顯示的資料
  abstract final List<MainChartState> mainState;

  /// 買賣量圖表
  abstract final VolumeChartState volumeState;

  /// 技術指標圖表
  abstract final IndicatorChartState indicatorState;

  /// ma(均線)週期
  abstract final List<int> maPeriods;

  /// 價格格式化
  abstract final String Function(num price) priceFormatter;

  /// 成交量格式化
  abstract final String Function(num volume) volumeFormatter;

  /// x軸日期時間格式化
  abstract final String Function(DateTime dateTime) xAxisDateTimeFormatter;

  /// 取得長按中的data index
  int? getLongPressDataIndex();

  /// 取得長按中的data
  KLineData? getLongPressData();

  /// 將data的索引值轉換為畫布繪製的x軸座標
  double dataIndexToRealX(int index);

  /// 將畫布繪製的x軸座標轉換為data的索引值
  int realXToDataIndex(double realX);
}
