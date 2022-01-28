import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/chart_painter.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_render_value_mixin.dart';

import '../../main_chart_render.dart';
import 'main_chart_render_paint_mixin.dart';

export 'ui_style/main_chart_ui_style.dart';

class MainChartRenderImpl extends MainChartRender
    with MainChartValueMixin, MainChartRenderPaintMixin {
  MainChartRenderImpl({
    required DataViewer dataViewer,
  }) : super(dataViewer: dataViewer);

  /// 繪製背景
  @override
  void paintBackground(Canvas canvas, Rect rect) {
    backgroundPaint.color = colors.background;
    canvas.drawRect(rect, backgroundPaint);
  }

  @override
  void paintGrid(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    gripPaint.color = chartUiStyle.colorSetting.grid;
    final gridRows = chartUiStyle.sizeSetting.gridRows;
    final gridColumns = chartUiStyle.sizeSetting.gridColumns;
    final topPadding = sizes.topPadding;
    final bottomPadding = sizes.bottomPadding;

    // 每一列的高度
    final rowHeight = (rect.height - topPadding - bottomPadding) / gridRows;

    // 每一行寬度
    final columnWidth = rect.width / gridColumns;

    // 畫橫線
    for (int i = 0; i <= gridRows; i++) {
      final y = rowHeight * i + topPadding;
      canvas.drawLine(
        Offset(0, y),
        Offset(rect.width, y),
        gripPaint,
      );
    }

    // 畫直線
    for (var i = 1; i < gridColumns; i++) {
      final x = columnWidth * i;
      canvas.drawLine(
        Offset(x, topPadding / 3),
        Offset(x, rect.bottom),
        gripPaint,
      );
    }
  }

  /// 繪製上方的數值說明文字
  @override
  void paintTopValueText(Canvas canvas, Rect rect) {
    final displayData = dataViewer.getLongPressData() ?? dataViewer.datas.last;
    final maData = displayData.indciatorData.ma?.ma;
    final spanTexts = <TextSpan>[];

    // 檢查是否需要顯示ma資訊
    if (mainState.contains(MainChartState.ma)) {
      final maTextStyle = TextStyle(fontSize: sizes.indexTip);
      final maSpan = dataViewer.maPeriods
          .map((e) {
            final value = maData?[e];
            if (value == null || value == 0) {
              return null;
            }
            return TextSpan(
              text: 'MA$e:$value    ',
              style: maTextStyle.copyWith(
                color: colors.maLine[e],
              ),
            );
          })
          .whereType<TextSpan>()
          .toList();
      spanTexts.addAll(maSpan);
    }

    // 檢查是否需要顯示boll訊息
    final bollData = displayData.indciatorData.boll;
    if (mainState.contains(MainChartState.boll) && bollData != null) {
      final bollTextStyle = TextStyle(fontSize: sizes.indexTip);

      final bollSpan = [
        TextSpan(
          text: 'BOLL:${dataViewer.formatPrice(bollData.mb)}    ',
          style: bollTextStyle.copyWith(color: colors.bollMb),
        ),
        TextSpan(
          text: 'UP:${dataViewer.formatPrice(bollData.up)}    ',
          style: bollTextStyle.copyWith(color: colors.bollUp),
        ),
        TextSpan(
          text: 'LB:${dataViewer.formatPrice(bollData.dn)}    ',
          style: bollTextStyle.copyWith(color: colors.bollDn),
        ),
      ];
      spanTexts.addAll(bollSpan);
    }

    if (spanTexts.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(children: spanTexts),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, rect.top));
  }

  /// 繪製右方的數值說明文字
  @override
  void paintRightValueText(Canvas canvas, Rect rect) {
    final chartUiStyle = dataViewer.chartUiStyle;
    final gridRows = chartUiStyle.sizeSetting.gridRows;
    final topPadding = sizes.topPadding;
    final bottomPadding = sizes.bottomPadding;
    final rowHeight = (rect.height - topPadding - bottomPadding) / gridRows;

    final textStyle = TextStyle(
      fontSize: sizes.rightValueText,
      color: colors.rightValueText,
    );

    for (var i = 0; i <= gridRows; ++i) {
      final positionY = i * rowHeight + topPadding;

      // 取得分隔線對應的數值
      final value = realYToValue(positionY);
      final span = TextSpan(
        text: dataViewer.formatPrice(value),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 將數值繪製在分隔線上方
      final textY = positionY - textPainter.height;
      textPainter.paint(
        canvas,
        Offset(rect.width - textPainter.width, textY),
      );
    }
  }

  /// 繪製圖表
  @override
  void paintChart(Canvas canvas, Rect rect) {
    // 蠟燭線跟折線只能存在一個
    if (dataViewer.mainState.contains(MainChartState.kLine)) {
      paintCandleChart(canvas, rect);
    } else if (dataViewer.mainState.contains(MainChartState.lineIndex)) {
      paintLineChart(canvas, rect);
    }

    // 繪製ma線
    if (dataViewer.mainState.contains(MainChartState.ma)) {
      paintMaChart(canvas, rect);
    }

    // 繪製boll線
    if (dataViewer.mainState.contains(MainChartState.boll)) {
      paintBollChart(canvas, rect);
    }
  }

  /// 繪製實時線
  @override
  void paintRealTimeLine(Canvas canvas, Rect rect) {
    final lastData = dataViewer.datas.last;
    final realTimeValue = lastData.close;

    // 右側顯示的實時數值
    final rightValueSpan = TextSpan(
      text: dataViewer.formatPrice(realTimeValue),
      style: TextStyle(
        fontSize: sizes.realTimeLineValue,
        color: colors.realTimeRightValue,
      ),
    );
    final valuePainter = TextPainter(
      text: rightValueSpan,
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();

    // 取得實時線的y軸位置
    // 之所以不用final, 是因為當在右側空間不可容納實時數值時
    // 可能會有超出上下限的情況, 此時需要調整至最高/最低
    final y = valueToRealY(realTimeValue);

    // 取得右側可以用來顯示的剩餘空間
    final rightRemainingSpace = rect.width -
        (dataViewer.dataIndexToRealX(dataViewer.endDataIndex) +
            (dataViewer.chartUiStyle.sizeSetting.dataWidth / 2));

    // if (!isLine) x += mPointWidth / 2;

    if (valuePainter.width < rightRemainingSpace) {
      // 右側空間可容納實時數值

      // 繪製右側的實時線
      paintRealTimeLineAtRight(
        canvas: canvas,
        rect: rect,
        startX: rect.width - rightRemainingSpace,
        valuePainter: valuePainter,
        y: y,
      );
    } else {
      // 右側不可容納實時數值

      // 需要繪製的實時數值
      // 與[rightValueSpan]顏色可能會不同
      final valueSpan = TextSpan(
          text: rightValueSpan.text,
          style: rightValueSpan.style!.copyWith(color: colors.realTimeValue));
      valuePainter.text = valueSpan;

      // 繪製跨越整個畫布的實時線
      paintRealTimeLineAtGlobal(
        canvas: canvas,
        rect: rect,
        valuePainter: valuePainter,
        y: y,
      );
    }
  }

  /// 繪製最大最小值
  @override
  void paintMaxMinValue(Canvas canvas, Rect rect) {
    // 圖表狀態為折線圖時不需顯示
    if (dataViewer.mainState.contains(MainChartState.lineIndex)) {
      return;
    }

    // 畫值
    // [value] - 需要畫的值
    // [dataIndex] - 需要畫的值對應的資料index
    // [y] - 需要畫得值對應的y軸位置
    // [textStyle] - 繪製的文字style
    void paintValue({
      required double value,
      required int dataIndex,
      required double y,
      required TextStyle textStyle,
    }) {
      // 取得資料位於畫布上的x軸位置
      final valueX = dataViewer.dataIndexToRealX(dataIndex);

      // 是否處於畫布左半邊
      final valueAtLeft = valueX < rect.width / 2;

      final valueText = valueAtLeft
          ? '── ${dataViewer.formatPrice(value)}'
          : '${dataViewer.formatPrice(value)} ──';

      final valuePainter = TextPainter(
        text: TextSpan(text: valueText, style: textStyle),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();

      final valueOffsetX = valueAtLeft ? valueX : valueX - valuePainter.width;
      valuePainter.paint(
        canvas,
        Offset(valueOffsetX, y - valuePainter.height / 2),
      );
    }

    // 畫最小值
    paintValue(
      value: minValue,
      dataIndex: minValueDataIndex,
      y: maxY,
      textStyle: TextStyle(
        fontSize: sizes.minValueText,
        color: colors.minValueText,
      ),
    );

    // 畫最大值
    paintValue(
      value: maxValue,
      dataIndex: maxValueDataIndex,
      y: minY,
      textStyle: TextStyle(
        fontSize: sizes.maxValueText,
        color: colors.maxValueText,
      ),
    );
  }

  /// 繪製長按橫線與數值
  @override
  void paintLongPressHorizontalLineAndValue(Canvas canvas, Rect rect) {
    var longPressY = dataViewer.longPressY;
    final dataIndex = dataViewer.getLongPressDataIndex();
    if (longPressY == null || dataIndex == null) {
      return;
    }

    // 將y限制在最大最小值
    longPressY = longPressY.clamp(minY, maxY);

    final longPressX = dataViewer.dataIndexToRealX(dataIndex);

    // 繪製橫向與交叉點
    paintLongPressHorizontalPoint(
      canvas: canvas,
      rect: rect,
      longPressX: longPressX,
      longPressY: longPressY,
    );

    // 繪製y軸數值
    paintLongPressValue(
      canvas: canvas,
      rect: rect,
      longPressX: longPressX,
      longPressY: longPressY,
    );
  }
}
