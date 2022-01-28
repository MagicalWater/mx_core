import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/chart_state/main_chart_state.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/k_line_data/k_line_data.dart';

import 'main_chart_render_value_mixin.dart';

mixin MainChartRenderPaintMixin on MainChartValueMixin {
  /// 繪製折線圖
  void paintLineChart(Canvas canvas, Rect rect) {
    linePaint
      ..strokeWidth = sizes.lineWidth
      ..color = colors.timeLine;

    final linePath =
        _getDisplayLinePath(dataViewer.datas.map((e) => e.close).toList());

    // 繪製漸變渲染
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: colors.timeLineShadow,
    ).createShader(rect);
    lineShadowPaint.shader = shader;

    final fillPath = Path.from(linePath);
    final bounds = fillPath.getBounds();
    fillPath.lineTo(bounds.right, rect.bottom);
    fillPath.lineTo(bounds.left, rect.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, lineShadowPaint);
    canvas.drawPath(linePath, linePaint);
  }

  /// 繪製ma線
  void paintMaChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final maData = dataViewer.datas.map((e) => e.indciatorData.ma?.ma);
    final periods = dataViewer.maPeriods;

    for (final element in periods) {
      final maList = maData.map((e) => e?[element]).toList();
      final linePath = _getDisplayLinePath(maList, curve: false);
      linePaint.color = colors.maLine[element]!;
      canvas.drawPath(linePath, linePaint);
    }
  }

  /// 繪製boll線
  void paintBollChart(Canvas canvas, Rect rect) {
    linePaint.strokeWidth = sizes.lineWidth;

    final bollData = dataViewer.datas.map((e) => e.indciatorData.boll);

    // 繪mb線
    final mbList = bollData.map((e) => e?.mb).toList();
    final mbPath = _getDisplayLinePath(mbList, curve: false);
    linePaint.color = colors.bollMb;
    canvas.drawPath(mbPath, linePaint);

    // 繪up線
    final upList = bollData.map((e) => e?.up).toList();
    final upPath = _getDisplayLinePath(upList, curve: false);
    linePaint.color = colors.bollUp;
    canvas.drawPath(upPath, linePaint);

    // 繪dn線
    final dnList = bollData.map((e) => e?.dn).toList();
    final dnPath = _getDisplayLinePath(dnList, curve: false);
    linePaint.color = colors.bollDn;
    canvas.drawPath(dnPath, linePaint);
  }

  /// 取得顯示在螢幕上的路線Path
  /// [curve] - 是否使用曲線
  Path _getDisplayLinePath(List<double?> values, {bool curve = true}) {
    final linePath = Path();

    double? preValue;
    double? preX, preY;

    final startIndex = max(0, dataViewer.startDataIndex - 1);
    final endIndex = min(
      values.length - 1,
      dataViewer.endDataIndex + 1,
    );

    // 畫折線
    for (int i = startIndex; i <= endIndex; i++) {
      final value = values[i];
      if (value == null) {
        continue;
      }
      final x = dataViewer.dataIndexToRealX(i);
      final y = valueToRealY(value);

      if (preValue == null) {
        linePath.moveTo(x, y);
      } else {
        final centerX = (preX! + x) / 2;
        if (curve) {
          linePath.cubicTo(centerX, preY!, centerX, y, x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }

      preX = x;
      preY = y;
      preValue = value;
    }

    return linePath;
  }

  /// 畫蠟燭總線圖
  void paintCandleChart(Canvas canvas, Rect rect) {
    for (int i = dataViewer.startDataIndex; i <= dataViewer.endDataIndex; i++) {
      final data = dataViewer.datas[i];
      final x = dataViewer.dataIndexToRealX(i);
      _paintCandle(canvas, x, data, i);
    }
  }

  /// 畫蠟燭
  /// [x] - 此蠟燭的正中央x軸位置
  /// [data] - 要繪製成蠟燭圖的資料
  /// [index] - 資料的index
  void _paintCandle(Canvas canvas, double x, KLineData data, int index) {
    final highY = valueToRealY(data.high);
    final lowY = valueToRealY(data.low);
    var openY = valueToRealY(data.open);
    var closeY = valueToRealY(data.close);

    // 是否漲
    final isUp = data.close > data.open;

    // 取得蠟燭圖的顏色
    final candleColor = isUp ? colors.upColor : colors.downColor;

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
    final candleRadius = candleWidthScaled / 2;
    final lineRadius = sizes.candleLineWidth / 2;

    chartPaint.color = candleColor;

    final candleRect = Rect.fromLTRB(
      x - candleRadius,
      isUp ? closeY : openY,
      x + candleRadius,
      isUp ? openY : closeY,
    );

    // 畫四方型
    canvas.drawRect(candleRect, chartPaint);

    final lineRect = Rect.fromLTRB(x - lineRadius, highY, x + lineRadius, lowY);
    // 畫中間線
    canvas.drawRect(lineRect, chartPaint);

    // final tp = TextPainter(
    //     text: TextSpan(
    //       text: '$index',
    //       style: const TextStyle(
    //         color: Colors.black,
    //         fontSize: 12,
    //       ),
    //     ),
    //     textDirection: TextDirection.ltr);
    // tp.layout();
    // tp.paint(canvas, candleRect.center);
  }

  /// 繪製最右側顯示的實時線
  /// [startX] - 實時線的起始x軸位置
  /// [valuePainter] - 實時數值繪製
  /// [y] - 實時線的y軸位置
  void paintRealTimeLineAtRight({
    required Canvas canvas,
    required Rect rect,
    required double startX,
    required TextPainter valuePainter,
    required double y,
  }) {
    // 虛線總寬度
    final dashTotalWidth = sizes.realTimeDashWidth + sizes.realTimeDashSpace;

    // 虛線起始點x
    var dottedLineX = startX;

    // 繪製實時虛線
    realTimeLinePaint.color = colors.realTimeRightLine;
    while (dottedLineX < rect.width) {
      canvas.drawLine(
        Offset(dottedLineX, y),
        Offset(dottedLineX + sizes.realTimeDashWidth, y),
        realTimeLinePaint,
      );
      dottedLineX += dashTotalWidth;
    }

    // 檢查是否為折線圖, 弱勢哲需要繪製實時價最右側原點
    // TODO: 需要加入圓點動畫
    if (dataViewer.mainState.contains(MainChartState.lineIndex)) {
      // startAnimation();
      final flashColors = List.of(colors.realTimeRightPointFlash);
      // flashColors[0] = flashColors[0].withOpacity(opacity);
      final pointGradient = RadialGradient(colors: flashColors);
      realTimeLinePaint.shader = pointGradient.createShader(
        Rect.fromCircle(center: Offset(startX, y), radius: 10.0),
      );
      canvas.drawCircle(Offset(startX, y), 10.0, realTimeLinePaint);
      realTimeLinePaint.shader = null;
      realTimeLinePaint.color = Colors.white;
      canvas.drawCircle(Offset(startX, y), 2, realTimeLinePaint);
    } else {
      // stopAnimation(); //停止一闪闪
    }

    // 畫最右側的實時數值
    final left = rect.width - valuePainter.width;
    final top = y - 0.5 - valuePainter.height / 2;
    canvas.drawRect(
      Rect.fromLTWH(left, top, valuePainter.width, valuePainter.height),
      realTimeLinePaint
        ..color = colors.realTimeRightValueBg
        ..style = PaintingStyle.fill,
    );
    valuePainter.paint(canvas, Offset(left, top));
  }

  /// 繪製跨越整個畫布的實時線
  /// [startX] - 實時線的起始x軸位置
  /// [valuePainter] - 實時數值繪製
  /// [y] - 實時線的y軸位置
  void paintRealTimeLineAtGlobal({
    required Canvas canvas,
    required Rect rect,
    required TextPainter valuePainter,
    required double y,
  }) {
    // 虛線總寬度
    final dashTotalWidth = sizes.realTimeDashWidth + sizes.realTimeDashSpace;

    // 檢查實時數值是否超過最高/最低限
    if (y > maxY) {
      y = maxY;
    } else if (y < minY) {
      y = minY;
    }

    // 繪製實時虛線
    var dottedLineX = 0.0;
    realTimeLinePaint.color = colors.realTimeLine;
    while (dottedLineX < rect.width) {
      canvas.drawLine(
        Offset(dottedLineX, y),
        Offset(dottedLineX + sizes.realTimeDashWidth, y),
        realTimeLinePaint..color,
      );
      dottedLineX += dashTotalWidth;
    }

    // 繪製標籤tag
    // x軸位置將會處於最後一個豎直隔線上

    // 三角箭頭size
    final triangleSize = sizes.realTimeTagTriangle;

    // 距離邊框的空隙 / 文字與三角箭頭中間的空隙
    final verticalPadding = sizes.realTimeTagVerticalPadding,
        horizontalPadding = sizes.realTimeTagHorizontalPadding,
        textSpace = 5;

    // 一個行的寬度
    final columnSpace =
        rect.width / dataViewer.chartUiStyle.sizeSetting.gridColumns;

    final left = rect.width -
        columnSpace -
        (valuePainter.width / 2) -
        (horizontalPadding * 2);
    final top = y - valuePainter.height / 2 - verticalPadding;

    // 標籤tag內容寬度
    final tagWidth = horizontalPadding * 2 +
        valuePainter.width +
        textSpace +
        triangleSize.width;

    // 標籤內容高度
    final tagHeight = verticalPadding * 2 + valuePainter.height;

    // 標籤圓弧半徑
    final tagArcRadius = tagHeight / 2;

    final tagRect = RRect.fromLTRBR(
      left,
      top,
      left + tagWidth,
      top + tagHeight,
      Radius.circular(tagArcRadius),
    );

    // 繪製外框/背景
    canvas.drawRRect(
      tagRect,
      realTimeLinePaint
        ..color = colors.realTimeValueBg
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      tagRect,
      realTimeLinePaint
        ..color = colors.realTimeValueBorder
        ..style = PaintingStyle.stroke,
    );

    // 繪製實時數值
    final valueOffset = Offset(
      left + horizontalPadding,
      y - valuePainter.height / 2,
    );
    valuePainter.paint(canvas, valueOffset);

    // 畫三角標示
    final path = Path();
    final dx = valuePainter.width + valueOffset.dx + textSpace;
    final dy = y - triangleSize.height / 2;
    path.moveTo(dx, dy);
    path.lineTo(dx + triangleSize.width, y);
    path.lineTo(dx, dy + triangleSize.height);
    path.close();
    canvas.drawPath(
      path,
      realTimeLinePaint
        ..color = colors.realTimeTriangleTag
        ..style = PaintingStyle.fill,
    );
  }

  /// 繪製長按橫線以及交叉點
  void paintLongPressHorizontalPoint({
    required Canvas canvas,
    required Rect rect,
    required double longPressX,
    required double longPressY,
  }) {
    final uiStyle = dataViewer.chartUiStyle;

    // 繪製橫線
    canvas.drawLine(
      Offset(rect.left, longPressY),
      Offset(rect.right, longPressY),
      crossHorizontalPaint
        ..style = PaintingStyle.stroke
        ..color = uiStyle.colorSetting.longPressHorizontallLine
        ..color = dataViewer.chartUiStyle.colorSetting.longPressHorizontallLine
        ..strokeWidth = uiStyle.sizeSetting.longPressHorizontalLineHeight,
    );

    final pointSize = 2.0 * dataViewer.scaleX;

    // 繪製長按交叉點
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(longPressX, longPressY),
        height: pointSize,
        width: pointSize,
      ),
      crossHorizontalPaint
        ..style = PaintingStyle.fill
        ..strokeWidth = 1
        ..color = dataViewer.chartUiStyle.colorSetting.longPressHorizontallLine,
    );
  }

  /// 繪製長按數值
  void paintLongPressValue({
    required Canvas canvas,
    required Rect rect,
    required double longPressX,
    required double longPressY,
  }) {
    final uiStyle = dataViewer.chartUiStyle;

    // 取得y對應的value
    final value = realYToValue(longPressY);

    final valuePainter = TextPainter(
      text: TextSpan(
        text: dataViewer.formatPrice(value),
        style: TextStyle(
          color: uiStyle.colorSetting.longPressValue,
          fontSize: uiStyle.sizeSetting.longPressValue,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();

    final valueHeight = valuePainter.height;
    final valueWidth = valuePainter.width;

    final horizontalPadding =
        uiStyle.sizeSetting.longPressValueBorderHorizontalPadding;
    final verticalPadding =
        uiStyle.sizeSetting.longPressValueBorderVerticalPadding;

    final totalWidth = horizontalPadding * 2 + valueWidth;
    final totalHeight = verticalPadding * 2 + valueHeight;

    final atLeft = longPressX < rect.width / 2;

    // 箭頭寬度
    const arrowWidth = 10.0;

    final path = Path();
    Offset valuePaintOffset;

    if (atLeft) {
      const x = 5.0;

      // 將數值繪製於右邊
      path.moveTo(x, longPressY - totalHeight / 2);
      path.lineTo(x, longPressY + totalHeight / 2);
      path.lineTo(x + totalWidth, longPressY + totalHeight / 2);
      path.lineTo(x + totalWidth + arrowWidth, longPressY);
      path.lineTo(x + totalWidth, longPressY - totalHeight / 2);
      path.close();

      valuePaintOffset = Offset(
        x + horizontalPadding,
        longPressY - valueHeight / 2,
      );
    } else {
      final x = rect.width - 5;
      // 將數值繪製於右邊
      path.moveTo(x, longPressY - totalHeight / 2);
      path.lineTo(x, longPressY + totalHeight / 2);
      path.lineTo(x - totalWidth, longPressY + totalHeight / 2);
      path.lineTo(x - totalWidth - arrowWidth, longPressY);
      path.lineTo(x - totalWidth, longPressY - totalHeight / 2);
      path.close();
      valuePaintOffset = Offset(
        x - horizontalPadding - valueWidth,
        longPressY - valueHeight / 2,
      );
    }

    canvas.drawPath(
      path,
      crossHorizontalPaint
        ..style = PaintingStyle.fill
        ..color = uiStyle.colorSetting.longPressValueBg,
    );
    canvas.drawPath(
      path,
      crossHorizontalPaint
        ..style = PaintingStyle.stroke
        ..color = uiStyle.colorSetting.longPressValueBorder,
    );
    valuePainter.paint(canvas, valuePaintOffset);
  }
}