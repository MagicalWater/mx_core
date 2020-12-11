import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 有箭頭方向的 container
class ArrowContainer extends SingleChildRenderObjectWidget {
  /// 箭頭尖端偏移
  final double shiftLeafPercent;

  /// 箭頭根部偏移
  final double shiftRootPercent;

  /// 箭頭方向
  final AxisDirection direction;

  /// 箭頭類型
  final ArrowSide arrowSide;

  /// 箭頭根部寬度, 只在 [arrowSide] 為 [ArrowSide.line] 時有效
  final double arrowRootSize;

  /// 箭頭大小, 當等於0時代表無箭頭
  final double arrowSize;

  /// 方形 radius
  final double radius;

  /// 框內顏色
  final Color color;

  /// 框內的漸變
  final Gradient gradient;

  /// 外框顏色
  final Color strokeColor;

  /// 外框漸變
  final Gradient strokeGradient;

  /// 外框size
  final double strokeWidth;

  /// 元件 Size callback
  final void Function(Size size) onSized;

  ArrowContainer({
    Widget child,
    this.shiftLeafPercent = 0,
    this.shiftRootPercent = 0,
    this.direction = AxisDirection.up,
    this.arrowSize = 20,
    this.arrowSide = ArrowSide.bezier,
    this.arrowRootSize = 20,
    this.radius = 10,
    this.color,
    this.strokeWidth = 2.0,
    this.strokeColor,
    this.gradient,
    this.strokeGradient,
    this.onSized,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _ArrowShiftBox(
        shiftLeafPercent: shiftLeafPercent,
        shiftRootPercent: shiftRootPercent,
        direction: direction,
        arrowSize: arrowSize,
        arrowSide: arrowSide,
        arrowRootSize: arrowRootSize,
        radius: radius,
        color: color,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
        gradient: gradient,
        strokeGradient: strokeGradient,
        onSized: onSized,
      );
}

class _ArrowShiftBox extends RenderShiftedBox {
  /// 繪製內容的畫筆
  Paint _fillPaint;

  /// 繪製外框的畫筆
  Paint _strokePaint;

  /// 箭頭尖端偏移
  final double shiftLeafPercent;

  /// 箭頭根部偏移
  final double shiftRootPercent;

  /// 箭頭方向
  final AxisDirection direction;

  /// 箭頭偏移(箭頭的長度)
  final double arrowSize;

  /// 箭頭類型
  final ArrowSide arrowSide;

  /// 箭頭根部寬度, 只在 [arrowSide] 為 [ArrowSide.line] 時有效
  final double arrowRootSize;

  /// 方形 radius
  final double radius;

  /// 箭頭方向是橫向
  bool get isArrowHorizontal =>
      direction == AxisDirection.left || direction == AxisDirection.right;

  /// 子元件的 offset
  Offset get childOffset => (child.parentData as BoxParentData).offset;

  /// 框內顏色
  final Color color;

  /// 框內漸變顏色
  final Gradient gradient;

  /// 外框漸變
  final Gradient strokeGradient;

  /// 外框顏色
  final Color strokeColor;

  /// 外框size
  final double strokeWidth;

  void Function(Size size) onSized;

  /// 因為外框size需要內縮的距離
  double get diffStrokeWidth {
    if (_strokePaint != null) {
      return strokeWidth;
    }
    return 0;
  }

  /// 已經繪製好的 fillPath
  Path fillPath;

  /// 已經繪製好的 strokePath
  Path strokePath;

  /// 當前繪製的 Rect
  Rect currentRect;

  _ArrowShiftBox({
    this.shiftLeafPercent = 0,
    this.shiftRootPercent = 0,
    this.direction = AxisDirection.up,
    this.arrowSize = 20,
    this.arrowSide = ArrowSide.bezier,
    this.arrowRootSize = 20,
    this.radius = 10,
    this.color,
    this.strokeWidth = 2.0,
    this.strokeColor,
    this.gradient,
    this.strokeGradient,
    this.onSized,
  }) : super(null) {
    _fillPaint = Paint()..style = PaintingStyle.fill;

    if (strokeColor != null &&
        strokeColor != Colors.transparent &&
        strokeWidth > 0.0) {
      _strokePaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
    }
  }

  @override
  void performLayout() {
    fillPath = null;
    strokePath = null;

    var minW = constraints.minWidth;
    var maxW = constraints.maxWidth;
    var minH = constraints.minHeight;
    var maxH = constraints.maxHeight;

    // 查看箭頭方向影響到哪些範圍
    if (isArrowHorizontal) {
      maxW -= arrowSize;
    } else {
      maxH -= arrowSize;
    }
    maxW -= diffStrokeWidth * 2;
    maxH -= diffStrokeWidth * 2;

    minW = min(minW, maxW);
    minH = min(minH, maxH);

    var childConstraint = BoxConstraints(
      minWidth: minW,
      maxWidth: maxW,
      minHeight: minH,
      maxHeight: maxH,
    );
    child.layout(childConstraint, parentUsesSize: true);

//    print('childConstraint: $childConstraint, max = $constraints');

    final childParentData = child.parentData as BoxParentData;
    childParentData.offset = Offset(
      direction == AxisDirection.left ? arrowSize : 0,
      direction == AxisDirection.up ? arrowSize : 0,
    ).translate(diffStrokeWidth, diffStrokeWidth);

//    print('childParentData: $childParentData, child = ${child.size}');

    if (isArrowHorizontal) {
      size = Size(
        child.size.width + arrowSize + diffStrokeWidth * 2,
        child.size.height + diffStrokeWidth * 2,
      );
    } else {
      size = Size(
        child.size.width + diffStrokeWidth * 2,
        child.size.height + arrowSize + diffStrokeWidth * 2,
      );
    }

//    size = Size(constraints.maxWidth, constraints.maxHeight);

//    print('size: $size');

    if (onSized != null) {
      onSized(size);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var canvas = context.canvas;

    // 從左上角開始畫 rect
    Rect rect = Rect.fromLTWH(
      offset.dx + childOffset.dx - diffStrokeWidth,
      offset.dy + childOffset.dy - diffStrokeWidth,
      child.size.width + diffStrokeWidth * 2,
      child.size.height + diffStrokeWidth * 2,
    );

    if (rect != currentRect) {
      fillPath = null;
      strokePath = null;
      currentRect = rect;
    }

    if (fillPath == null) {
      if (gradient != null) {
        // 使用漸變
        _fillPaint.shader = gradient.createShader(rect);
      } else {
        // 使用純色
        _fillPaint.color = color ?? Colors.transparent;
      }
      fillPath = _buildPath(rect, 0);
    }

    if (_strokePaint != null) {
      if (strokePath == null) {
        if (strokeGradient != null) {
          _strokePaint.shader = strokeGradient.createShader(rect);
        } else {
          _strokePaint.color = strokeColor ?? Colors.transparent;
        }
        strokePath = _buildPath(rect, diffStrokeWidth);
      }

      // 由於方形內縮後, stroke 貝茲曲線的彎度幅度也內縮
      // 當 strokeWidth 會出現 fill color 凸出的問題
      // 因此先將 canvas 狀態存起來, 根據 strokePath 進行裁減
      canvas.save();
      canvas.clipPath(strokePath);
      canvas.drawPath(fillPath, _fillPaint);
      canvas.restore();
      canvas.clipPath(fillPath);
      canvas.drawPath(strokePath, _strokePaint);
    } else {
      canvas.drawPath(fillPath, _fillPaint);
      canvas.clipPath(fillPath);
    }

    super.paint(context, offset);
  }

  /// 構建箭頭框
  /// [diffWidth] 內縮距離
  Path _buildPath(Rect rect, double diffWidth) {
    Path path = Path();

    if (diffWidth != 0) {
      rect = Rect.fromLTWH(
        rect.left + diffWidth / 2,
        rect.top + diffWidth / 2,
        rect.width - diffWidth,
        rect.height - diffWidth,
      );
    }

    // 從左上角開始畫線
    path.moveTo(rect.left + radius, rect.top);
//    path.addOval(Rect.fromLTWH(rect.left + radius + diffWidth, rect.top, 20, 20));
    // 構建上方line
    _buildUpLine(path, rect);

    // 構建右上角彎曲
    path.quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + radius);
    // 構建右方line
    _buildRightLine(path, rect);
    path.quadraticBezierTo(
        rect.right, rect.bottom, rect.right - radius, rect.bottom);

    // 檢查箭頭是否在下方
    _buildDownLine(path, rect);
    path.quadraticBezierTo(
        rect.left, rect.bottom, rect.left, rect.bottom - radius);

    // 構建左方line
    _buildLeftLine(path, rect);
    path.quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top);
    path.close();

    return path;
  }

  /// 構建方框上方 path
  void _buildUpLine(Path path, Rect rect) {
    // 檢查箭頭是否在上方
    if (direction == AxisDirection.up && arrowSize != 0) {
      // 箭頭對準 [shiftPercent]
      var arrowX = rect.left + (rect.width * shiftLeafPercent);
      var arrowY = rect.top - arrowSize;

      switch (arrowSide) {
        case ArrowSide.bezier:
          // 以根部為中心點構建
          var arrowRootX = rect.left +
              radius +
              ((rect.width - radius * 2) * shiftRootPercent);
          path.quadraticBezierTo(arrowRootX, rect.top, arrowX, arrowY);
          path.quadraticBezierTo(
              arrowRootX, rect.top, rect.right - radius, rect.top);
          break;
        case ArrowSide.line:
          // 以箭頭尖端為中心構建
          double arrowRootStartX = arrowX - arrowRootSize / 2;
          arrowRootStartX = max(rect.left + radius, arrowRootStartX);
          double arrowRootEndX = arrowRootStartX + arrowRootSize;
          arrowRootEndX = min(rect.right - radius, arrowRootEndX);
          path.lineTo(arrowRootStartX, rect.top);
          path.lineTo(arrowX, arrowY);
          path.lineTo(arrowRootEndX, rect.top);
          path.lineTo(rect.right - radius, rect.top);
          break;
      }
    } else {
      path.lineTo(rect.right - radius, rect.top);
    }
  }

  /// 構建右方 path
  void _buildRightLine(Path path, Rect rect) {
    // 檢查箭頭是否在右邊
    if (direction == AxisDirection.right && arrowSize != 0) {
      // 箭頭對準 [shiftPercent]
      var arrowX = rect.right + arrowSize;
      var arrowY = rect.top + (rect.height * shiftLeafPercent);

      switch (arrowSide) {
        case ArrowSide.bezier:
          // 以根部為中心點構建
          var arrowRootY = rect.top +
              radius +
              ((rect.height - radius * 2) * shiftRootPercent);
          path.quadraticBezierTo(rect.right, arrowRootY, arrowX, arrowY);
          path.quadraticBezierTo(
              rect.right, arrowRootY, rect.right, rect.bottom - radius);
          break;
        case ArrowSide.line:
          // 以箭頭尖端為中心構建
          double arrowRootStartY = arrowY - arrowRootSize / 2;
          arrowRootStartY = max(rect.top + radius, arrowRootStartY);
          double arrowRootEndY = arrowRootStartY + arrowRootSize;
          arrowRootEndY = min(rect.bottom - radius, arrowRootEndY);
          path.lineTo(rect.right, arrowRootStartY);
          path.lineTo(arrowX, arrowY);
          path.lineTo(rect.right, arrowRootEndY);
          path.lineTo(rect.right, rect.bottom - radius);
          break;
      }
    } else {
      path.lineTo(rect.right, rect.bottom - radius);
    }
  }

  /// 構建下方 path
  void _buildDownLine(Path path, Rect rect) {
    // 檢查箭頭是否在下邊
    if (direction == AxisDirection.down && arrowSize != 0) {
      // 箭頭對準 [shiftPercent]
      var arrowX = rect.left + (rect.width * shiftLeafPercent);
      var arrowY = rect.bottom + arrowSize;

      switch (arrowSide) {
        case ArrowSide.bezier:
          // 以根部為中心點構建
          var arrowRootX = rect.left +
              radius +
              ((rect.width - radius * 2) * shiftRootPercent);
          path.quadraticBezierTo(arrowRootX, rect.bottom, arrowX, arrowY);
          path.quadraticBezierTo(
              arrowRootX, rect.bottom, rect.left + radius, rect.bottom);
          break;
        case ArrowSide.line:
          // 以箭頭尖端為中心構建
          double arrowRootStartX = arrowX - arrowRootSize / 2;
          arrowRootStartX = max(rect.left + radius, arrowRootStartX);
          double arrowRootEndX = arrowRootStartX + arrowRootSize;
          arrowRootEndX = min(rect.right - radius, arrowRootEndX);
          path.lineTo(arrowRootEndX, rect.bottom);
          path.lineTo(arrowX, arrowY);
          path.lineTo(arrowRootStartX, rect.bottom);
          path.lineTo(rect.left + radius, rect.bottom);
          break;
      }
    } else {
      path.lineTo(rect.left + radius, rect.bottom);
    }
  }

  /// 構建左方 path
  void _buildLeftLine(Path path, Rect rect) {
    // 檢查箭頭是否在左邊
    if (direction == AxisDirection.left && arrowSize != 0) {
      // 箭頭對準 [shiftPercent]
      var arrowX = rect.left - arrowSize;
      var arrowY = rect.top + (rect.height * shiftLeafPercent);

      switch (arrowSide) {
        case ArrowSide.bezier:
          // 以根部為中心點構建
          var arrowRootY = rect.top +
              radius +
              ((rect.height - radius * 2) * shiftRootPercent);
          path.quadraticBezierTo(rect.left, arrowRootY, arrowX, arrowY);
          path.quadraticBezierTo(
              rect.left, arrowRootY, rect.left, rect.top + radius);
          break;
        case ArrowSide.line:
          // 以箭頭尖端為中心構建
          double arrowRootStartY = arrowY - arrowRootSize / 2;
          arrowRootStartY = max(rect.top + radius, arrowRootStartY);
          double arrowRootEndY = arrowRootStartY + arrowRootSize;
          arrowRootEndY = min(rect.bottom - radius, arrowRootEndY);
          path.lineTo(rect.left, arrowRootEndY);
          path.lineTo(arrowX, arrowY);
          path.lineTo(rect.left, arrowRootStartY);
          path.lineTo(rect.left, rect.top + radius);
          break;
      }
    } else {
      path.lineTo(rect.left, rect.top + radius);
    }
  }
}

/// 箭頭的類型
enum ArrowSide {
  /// 貝茲曲線, 默認整個邊皆為曲線
  bezier,

  /// 直線, 會有完整的三角形直線
  line,
}
