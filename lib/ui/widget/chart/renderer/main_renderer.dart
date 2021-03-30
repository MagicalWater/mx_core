import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart.dart' show MainState;
import '../k_chart.dart';
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  MainState state;
  bool isLine;

  /// 繪製圖形的內容邊距
  double _contentPadding = 0;

  MAStyle get maStyle => style.maStyle;

  BOLLStyle get bollStyle => style.bollStyle;

  List<MALine> maLine;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    this.isLine,
    double scaleX,
    MainChartStyle style,
    this.maLine,
  ) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          scaleX: scaleX,
          style: style,
        ) {
    var diff = maxValue - minValue; //计算差
    var newScaleY = (chartRect.height - _contentPadding) / diff; //内容区域高度/差=新的比例
    var newDiff = chartRect.height / newScaleY; //高/新比例=新的差
    var value = (newDiff - diff) / 2; //新差-差/2=y轴需要扩大的值
    if (newDiff > diff) {
      this.scaleY = newScaleY;
      this.maxValue += value;
      this.minValue -= value;
    }
    // print('初始化最高: ${this.maxValue}');
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan span;
    if (state == MainState.MA) {
      span = TextSpan(
        children: [
          if (maLine.contains(MALine.ma5) && data.MA5Price != 0)
            TextSpan(
                text: "MA5:${format(data.MA5Price)}    ",
                style: getTextStyle(maStyle.ma5Color)),
          if (maLine.contains(MALine.ma10) && data.MA10Price != 0)
            TextSpan(
                text: "MA10:${format(data.MA10Price)}    ",
                style: getTextStyle(maStyle.ma10Color)),
          if (maLine.contains(MALine.ma20) && data.MA20Price != 0)
            TextSpan(
                text: "MA20:${format(data.MA20Price)}    ",
                style: getTextStyle(maStyle.ma20Color)),
          if (maLine.contains(MALine.ma30) && data.MA30Price != 0)
            TextSpan(
                text: "MA30:${format(data.MA30Price)}    ",
                style: getTextStyle(maStyle.ma30Color)),
        ],
      );
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          if (data.mb != 0)
            TextSpan(
                text: "BOLL:${format(data.mb)}    ",
                style: getTextStyle(bollStyle.color)),
          if (data.up != 0)
            TextSpan(
                text: "UP:${format(data.up)}    ",
                style: getTextStyle(bollStyle.upColor)),
          if (data.dn != 0)
            TextSpan(
                text: "LB:${format(data.dn)}    ",
                style: getTextStyle(bollStyle.lbColor)),
        ],
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (isLine != true) drawCandle(curPoint, canvas, curX);
    if (isLine == true) {
      draLine(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else if (state == MainState.MA) {
      drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
    } else if (state == MainState.BOLL) {
      drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
    }
  }

  Shader mLineFillShader;
  Path mLinePath, mLineFillPath;
  final double mLineStrokeWidth = 1.0;
  final Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  draLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
    mLinePath ??= Path();
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath.moveTo(lastX, getY(lastPrice));
    mLinePath.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: style.timelineShadowColor,
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath.lineTo(lastX, getY(lastPrice));
    mLineFillPath.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath.close();

    canvas.drawPath(mLineFillPath, mLineFillPaint);
    mLineFillPath.reset();

    canvas.drawPath(
      mLinePath,
      mLinePaint
        ..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.3, 1.0)
        ..color = style.timelineColor,
    );
    mLinePath.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    if (maLine.contains(MALine.ma5) && lastPoint.MA5Price != 0) {
      drawLine(lastPoint.MA5Price, curPoint.MA5Price, canvas, lastX, curX,
          maStyle.ma5Color);
    }
    if (maLine.contains(MALine.ma10) && lastPoint.MA10Price != 0) {
      drawLine(lastPoint.MA10Price, curPoint.MA10Price, canvas, lastX, curX,
          maStyle.ma10Color);
    }
    if (maLine.contains(MALine.ma20) && lastPoint.MA20Price != 0) {
      drawLine(lastPoint.MA20Price, curPoint.MA20Price, canvas, lastX, curX,
          maStyle.ma20Color);
    }
    if (maLine.contains(MALine.ma30) && lastPoint.MA30Price != 0) {
      drawLine(lastPoint.MA30Price, curPoint.MA30Price, canvas, lastX, curX,
          maStyle.ma30Color);
    }
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(
          lastPoint.up, curPoint.up, canvas, lastX, curX, maStyle.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(
          lastPoint.mb, curPoint.mb, canvas, lastX, curX, maStyle.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(
          lastPoint.dn, curPoint.dn, canvas, lastX, curX, maStyle.ma30Color);
    }
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;

    // print('最高y = $high');

    //防止线太细，强制最细1px
    if ((open - close).abs() < 1) {
      if (open > close) {
        open += 0.5;
        close -= 0.5;
      } else {
        open -= 0.5;
        close += 0.5;
      }
    }
    if (open > close) {
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint..color = style.candleStrokeColor,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        chartPaint..color = style.upColor,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR / 2, high, curX + lineR, low),
        chartPaint..color = style.candleStrokeColor,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - r, open, curX + r, close),
        chartPaint..color = style.downColor,
      );
    }
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double position = 0;
      if (i == 0) {
        position = (gridRows - i) * rowSpace - _contentPadding / 2;
      } else if (i == gridRows) {
        position = (gridRows - i) * rowSpace + _contentPadding / 2;
      } else {
        position = (gridRows - i) * rowSpace;
      }
      var value = position / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      double y;
      // if (i == 0 || i == gridRows) {
      //   y = getY(value) - tp.height / 2;
      // } else {
        y = getY(value) - tp.height;
      // }
      tp.paint(canvas, Offset(chartRect.width - tp.width, y));
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    // print('繪製隔線最高: $topPadding, max: $maxValue');
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i + topPadding),
        Offset(chartRect.width, rowSpace * i + topPadding),
        gridPaint,
      );
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, topPadding / 3),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }
}
