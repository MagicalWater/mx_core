import 'dart:math';

import 'package:flutter/material.dart';

/// 多層次的 Material
/// 元件結構
/// MaterialLayer
/// => Container(應用 layer)
/// . layer
/// .
/// .
/// => Material
/// => InkWell
/// => child
class MaterialLayer extends StatelessWidget {
  final List<LayerProperties> layers;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Widget child;

  MaterialLayer._({
    this.child,
    this.layers,
    this.borderRadius,
    this.onTap,
  });

  factory MaterialLayer({
    Widget child,
    List<LayerProperties> layers,
    TapFeedback tapStyle,
    VoidCallback onTap,
  }) {
    layers ??= [];
    BorderRadius borderRadius;
    if (onTap != null && layers.isNotEmpty) {
      borderRadius = _getBorderRadius(layers, child);
    }

    Widget widgetChain = child;

    if (onTap != null) {
      widgetChain = Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          highlightColor: tapStyle?.highlightColor,
          splashColor: tapStyle?.splashColor,
          focusColor: tapStyle?.focusColor,
          hoverColor: tapStyle?.hoverColor,
          borderRadius: borderRadius,
          onTap: onTap,
          child: child,
        ),
      );
    }

    // 把所有的layer轉化為container
    layers
        .forEach((e) => widgetChain = _convertLayerToContainer(e, widgetChain));

    return MaterialLayer._(
      child: widgetChain,
      layers: layers,
      borderRadius: borderRadius,
      onTap: onTap,
    );
  }

  factory MaterialLayer.single({
    Widget child,
    LayerProperties layer,
    TapFeedback tapStyle,
    VoidCallback onTap,
  }) {
    return MaterialLayer(
      layers: layer == null ? null : [layer],
      child: child,
      tapStyle: tapStyle,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class LayerProperties {
  AlignmentGeometry alignment;
  EdgeInsetsGeometry padding;
  Color color;
  Decoration decoration;
  Decoration foregroundDecoration;
  double width;
  double height;
  BoxConstraints constraints;
  EdgeInsetsGeometry margin;
  Matrix4 transform;

  LayerProperties({
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
  });
}

/// 從 layers 取得應該設置給 InkWell 的 borderRadius
BorderRadius _getBorderRadius(List<LayerProperties> layers, Widget child) {
  BorderRadius borderRadius;

  // 找出擁有 radius 的所有 layers
  var boxDecorationList = layers
      .where((e) {
        return e.decoration != null && e.decoration is BoxDecoration;
      })
      .map((e) => e.decoration as BoxDecoration)
      .toList();

  if (child is Container &&
      child.decoration != null &&
      child.decoration is BoxDecoration) {
    boxDecorationList.add(child.decoration);
  } else if (child is DecoratedBox &&
      child.decoration != null &&
      child.decoration is BoxDecoration) {
    boxDecorationList.add(child.decoration);
  }

  if (boxDecorationList.isNotEmpty) {
    bool isCircle = boxDecorationList.any((e) => e.shape == BoxShape.circle);

    if (isCircle) {
      // 是圓圈 shape
      borderRadius = BorderRadius.circular(9999);
    } else {
      // 遍歷所有 decoration, 取得 InkWell 應該設置的點擊 radius
      Radius topLeft = Radius.zero;
      Radius topRight = Radius.zero;
      Radius bottomLeft = Radius.zero;
      Radius bottomRight = Radius.zero;

      boxDecorationList.forEach((e) {
        var borderRadius = e.borderRadius;
        if (borderRadius != null && borderRadius is BorderRadius) {
          var topLeftX = max(topLeft.x, borderRadius.topLeft.x);
          var topLeftY = max(topLeft.y, borderRadius.topLeft.y);
          var topRightX = max(topRight.x, borderRadius.topRight.x);
          var topRightY = max(topRight.y, borderRadius.topRight.y);
          var bottomLeftX = max(bottomLeft.x, borderRadius.bottomLeft.x);
          var bottomLeftY = max(bottomLeft.y, borderRadius.bottomLeft.y);
          var bottomRightX = max(bottomRight.x, borderRadius.bottomRight.x);
          var bottomRightY = max(bottomRight.y, borderRadius.bottomRight.y);

          topLeft = Radius.elliptical(topLeftX, topLeftY);
          topRight = Radius.elliptical(topRightX, topRightY);
          bottomLeft = Radius.elliptical(bottomLeftX, bottomLeftY);
          bottomRight = Radius.elliptical(bottomRightX, bottomRightY);
        }
      });

      borderRadius = BorderRadius.only(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      );
    }
  }

  return borderRadius;
}

/// 將 Layer 轉換為 Container
Container _convertLayerToContainer(LayerProperties layer, Widget child) {
  return Container(
    alignment: layer.alignment,
    decoration: layer.decoration,
    color: layer.color,
    foregroundDecoration: layer.foregroundDecoration,
    padding: layer.padding,
    margin: layer.margin,
    width: layer.width,
    height: layer.height,
    transform: layer.transform,
    constraints: layer.constraints,
    child: child,
  );
}

class TapFeedback {
  Color highlightColor;
  Color splashColor;
  Color focusColor;
  Color hoverColor;

  TapFeedback({
    this.highlightColor,
    this.splashColor,
    this.focusColor,
    this.hoverColor,
  });
}
