import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart' show NumUtil;
import 'package:mx_core/ui/widget/chart/entity/k_line_entity.dart';

import '../entity/candle_entity.dart';
import '../k_chart.dart';
import 'base_chart_renderer.dart';

class _MinMax {
  final double min;
  final double max;

  final bool isMinDefault;
  final bool isMaxDefault;

  _MinMax({
    required this.min,
    required this.max,
    required this.isMinDefault,
    required this.isMaxDefault,
  });
}

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  double mCandleWidth = ChartStyle.candleWidth;
  double mCandleLineWidth = ChartStyle.candleLineWidth;
  MainState state;
  bool isLine;

  /// 繪製圖形的內容邊距
  final double _contentPadding = 0;

  MAStyle get maStyle => style.maStyle;

  BOLLStyle get bollStyle => style.bollStyle;

  List<MALine> maLine;

  KLineEntity? preEntity;
  KLineEntity? nextEntity;

  List<double> gridPosition = [];

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
    this.preEntity,
    this.nextEntity,
  ) : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          scaleX: scaleX,
          style: style,
        );

  @override
  void translateMinMax() {
    _MinMax _minMax(
      double minDefault,
      double maxDefault, [
      double? v1,
      double? v2,
      double? v3,
      double? v4,
      double? v5,
      double? v6,
      double? v7,
      double? v8,
      double? v9,
      double? v10,
    ]) {
      var nullValues = <double?>[];
      nullValues
        ..add(v1)
        ..add(v2)
        ..add(v3)
        ..add(v4)
        ..add(v5)
        ..add(v6)
        ..add(v7)
        ..add(v8)
        ..add(v9)
        ..add(v10);
      nullValues.removeWhere((element) => element == null);
      var values = nullValues.map((e) => e!).toList();
      if (values.isEmpty) {
        return _MinMax(
          min: minDefault,
          max: maxDefault,
          isMinDefault: true,
          isMaxDefault: true,
        );
      } else {
        var maxV = max(minDefault, values.reduce(max));
        var minV = min(minDefault, values.reduce(min));
        return _MinMax(
          min: minV,
          max: maxV,
          isMinDefault: minV == minDefault,
          isMaxDefault: maxV == maxDefault,
        );
      }
    }

    if (maxValue == minValue) {
      _MinMax minMax;

      // 當最大最小同一時需要預先調整
      switch (state) {
        case MainState.ma:
          minMax = _minMax(
            minValue,
            maxValue,
            preEntity?.ma5Price,
            preEntity?.ma10Price,
            preEntity?.ma20Price,
            preEntity?.ma30Price,
            nextEntity?.ma5Price,
            nextEntity?.ma10Price,
            nextEntity?.ma20Price,
            nextEntity?.ma30Price,
          );
          break;
        case MainState.boll:
          minMax = _minMax(
            minValue,
            maxValue,
            preEntity?.mb,
            preEntity?.dn,
            preEntity?.up,
            nextEntity?.mb,
            nextEntity?.dn,
            nextEntity?.up,
          );
          break;
        case MainState.none:
          minMax = _minMax(
            minValue,
            maxValue,
          );
          break;
      }

      if (!minMax.isMinDefault && !minMax.isMaxDefault) {
        // 都非預設
        var minDiff = NumUtil.subtract(maxValue, minMax.min);
        var maxDiff = NumUtil.subtract(minMax.max, maxValue);

        if (minDiff > maxDiff) {
          // 採用最小
          minValue = minMax.min;
          maxValue = NumUtil.add(maxValue, minDiff);
        } else {
          maxValue = minMax.max;
          minValue = NumUtil.subtract(minValue, maxDiff);
        }
      } else if (!minMax.isMinDefault) {
        // 最大值為預設
        var minDiff = NumUtil.subtract(maxValue, minMax.min);
        minValue = minMax.min;
        maxValue = NumUtil.add(maxValue, minDiff);
      } else if (!minMax.isMaxDefault) {
        // 最小值為預設
        var maxDiff = NumUtil.subtract(minMax.max, maxValue);
        maxValue = minMax.max;
        minValue = NumUtil.subtract(minValue, maxDiff);
      } else {
        minValue -= 0.5;
        maxValue += 0.5;
      }
    }

    var diff = maxValue - minValue; //计算差
    var newScaleY = (chartRect.height - _contentPadding) / diff; //内容区域高度/差=新的比例
    var newDiff = chartRect.height / newScaleY; //高/新比例=新的差
    var value = (newDiff - diff) / 2; //新差-差/2=y轴需要扩大的值
    if (newDiff > diff) {
      scaleY = newScaleY;
      maxValue += value;
      minValue -= value;
    }
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan? span;
    if (state == MainState.ma) {
      span = TextSpan(
        children: [
          if (maLine.contains(MALine.ma5) && data.ma5Price != 0)
            TextSpan(
                text: "MA5:${format(data.ma5Price)}    ",
                style: getTextStyle(maStyle.ma5Color)),
          if (maLine.contains(MALine.ma10) && data.ma10Price != 0)
            TextSpan(
                text: "MA10:${format(data.ma10Price)}    ",
                style: getTextStyle(maStyle.ma10Color)),
          if (maLine.contains(MALine.ma20) && data.ma20Price != 0)
            TextSpan(
                text: "MA20:${format(data.ma20Price)}    ",
                style: getTextStyle(maStyle.ma20Color)),
          if (maLine.contains(MALine.ma30) && data.ma30Price != 0)
            TextSpan(
                text: "MA30:${format(data.ma30Price)}    ",
                style: getTextStyle(maStyle.ma30Color)),
        ],
      );
    } else if (state == MainState.boll) {
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
    } else if (state == MainState.ma) {
      drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
    } else if (state == MainState.boll) {
      drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  final double mLineStrokeWidth = 1.0;
  final Paint mLinePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  void draLine(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    mLinePath ??= Path();
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );

//    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: style.timelineShadowColor,
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint.shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(
      mLinePath!,
      mLinePaint
        ..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.3, 1.0)
        ..color = style.timelineColor,
    );
    mLinePath!.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    final oriWidth = chartPaint.strokeWidth;
    chartPaint.strokeWidth = 1.2;
    if (maLine.contains(MALine.ma5) && lastPoint.ma5Price != 0) {
      drawLine(lastPoint.ma5Price, curPoint.ma5Price, canvas, lastX, curX,
          maStyle.ma5Color);
    }
    if (maLine.contains(MALine.ma10) && lastPoint.ma10Price != 0) {
      drawLine(lastPoint.ma10Price, curPoint.ma10Price, canvas, lastX, curX,
          maStyle.ma10Color);
    }
    if (maLine.contains(MALine.ma20) && lastPoint.ma20Price != 0) {
      drawLine(lastPoint.ma20Price, curPoint.ma20Price, canvas, lastX, curX,
          maStyle.ma20Color);
    }
    if (maLine.contains(MALine.ma30) && lastPoint.ma30Price != 0) {
      drawLine(lastPoint.ma30Price, curPoint.ma30Price, canvas, lastX, curX,
          maStyle.ma30Color);
    }
    chartPaint.strokeWidth = oriWidth;
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    final oriWidth = chartPaint.strokeWidth;
    chartPaint.strokeWidth = 1.2;
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
    chartPaint.strokeWidth = oriWidth;
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
        chartPaint..color = style.upColor,
      );
      canvas.drawRect(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        chartPaint..color = style.upColor,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR / 2, high, curX + lineR, low),
        chartPaint..color = style.downColor,
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
        // 最高
        position = (gridRows - i) * rowSpace - _contentPadding / 2;
      } else if (i == gridRows) {
        // 最低
        position = (gridRows - i) * rowSpace + _contentPadding / 2;
      } else {
        position = (gridRows - i) * rowSpace;
      }
      var value = position / scaleY + minValue;
      TextSpan span = TextSpan(text: format(value), style: textStyle);
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
    gridPosition.clear();
    for (int i = 0; i <= gridRows; i++) {
      var pos = rowSpace * i + topPadding;
      canvas.drawLine(
        Offset(0, pos),
        Offset(chartRect.width, rowSpace * i + topPadding),
        gridPaint,
      );
      gridPosition.add(pos);
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

  /// 針對grid圖表切割線的吸附
  double getGridAdsorption(double y) {
    var absorptionPoint =
        gridPosition.firstWhereOrNull((element) => (y - element).abs() < 4);

    return absorptionPoint ?? y;
  }
}
