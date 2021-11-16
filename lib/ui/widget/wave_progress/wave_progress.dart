import 'dart:math';

import 'package:flutter/material.dart';

part 'wave_painter.dart';

/// 進度控制
class ProgressController {
  _WaveProgressState? _bind;

  double get currentProgress => _bind?._currentProgress ?? 0;

  /// 設置進度
  void setProgress(double progress, [double? total]) {
    _bind?.setProgress(progress, total);
  }

  void dispose() {
    _bind = null;
  }
}

/// 進度元件構建
typedef ProgressWidgetBuilder = Function(
    BuildContext context, double progress, double total);

/// 波浪進度條
class WaveProgress extends StatefulWidget {
  /// 波浪顏色
  final Color waveColor;

  /// 第二道波浪顏色
  final Color? secondWaveColor;

  /// 波浪速率
  final double velocity;

  /// 波浪高度幅度倍數
  final double amplitudeMultiple;

  /// 子元件構建類
  final ProgressWidgetBuilder? builder;

  /// 滿進度
  final double maxProgress;

  /// 初始進度
  final double initProgress;

  /// 裝載形狀
  final BoxShape shape;

  /// 外框參數
  final WaveStyle style;

  final ProgressController? controller;

  const WaveProgress({Key? key,
    this.builder,
    this.initProgress = 30,
    this.maxProgress = 100,
    this.waveColor = Colors.blueAccent,
    this.secondWaveColor,
    this.velocity = 100,
    this.controller,
    this.shape = BoxShape.circle,
    this.style = const WaveStyle(),
    this.amplitudeMultiple = 1,
  }) : super(key: key);

  @override
  _WaveProgressState createState() => _WaveProgressState();
}

class _WaveProgressState extends State<WaveProgress>
    with TickerProviderStateMixin {
  /// 近處的波浪
  late AnimationController _waveAnimationController1;

  /// 遠方的波浪
  late AnimationController _waveAnimationController2;

  /// 構成波浪path的 offset
  List<Offset> _wavePoints1 = [];

  List<Offset> _wavePoints2 = [];

  /// 當前的波浪震幅
  late double _waveAmplitude;

  /// 滿進度
  late double _totalProgress;

  /// 動畫賦予的進度暫存值
  late double _tempAnimatedProgress;

  /// 當前進度
  late double _currentProgress;

  /// 當前進度轉換為比例
  double get _progressPercent => min(_tempAnimatedProgress / _totalProgress, 1);

  @override
  void initState() {
    _waveAmplitude = 0;
    _tempAnimatedProgress = 0;
    _totalProgress = widget.maxProgress;
    _currentProgress = widget.initProgress;

    widget.controller?._bind = this;

    // 將速率換換成波浪移動一個 pi 的時間
    // 這邊的換算乘以 20 只是單純適配個人認為最剛好的速率
    var speed1 = (20 * widget.velocity).toInt();

    // 比較遠的海浪速度要慢一點, 因此我們將 [speed1] 乘以 2.5
    var speed2 = (speed1 * 1.5).toInt();

    _waveAnimationController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: speed1),
    );

    _waveAnimationController2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: speed2),
    );

    var animation1 = CurvedAnimation(
      parent: _waveAnimationController1,
      curve: Curves.linear,
    );

    var animation2 = CurvedAnimation(
      parent: _waveAnimationController2,
      curve: Curves.linear,
    );

    _waveAnimationController1.addListener(() {
      RenderBox stackBox = context.findRenderObject() as RenderBox;
      if (!stackBox.hasSize) {
        _wavePoints1.clear();
        _wavePoints2.clear();
        return;
      }

      var widgetWidth = stackBox.size.width;
      var widgetHeight = stackBox.size.height;
      var pointCount = widgetWidth.toInt();

      var value1 = animation1.value;
      var value2 = animation2.value;

      // 動畫暫存值準備動畫移動到當前的進度值
      // 每次的進度動畫跳轉將以 1/100 的方式更新
      if (_tempAnimatedProgress > _currentProgress) {
        _tempAnimatedProgress -= _totalProgress / 100;
        if (_tempAnimatedProgress < _currentProgress) {
          _tempAnimatedProgress = _currentProgress;
        }
      } else if (_tempAnimatedProgress < _currentProgress) {
        _tempAnimatedProgress += _totalProgress / 100;
        if (_tempAnimatedProgress > _currentProgress) {
          _tempAnimatedProgress = _currentProgress;
        }
      }

      // 將動畫移動的值更改為長度最長為 2pi
      // 因為2pi 為一個完整的循環 z, 長度拉為 2pi
      // 代表動畫位移數度, 為在 2 秒內位移 2pi 的距離
      var animatedTranslateX1 = (2 * pi) * (value1 / 1);
      var animatedTranslateX2 = (2 * pi) * (value2 / 1);

      // 波浪的數量跟寬度比為 1 : 300
      // 波浪的振幅跟面積比為 15 : (200 * 300)
      // 震幅依照當前進度百分比, 越接近50%, 此震幅越高, 否則越低
      // 此比值單純為個人認為最好的比值
      var waveCount = pointCount / 300;
      var progressDiff = (_progressPercent - 0.5).abs() * 20;
      _waveAmplitude = 15 * ((100 - progressDiff) / 100);
      _waveAmplitude =
          ((widgetWidth * widgetHeight) * _waveAmplitude) / (200 * 300);
      _waveAmplitude *= widget.amplitudeMultiple;

      // 依照當前的 size, 設置構成波浪的 offset
      _wavePoints1 = _getWavePoints(
        animatedValue: animatedTranslateX1,
        totalPoint: pointCount,
        waveCount: waveCount,
        amplitude: _waveAmplitude,
      );
      _wavePoints2 = _getWavePoints(
        animatedValue: animatedTranslateX2,
        totalPoint: pointCount,
        waveCount: waveCount * 2 / 3,
        amplitude: _waveAmplitude,
      );
    });

    _waveAnimationController1.repeat();
    _waveAnimationController2.repeat();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: _getDecoration(),
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: _waveAnimationController1,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) {
          Widget childWidget;
          if (widget.builder != null) {
            childWidget =
                widget.builder!(context, _tempAnimatedProgress, _totalProgress);
          } else {
            childWidget = Container(
              alignment: Alignment.center,
              child: Text(
                "${((_tempAnimatedProgress / _totalProgress) * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            );
          }
          return CustomPaint(
            child: childWidget,
            painter: _WaveProgressPainter(
              points1: _wavePoints1,
              percent: _progressPercent,
              points2: _wavePoints2,
              amplitude: _waveAmplitude,
              shape: widget.shape,
              radius: widget.style.radius ?? 0,
              waveColor: widget.waveColor,
              secondWaveColor: widget.secondWaveColor,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _waveAnimationController1.dispose();
    _waveAnimationController2.dispose();
    super.dispose();
  }

  /// 設置進度
  void setProgress(double progress, [double? total]) {
    if (total != null && total > 0) {
      _totalProgress = total;
    }

    if (progress <= 0) {
      _currentProgress = 0;
    } else if (progress >= _totalProgress) {
      _currentProgress = _totalProgress;
    } else {
      _currentProgress = progress;
    }
  }

  /// 取得波浪的全部的點
  /// [animatedValue] - 動畫偏移值, 由動畫取得並帶入此值達到波浪移動的效果
  /// [totalPoint] - 共有多少個點需要生成
  /// [waveCount] - 波浪的數量
  /// [amplitude] - 波浪震幅高度
  List<Offset> _getWavePoints({
    required double animatedValue,
    required int totalPoint,
    required double waveCount,
    required double amplitude,
  }) {
    // 依照 [waveCount] 的數量, 取得應該將多長的曲線拉滿
    // 例如當 [waveCount] 為 3 時, 則依照比例, 長度應該要拉為6pi
    var extendWidth = waveCount * (2 * pi);
    return List.generate(totalPoint, (index) {
      var x = extendWidth * (index / totalPoint) + animatedValue;
      var y = sin(x) * amplitude;
      return Offset(index.toDouble(), y);
    });
  }

  /// 從 shape 以及 borderStyle 取得 Decoration
  Decoration _getDecoration() {
    var style = widget.style;
    return BoxDecoration(
      shape: widget.shape,
      borderRadius: widget.shape == BoxShape.circle
          ? null
          : BorderRadius.circular(style.radius ?? 0),
      border: style.borderWidth == 0
          ? null
          : Border.all(
              color: style.borderColor,
              width: style.borderWidth,
            ),
      color: style.color,
      gradient: style.gradient,
    );
  }
}

/// 容器裝飾
class WaveStyle {
  /// 外框粗細
  final double borderWidth;

  /// 外框顏色
  final Color borderColor;

  /// 內容漸變
  final Gradient? gradient;

  /// 內容顏色
  final Color? color;

  /// 圓角
  final double? radius;

  const WaveStyle({
    this.borderWidth = 1,
    this.borderColor = Colors.black,
    this.gradient,
    this.color,
    this.radius,
  });

  static const WaveStyle none = WaveStyle(borderWidth: 0);
}
