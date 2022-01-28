import 'package:flutter/painting.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/chart_state/indicator_chart_state.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/chart_state/volume_chart_state.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/macd_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/main_chart_render.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/volume_chart_render.dart';

mixin ChartPainterPaintMixin on ChartPainter {
  /// 交叉豎線畫筆
  final _crossLinePaint = Paint()..isAntiAlias = true;

  /// 下方時間軸畫筆
  final _bottomTimePaint = Paint()..isAntiAlias = true;

  /// 下方長按時間軸畫筆
  final _longPressTimePaint = Paint()..isAntiAlias = true;

  /// 繪製主圖表
  void paintMainChart(Canvas canvas, Rect rect) {
    final render = MainChartRenderImpl(dataViewer: this);
    render.initValue(rect);
    render.paintBackground(canvas, rect);
    render.paintGrid(canvas, rect);
    render.paintTopValueText(canvas, rect);
    render.paintChart(canvas, rect);
    render.paintRightValueText(canvas, rect);
    render.paintMaxMinValue(canvas, rect);
    render.paintRealTimeLine(canvas, rect);
    render.paintLongPressHorizontalLineAndValue(canvas, rect);
    render.paintLongPressHorizontalLineAndValue(canvas, rect);
  }

  /// 繪製volume圖表
  void paintVolumeChart(Canvas canvas, Rect rect) {
    switch (volumeState) {
      case VolumeChartState.volume:
        final render = VolumeChartRenderImpl(dataViewer: this);
        render.initValue(rect);
        render.paintBackground(canvas, rect);
        render.paintGrid(canvas, rect);
        render.paintTopValueText(canvas, rect);
        render.paintChart(canvas, rect);
        render.paintRightValueText(canvas, rect);
        break;
      case VolumeChartState.none:
        // TODO: Handle this case.
        break;
    }
  }

  /// 繪製技術指標圖表
  void paintIndicatorChart(Canvas canvas, Rect rect) {
    switch (indicatorState) {
      case IndicatorChartState.macd:
        final render = MACDChartRenderImpl(dataViewer: this);
        render.initValue(rect);
        render.paintBackground(canvas, rect);
        render.paintGrid(canvas, rect);
        render.paintTopValueText(canvas, rect);
        render.paintChart(canvas, rect);
        render.paintRightValueText(canvas, rect);
        break;
      case IndicatorChartState.rsi:
        // TODO: Handle this case.
        break;
      case IndicatorChartState.wr:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
  }

  /// 繪製長按豎線
  void paintLongPressVerticalLine(Canvas canvas, Size size) {
    // 取得長案的資料index
    final index = getLongPressDataIndex();
    if (index == null) {
      return;
    }
    final x = dataIndexToRealX(index);
    _crossLinePaint.color = chartUiStyle.colorSetting.longPressVerticalLine;
    _crossLinePaint.strokeWidth =
        chartUiStyle.sizeSetting.longPressVerticalLineWidth *
            chartGesture.scaleX;

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height - chartUiStyle.heightRatioSetting.bottomTimeFixed),
      _crossLinePaint,
    );
  }

  /// 繪製長按時間
  void paintLongPressTime(Canvas canvas, Rect rect) {
    final index = getLongPressDataIndex();
    if (index == null) {
      return;
    }

    // 取得資料的中心x軸位置
    final x = dataIndexToRealX(index);

    final sizes = chartUiStyle.sizeSetting;
    final colors = chartUiStyle.colorSetting;

    final data = datas[index];
    final timePainter = TextPainter(
      text: TextSpan(
        text: formateTime(data.dateTime),
        style: TextStyle(
          color: colors.longPressTime,
          fontSize: sizes.longPressTime,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    timePainter.layout();
    final timeWidth = timePainter.width;
    final timeHeight = timePainter.height;

    final horizontalPadding = sizes.longPressTimeBorderHorizontalPadding;
    final verticalPadding = sizes.longPressTimeBorderVerticalPadding;

    final totalWidth = horizontalPadding * 2 + timeWidth;
    final totalHeight = verticalPadding * 2 + timeHeight;

    // 時間框的位置Rect
    Rect timeRect;

    if (x - totalWidth / 2 <= rect.left) {
      // 時間顯示左側會超出邊界, 因此固定開頭在起始點
      timeRect = Rect.fromLTWH(
        rect.left,
        rect.top,
        totalWidth,
        totalHeight,
      );
    } else if (x + totalWidth / 2 >= rect.right) {
      // 時間顯示右側會超出邊界, 因此固定開頭在結束點
      timeRect = Rect.fromLTWH(
        rect.right - totalWidth,
        rect.top,
        totalWidth,
        totalHeight,
      );
    } else {
      // 可以正常於中間顯示
      timeRect = Rect.fromLTWH(
        x - totalWidth / 2,
        rect.top,
        totalWidth,
        totalHeight,
      );
    }

    // 繪製背景
    canvas.drawRect(
      timeRect,
      _longPressTimePaint
        ..style = PaintingStyle.fill
        ..color = colors.longPressTimeBg,
    );

    // 繪製外框
    canvas.drawRect(
      timeRect,
      _longPressTimePaint
        ..style = PaintingStyle.stroke
        ..color = colors.longPressTimeBorder,
    );

    // 繪製時間文字
    timePainter.paint(
      canvas,
      Offset(
        timeRect.center.dx - timeWidth / 2,
        timeRect.center.dy - timeHeight / 2,
      ),
    );
  }

  /// 繪製時間軸
  void paintTimeAxis(Canvas canvas, Rect rect) {
    final sizes = chartUiStyle.sizeSetting;
    final colors = chartUiStyle.colorSetting;

    // 繪製背景
    _bottomTimePaint.color = colors.bottomTimeBg;
    canvas.drawRect(rect, _bottomTimePaint);

    // 繪製上方橫格線
    canvas.drawLine(
      Offset(0, rect.top),
      Offset(rect.right, rect.top),
      _bottomTimePaint..color = colors.grid,
    );

    final columnWidth = rect.width / sizes.gridColumns;
    final timeTextStyle = TextStyle(
      color: colors.bottomTimeText,
      fontSize: sizes.bottomTimeText,
    );

    for (var i = 1; i < sizes.gridColumns; ++i) {
      final x = columnWidth * i;
      final dataIndex = realXToDataIndex(x);
      final data = datas[dataIndex];
      final textPainter = TextPainter(
        text: TextSpan(
          text: formateTime(data.dateTime),
          style: timeTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }
}