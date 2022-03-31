import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/data_viewer.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_render/impl/main_chart/main_chart_render_value_mixin.dart';

import '../../../../k_line_chart.dart';
import '../../main_chart_render.dart';
import 'main_chart_render_paint_mixin.dart';

export 'ui_style/main_chart_ui_style.dart';

class MainChartRenderImpl extends MainChartRender
    with MainChartValueMixin, MainChartRenderPaintMixin {
  /// [pricePositionGetter] - 價格標示y軸位置獲取
  MainChartRenderImpl({
    required DataViewer dataViewer,
    PricePositionGetter? pricePositionGetter,
  }) : super(
          dataViewer: dataViewer,
          pricePositionGetter: pricePositionGetter,
        );

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
    final maData = displayData.indicatorData.ma?.ma;
    final spanTexts = <TextSpan>[];

    // 檢查是否需要顯示ma資訊
    if (isShowMa) {
      final maTextStyle = TextStyle(fontSize: sizes.indexTip);
      final maSpan = dataViewer.maPeriods
          .map((e) {
            final value = maData?[e];
            if (value == null || value == 0) {
              return null;
            }
            return TextSpan(
              text: 'MA$e:${dataViewer.priceFormatter(value)}    ',
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
    final bollData = displayData.indicatorData.boll;
    if (isShowBoll && bollData != null) {
      final bollTextStyle = TextStyle(fontSize: sizes.indexTip);

      final bollSpan = [
        TextSpan(
          text: 'BOLL:${dataViewer.priceFormatter(bollData.mb)}    ',
          style: bollTextStyle.copyWith(color: colors.bollMb),
        ),
        TextSpan(
          text: 'UP:${dataViewer.priceFormatter(bollData.up)}    ',
          style: bollTextStyle.copyWith(color: colors.bollUp),
        ),
        TextSpan(
          text: 'LB:${dataViewer.priceFormatter(bollData.dn)}    ',
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
        text: dataViewer.priceFormatter(value),
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
    if (isShowKLine) {
      paintCandleChart(canvas, rect);

      // 繪製ma線
      if (isShowMa) {
        paintMaChart(canvas, rect);
      }

      // 繪製boll線
      if (isShowBoll) {
        paintBollChart(canvas, rect);
      }
    } else if (isShowLineIndex) {
      // 折線狀態不可再有ma以及boll
      paintLineChart(canvas, rect);
    }
  }

  /// 繪製實時線
  @override
  void paintRealTimeLine(Canvas canvas, Rect rect) {
    // final lastData = dataViewer.datas.last;
    // final realTimeValue = lastData.close;

    // 右側顯示的實時數值
    // final rightValueSpan = TextSpan(
    //   text: dataViewer.priceFormatter(realTimeValue),
    //   style: TextStyle(
    //     fontSize: sizes.realTimeLineValue,
    //     color: colors.realTimeRightValue,
    //   ),
    // );
    // final valuePainter = TextPainter(
    //   text: rightValueSpan,
    //   textDirection: TextDirection.ltr,
    // );
    // valuePainter.layout();

    // 取得實時線的y軸位置
    // 之所以不用final, 是因為當在右側空間不可容納實時數值時
    // 可能會有超出上下限的情況, 此時需要調整至最高/最低
    // var y = valueToRealY(realTimeValue);

    final dataX = dataViewer.dataIndexToRealX(dataViewer.datas.length - 1);

    // 取得右側可以用來顯示的剩餘空間
    double rightRemainingSpace;

    if (isShowLineIndex) {
      // 折線圖
      rightRemainingSpace = rect.width - dataX;
    } else {
      // 蠟燭圖, 需要再加上一半的蠟燭寬度
      rightRemainingSpace = rect.width - (dataX + (dataWidthScaled / 2));
    }

    if (rightRemainingSpace <= 0) {
      rightRemainingSpace = 0;
    }

    pricePositionGetter?.call(
      rightRemainingSpace,
      valueToRealYWithClamp,
    );

    //
    // // if (!isLine) x += mPointWidth / 2;
    //
    // if (valuePainter.width < rightRemainingSpace) {
    //   // 右側空間可容納實時數值
    //
    //   var startX = dataX;
    //   if (isShowKLine) {
    //     startX += candleWidthScaled / 2;
    //   }
    //
    //   // 繪製右側的實時線
    //   paintRealTimeLineAtRight(
    //     canvas: canvas,
    //     rect: rect,
    //     startX: startX,
    //     valuePainter: valuePainter,
    //     y: y,
    //   );
    //
    //   // 將最右側的實時價格位置打出去
    //   pricePosition?.call(Offset(startX, y));
    //
    //   // 全局最新實時價格處於不可見
    //   globalRealTimePriceY?.call(null);
    // } else {
    //   // 右側不可容納實時數值
    //
    //   // y軸不可超過最大最小值
    //   y = y.clamp(minY, maxY);
    //
    //   // 繪製跨越整個畫布的實時線
    //   paintRealTimeLineAtGlobal(
    //     canvas: canvas,
    //     rect: rect,
    //     y: y,
    //   );
    //
    //   // 右側最新實時價格處於不可見位置
    //   rightRealPriceOffset?.call(null);
    //
    //   // 將全局最新實時價格y軸位置打出去
    //   globalRealTimePriceY?.call(y);
    // }
  }

  double valueToRealYWithClamp(double value) {
    var y = valueToRealY(value);
    y = y.clamp(minY, maxY);
    return y;
  }

  /// 繪製最大最小值
  @override
  void paintMaxMinValue(Canvas canvas, Rect rect) {
    if (isShowLineIndex) {
      // 圖表狀態為折線圖時不需顯示
      return;
    } else if (isMinMaxValueEqual) {
      // 最大最小值相同時不需顯示
      return;
    }

    // 圖表最大最小值一樣時不需顯示

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
          ? '── ${dataViewer.priceFormatter(value)}'
          : '${dataViewer.priceFormatter(value)} ──';

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
