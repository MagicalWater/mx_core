import 'package:flutter/material.dart';

/// 圖表慣性滾動
class ChartInertialScroller {
  final AnimationController _controller;

  ChartInertialScroller({required AnimationController controller})
      : _controller = controller;

  /// 是否正在慣性滾動中
  bool get isScroll => _controller.isAnimating;

  /// 停止滾動
  void stopScroll() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  /// 進行慣性滾動
  /// [position] - 開始進行慣性滾動的位置
  /// [velocity] - 初始慣性滑動速率
  void startIntertialScroll({
    required double position,
    required double velocity,
  }) {
    final pixelRatio = WidgetsBinding.instance!.window.devicePixelRatio;

    // 計算模擬滾動公差
    // TODO: 這邊是模擬滾動的重點, 對於圖表的絲滑程度有個很重要的決定性差異, 之後需要多多研究
    final tolerance = Tolerance(
      velocity: 1.0 / (0.050 * pixelRatio),
      distance: 1.0 / pixelRatio,
    );

    // 從 [position] 開始進行模擬滾動
    final simulation = ClampingScrollSimulation(
      position: position,
      velocity: velocity,
      tolerance: tolerance,
    );
    _controller.animateWith(simulation);
  }
}
