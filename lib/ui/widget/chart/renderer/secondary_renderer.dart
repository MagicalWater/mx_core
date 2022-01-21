import 'package:flutter/material.dart';

import '../entity/macd_entity.dart';
import '../k_chart.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  double mMACDWidth = ChartStyle.macdWidth;
  SecondaryState state;
  SubChartStyle subChartStyle;

  KDJStyle get kdjStyle => subChartStyle.kdj;

  MACDStyle get macdStyle => subChartStyle.macd;

  RSIStyle get rsiStyle => subChartStyle.rsi;

  WRStyle get wrStyle => subChartStyle.wr;

  SecondaryRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    double scaleX,
    this.subChartStyle,
    MainChartStyle mainChartStyle,
  ) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          scaleX: scaleX,
          style: mainChartStyle,
        );

  @override
  void drawChart(
    MACDEntity lastPoint,
    MACDEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    switch (state) {
      case SecondaryState.macd:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.kdj:
        final oriWidth = chartPaint.strokeWidth;
        chartPaint.strokeWidth = 1;
        if (lastPoint.k != 0) {
          drawLine(
              lastPoint.k, curPoint.k, canvas, lastX, curX, kdjStyle.kColor);
        }
        if (lastPoint.d != 0) {
          drawLine(
              lastPoint.d, curPoint.d, canvas, lastX, curX, kdjStyle.dColor);
        }
        if (lastPoint.j != 0) {
          drawLine(
              lastPoint.j, curPoint.j, canvas, lastX, curX, kdjStyle.jColor);
        }
        chartPaint.strokeWidth = oriWidth;
        break;
      case SecondaryState.rsi:
        final oriWidth = chartPaint.strokeWidth;
        chartPaint.strokeWidth = 1;
        if (lastPoint.rsi != 0) {
          drawLine(
              lastPoint.rsi, curPoint.rsi, canvas, lastX, curX, rsiStyle.color);
        }
        chartPaint.strokeWidth = oriWidth;
        break;
      case SecondaryState.wr:
        final oriWidth = chartPaint.strokeWidth;
        chartPaint.strokeWidth = 1;
        if (lastPoint.r != 0) {
          drawLine(lastPoint.r, curPoint.r, canvas, lastX, curX, wrStyle.color);
        }
        chartPaint.strokeWidth = oriWidth;
        break;
      default:
        break;
    }
  }

  void drawMACD(
    MACDEntity curPoint,
    Canvas canvas,
    double curX,
    MACDEntity lastPoint,
    double lastX,
  ) {
    double macdY = getY(curPoint.macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd > 0) {
      if (curPoint.macd >= lastPoint.macd) {
        chartPaint.color = macdStyle.sellUpColor;
      } else {
        chartPaint.color = macdStyle.sellDownColor;
      }

      canvas.drawRect(
        Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
        chartPaint,
      );
    } else {
      if (curPoint.macd < lastPoint.macd) {
        chartPaint.color = macdStyle.buyUpColor;
      } else {
        chartPaint.color = macdStyle.buyDownColor;
      }

      canvas.drawRect(
        Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
        chartPaint,
      );
    }
    final oriWidth = chartPaint.strokeWidth;
    chartPaint.strokeWidth = 1;
    if (lastPoint.dif != 0) {
      drawLine(
          lastPoint.dif, curPoint.dif, canvas, lastX, curX, macdStyle.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(
          lastPoint.dea, curPoint.dea, canvas, lastX, curX, macdStyle.deaColor);
    }
    chartPaint.strokeWidth = oriWidth;
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan> children;
    switch (state) {
      case SecondaryState.macd:
        children = [
          TextSpan(
              text: "MACD(12,26,9)    ",
              style: getTextStyle(macdStyle.textColor1)),
          if (data.macd != 0)
            TextSpan(
                text: "MACD:${format(data.macd)}    ",
                style: getTextStyle(macdStyle.textColor2)),
          if (data.dif != 0)
            TextSpan(
                text: "DIF:${format(data.dif)}    ",
                style: getTextStyle(macdStyle.difColor)),
          if (data.dea != 0)
            TextSpan(
                text: "DEA:${format(data.dea)}    ",
                style: getTextStyle(macdStyle.deaColor)),
        ];
        break;
      case SecondaryState.kdj:
        children = [
          TextSpan(
              text: "KDJ(14,1,3)    ", style: getTextStyle(kdjStyle.textColor)),
          if (data.macd != 0)
            TextSpan(
                text: "K:${format(data.k)}    ",
                style: getTextStyle(kdjStyle.kColor)),
          if (data.dif != 0)
            TextSpan(
                text: "D:${format(data.d)}    ",
                style: getTextStyle(kdjStyle.dColor)),
          if (data.dea != 0)
            TextSpan(
                text: "J:${format(data.j)}    ",
                style: getTextStyle(kdjStyle.jColor)),
        ];
        break;
      case SecondaryState.rsi:
        children = [
          TextSpan(
              text: "RSI(14):${format(data.rsi)}    ",
              style: getTextStyle(rsiStyle.color)),
        ];
        break;
      case SecondaryState.wr:
        children = [
          TextSpan(
              text: "WR(14):${format(data.r)}    ",
              style: getTextStyle(wrStyle.color)),
        ];
        break;
      case SecondaryState.none:
        return;
    }
    TextPainter tp = TextPainter(
      text: TextSpan(children: children),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: format(maxValue), style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: format(minValue), style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
