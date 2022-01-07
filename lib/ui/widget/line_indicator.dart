import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/util/num_util/num_util.dart';

class _PlacePainter {
  Decoration decoration;
  BoxPainter painter;
  double start, end;
  bool placeUp;

  _PlacePainter({
    required this.decoration,
    required this.painter,
    required this.start,
    required this.end,
    required this.placeUp,
  });
}

class LinePlace {
  double start, end;
  Decoration? decoration;
  Color? color;
  bool placeUp;

  LinePlace({
    required this.start,
    required this.end,
    this.decoration,
    this.color,
    this.placeUp = true,
  });
}

/// 線條指示器, 如同 TabBar 底下的 Indicator
/// 但有時會單獨需要此類功能, 因此獨立製作
class LineIndicator extends StatefulWidget {
  /// 方向
  final Axis direction;

  /// 線的粗細, 沒帶入則占滿
  final double? size;

  /// 線最大長度
  /// 依照 [direction] 不同所指不同
  /// [Axis.horizontal] => 線條最大寬度
  /// [Axis.vertical] => 線條最大高度
  final double? maxLength;

  /// 線的邊距
  /// 依照 [direction] 不同所指不同
  /// [Axis.horizontal] => 線條橫向邊距
  /// [Axis.vertical] => 線條最大高度
  final EdgeInsetsGeometry? padding;

  /// 此參數優先於 color
  final Decoration? decoration;

  /// 若線條空間沒填滿
  /// 則需要設置對齊位置
  final Alignment alignment;

  /// 線條顏色
  final Color? color;

  /// 線條開始百分比位置, 0 < value < 1
  final double start;

  /// 線條結尾百分比位置, 0 < value < 1
  final double end;

  /// 插值器
  final Curve curve;

  /// 動畫時間
  final Duration duration;

  /// 從無至有顯示是否使用動畫
  final bool appearAnimation;

  /// 是否啟用動畫
  final bool animation;

  /// 線條佔位
  final List<LinePlace>? places;

  const LineIndicator({Key? key,
    required this.start,
    required this.end,
    this.color,
    this.decoration,
    this.direction = Axis.horizontal,
    this.alignment = Alignment.center,
    this.size,
    this.maxLength,
    this.padding,
    this.curve = Curves.easeInOutSine,
    this.duration = const Duration(milliseconds: 300),
    this.places,
    this.appearAnimation = true,
    this.animation = true,
  }) : assert(color != null || decoration != null), super(key: key);

  @override
  _LineIndicatorState createState() => _LineIndicatorState();
}

class _LineIndicatorState extends State<LineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Tween<double>? startTween;
  Tween<double>? endTween;

  Animation<double>? startAnim;
  Animation<double>? endAnim;

  double currentStart = 0;
  double currentEnd = 0;

  BoxPainter? painter;

  List<_PlacePainter> placePainter = [];

  Decoration? currentDecoration;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    syncShow(widget);
    _controller.addListener(_handleAnimValueUpdate);
    super.initState();
  }

  void _handleAnimValueUpdate() {
    currentStart = startAnim!.value;
    currentEnd = endAnim!.value;
    setState(() {});
  }

  void releaseAllPlacePainter() {
    for (var element in placePainter) {
      element.painter.dispose();
    }
    placePainter.clear();
  }

  @override
  void didUpdateWidget(LineIndicator oldWidget) {
    _controller.duration = widget.duration;
    syncShow(widget);
    super.didUpdateWidget(oldWidget);
  }

  void syncShow(LineIndicator widget) {
    var newDecoration = widget.decoration ?? BoxDecoration(color: widget.color);

    if (currentDecoration != null && currentDecoration != newDecoration) {
      painter?.dispose();
      painter = null;
    }

    currentDecoration = newDecoration;
    painter ??= currentDecoration!.createBoxPainter(() {
      print('需要重繪');
      setState(() {});
    });

    // 同步 widget.places 與 placePainter 的數量
    void _syncPlacePainter() {
      var places = widget.places ?? [];
      if (places.isEmpty) {
        releaseAllPlacePainter();
        return;
      }

      for (var i = 0; i < places.length; i++) {
        var newPlace = widget.places![i];
        var placeDecoration =
            newPlace.decoration ?? BoxDecoration(color: newPlace.color);
        if (placePainter.length > i) {
          var painterPair = placePainter[i];
          if (painterPair.decoration != placeDecoration) {
            painterPair.painter.dispose();
            painterPair.decoration = placeDecoration;
            painterPair.painter = painterPair.decoration.createBoxPainter(() {
              setState(() {});
            });
          }

          painterPair.start = newPlace.start;
          painterPair.end = newPlace.end;
          painterPair.placeUp = newPlace.placeUp;
        } else {
          var painter = _PlacePainter(
            decoration: placeDecoration,
            painter: placeDecoration.createBoxPainter(() {
              setState(() {});
            }),
            start: newPlace.start,
            end: newPlace.end,
            placeUp: newPlace.placeUp,
          );
          placePainter.add(painter);
        }
      }

      if (placePainter.length > places.length) {
        placePainter.removeLast().painter.dispose();
      }
    }

    _syncPlacePainter();

    if (currentStart == widget.start && currentEnd == widget.end) {
      return;
    }

    if (!widget.appearAnimation) {
      var isStartAppear = currentStart == 0 || (currentStart == currentEnd);
      var isEndAppear = currentEnd == 0 || (currentStart == currentEnd);

      if (isStartAppear && isEndAppear) {
        currentStart = widget.start;
        currentEnd = widget.end;
        return;
      }
    }

    if (!widget.animation) {
      currentStart = widget.start;
      currentEnd = widget.end;
      return;
    }

    if (startTween != null) {
      startTween!.begin = currentStart;
      startTween!.end = widget.start;
    } else {
      double startPoint;
      if (currentStart == 0 && currentEnd == 0) {
        startPoint = (widget.start + widget.end) / 2;
      } else {
        startPoint = currentStart;
      }
      startTween = Tween(begin: startPoint, end: widget.start);
      startAnim = startTween!.animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
    }

    if (endTween != null) {
      endTween!.begin = currentEnd;
      endTween!.end = widget.end;
    } else {
      double endPoint;
      if (currentStart == 0 && currentEnd == 0) {
        endPoint = (widget.start + widget.end) / 2;
      } else {
        endPoint = currentEnd;
      }
      endTween = Tween(begin: endPoint, end: widget.end);
      endAnim = endTween!.animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
    }

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.direction == Axis.vertical ? widget.size : null,
      height: widget.direction == Axis.horizontal ? widget.size : null,
      child: CustomPaint(
        painter: _LinePainter(
          start: currentStart,
          end: currentEnd,
          lineSize: widget.size,
          maxLength: widget.maxLength,
          padding: widget.padding ?? EdgeInsets.zero,
          direction: widget.direction,
          alignment: widget.alignment,
          painter: painter!,
          placePainters: placePainter,
        ),
        child: Container(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimValueUpdate);
    _controller.dispose();

    painter?.dispose();

    releaseAllPlacePainter();

    super.dispose();
  }
}

class _LinePainter extends CustomPainter {
  /// 元件大小, 整個粒子運動空間
  final double start, end;

  double? lineSize;
  final Axis direction;
  final double? maxLength;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  BoxPainter painter;

  List<_PlacePainter> placePainters;

  _LinePainter({
    required this.start,
    required this.end,
    required this.padding,
    required this.direction,
    required this.alignment,
    required this.painter,
    required this.placePainters,
    this.lineSize,
    this.maxLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var bgPlace = placePainters.where((element) => !element.placeUp).toList();
    var fgPlace = placePainters.where((element) => element.placeUp).toList();

    // print('背景: ${bgPlace.length}, 前景: ${fgPlace.length}');

    switch (direction) {
      case Axis.horizontal:
        lineSize ??= size.height;
        for (var element in bgPlace) {
          _paintHorizontal(
              canvas, size, element.painter, element.start, element.end);
        }
        _paintHorizontal(canvas, size, painter, start, end);
        for (var element in fgPlace) {
          _paintHorizontal(
              canvas, size, element.painter, element.start, element.end);
        }
        break;
      case Axis.vertical:
        lineSize ??= size.width;
        for (var element in bgPlace) {
          _paintVertical(
              canvas, size, element.painter, element.start, element.end);
        }
        _paintVertical(canvas, size, painter, start, end);
        for (var element in fgPlace) {
          _paintVertical(
              canvas, size, element.painter, element.start, element.end);
        }
        break;
    }
  }

  void _paintVertical(
      Canvas canvas, Size size, BoxPainter painter, double start, double end) {
    var startPos = size.height * start;
    var endPos = size.height * end;

    double startX = 0;
    var lineWidth = min(lineSize ?? double.infinity, size.width);

    if (padding is EdgeInsets) {
      startPos += (padding as EdgeInsets).top;
      endPos -= (padding as EdgeInsets).bottom;

      startX = (padding as EdgeInsets).left;
      lineWidth = lineWidth -
          ((padding as EdgeInsets).left + (padding as EdgeInsets).right);
    } else {
      startPos += padding.vertical / 2;
      endPos -= padding.vertical / 2;
      startX = padding.horizontal / 2;
      lineWidth = lineWidth - padding.horizontal;
    }

    if (startPos >= endPos) {
      return;
    }

    var length = endPos - startPos;

    if (maxLength != null && maxLength! < length) {
      var halfLength = NumUtil.divide(maxLength!, 2);

      var minPos = startPos + halfLength;
      var maxPos = endPos - halfLength;
      var rect = Rect.fromLTRB(0, minPos, size.width, maxPos);
      var startOffset = alignment.withinRect(rect);

      startPos = startOffset.dy - halfLength;
      endPos = startPos + maxLength!;
    }

    painter.paint(
      canvas,
      Offset(startX, startPos),
      ImageConfiguration(
        size: Size(lineWidth, endPos - startPos),
      ),
    );
  }

  void _paintHorizontal(
      Canvas canvas, Size size, BoxPainter painter, double start, double end) {
    var startPos = size.width * start;
    var endPos = size.width * end;

    double startY = 0;
    var lineWidth = min(lineSize ?? double.infinity, size.height);

    if (padding is EdgeInsets) {
      startPos += (padding as EdgeInsets).left;
      endPos -= (padding as EdgeInsets).right;
      startY = (padding as EdgeInsets).top;
      lineWidth = lineWidth -
          ((padding as EdgeInsets).top + (padding as EdgeInsets).bottom);
    } else {
      startPos += padding.horizontal / 2;
      endPos -= padding.horizontal / 2;
      startY = padding.vertical / 2;
      lineWidth = lineWidth - padding.vertical;
    }

    if (startPos >= endPos) {
      return;
    }

    var length = endPos - startPos;

    if (maxLength != null && maxLength! < length) {
      var halfLength = NumUtil.divide(maxLength!, 2);

      var minPos = startPos + halfLength;
      var maxPos = endPos - halfLength;
      var rect = Rect.fromLTRB(minPos, 0, maxPos, size.height);
      var startOffset = alignment.withinRect(rect);

      startPos = startOffset.dx - halfLength;
      endPos = startPos + maxLength!;
    }

    painter.paint(
      canvas,
      Offset(startPos, startY),
      ImageConfiguration(
        size: Size(endPos - startPos, lineWidth),
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is _LinePainter) {
      return painter != oldDelegate.painter ||
          start != oldDelegate.start ||
          end != oldDelegate.end;
    }
    return false;
  }
}
