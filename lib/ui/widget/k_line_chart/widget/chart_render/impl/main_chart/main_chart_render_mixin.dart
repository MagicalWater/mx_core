import 'dart:math';
import 'dart:ui';

import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';

import '../../chart_render.dart';
import 'main_chart_color_setting.dart';
import 'main_chart_size_setting.dart';
import 'main_chart_ui_style.dart';

mixin MainChartMixin on ChartRender {
  /// 資料檢視區間的最小值/最大值
  late double minValue, maxValue;

  /// 顯示的y軸位置區間
  /// [maxValue] 對應[minY]
  /// [minValue] 對應[maxY]
  late double minY, maxY;

  /// 快速將 value 轉換為 y軸位置的縮放參數
  late double valueToYScale;

  final Paint backgroundPaint = Paint();
  final Paint gripPaint = Paint();

  MainChartUiStyle get uiStyle => dataViewer.mainChartUiStyle;

  MainChartColorSetting get colors => uiStyle.colorSetting;

  MainChartSizeSetting get sizes => uiStyle.sizeSetting;

  List<MainChartState> get mainState => dataViewer.mainState;

  final chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;

  @override
  void initValue(Rect rect) {
    minY = rect.top + dataViewer.chartUiStyle.heightRatioSetting.topSpaceFixed;
    maxY = rect.bottom;

    // 取得顯示區間的資料的最大值
    maxValue = 0;
    minValue = double.infinity;

    final maDisplay = dataViewer.mainState.contains(MainChartState.ma);
    final bollDisplay = dataViewer.mainState.contains(MainChartState.boll);
    for (var i = dataViewer.startDataIndex; i < dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      maxValue = max(maxValue, data.high);
      minValue = min(minValue, data.low);

      if (maDisplay) {
        //TODO: 上需要確認ma的最大最小值
        // maxValue = max(maxValue, data.ma.values.reduce(max));
        // minValue = min(minValue, data.ma.values.reduce(min));
      }

      if (bollDisplay) {
        //TODO: 上需要確認boll的最大最小值
      }
    }

    // 取得 value 快速轉換 y軸位置的縮放參數
    final valueInterval = maxValue - minValue;
    final yInterval = maxY - minY;
    valueToYScale = yInterval / valueInterval;
  }

  /// 帶入數值, 取得顯示的y軸位置
  double valueToRealY(double value) {
    final result= maxY - (value - minValue) * valueToYScale;
    return result;
  }

  /// 畫蠟燭
  /// [x] - 此蠟燭的正中央x軸位置
  void paintCandle(Canvas canvas, double x, KLineData data) {
    final highY = valueToRealY(data.high);
    final lowY = valueToRealY(data.low);
    var openY = valueToRealY(data.open);
    var closeY = valueToRealY(data.close);

    // print('繪製圖表: y軸: $openY');

    // 若開盤收盤相減小余1, 則將其多繪製至1px, 防止線太細
    if ((openY - closeY).abs() < 1) {
      if (openY > closeY) {
        openY += 0.5;
        closeY -= 0.5;
      } else {
        openY -= 0.5;
        closeY += 0.5;
      }
    }

    // 取得蠟燭寬度/線條寬度半徑
    final candleRadius = dataViewer.chartUiStyle.sizeSetting.candleWidth / 2;
    final lineRadius = dataViewer.chartUiStyle.sizeSetting.candleLineWidth / 2;

    // 畫四方型
    canvas.drawRect(
      Rect.fromLTRB(x - candleRadius, highY, x + candleRadius, lowY),
      chartPaint..color = openY > closeY ? colors.upColor : colors.downColor,
    );

    // 畫中間線
    canvas.drawRect(
      Rect.fromLTRB(x - lineRadius, highY, x + lineRadius, lowY),
      chartPaint..color = openY > closeY ? colors.upColor : colors.downColor,
    );
  }
}
