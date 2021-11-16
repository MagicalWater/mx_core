part of 'wave_progress.dart';

/// 波浪進度繪製
class _WaveProgressPainter extends CustomPainter {
  late Paint _paint1;
  late Paint _paint2;

  /// 構成波浪path的 offset
  final List<Offset> points1;
  final List<Offset> points2;

  /// 當前的波浪震幅
  final double amplitude;

  /// 波浪進度百分比
  final double percent;

  /// 外框形狀
  BoxShape shape;

  /// 外框圓角
  double radius;

  _WaveProgressPainter({
    required this.points1,
    required this.points2,
    required this.percent,
    required this.amplitude,
    required this.shape,
    this.radius = 0,
    required Color waveColor,
    Color? secondWaveColor,
  }) {
    _paint1 = Paint()
      ..strokeWidth = 1
      ..color = waveColor
      ..style = PaintingStyle.fill;

    _paint2 = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    secondWaveColor ??= Color.fromARGB(
        waveColor.alpha,
        (waveColor.red + 255) ~/ 2,
        (waveColor.green + 255) ~/ 2,
        (waveColor.blue + 255) ~/ 2,
      );
    _paint2.color = secondWaveColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    var clipPath = Path();
    var rect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      Radius.circular(radius),
    );
    switch (shape) {
      case BoxShape.rectangle:
        clipPath.addRRect(rect);
        break;
      case BoxShape.circle:
        clipPath.addOval(rect.outerRect);
        break;
    }
    canvas.clipPath(clipPath);
    _drawWave(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /// 繪製波浪
  void _drawWave(Canvas canvas, Size size) {
    // 依照當前進度百分比, 取得位置的波浪線高度
    var waveHeight = size.height * (1 - percent);

    var translatePoints1 =
        points1.map((e) => e.translate(0, waveHeight)).toList();

    // 遠景波浪偏移將在前景波浪的基礎上往上偏移
    // 偏移的距離為 震幅 * (1/3)
    var translatePoints2 = points2
        .map((e) => e.translate(0, waveHeight - (amplitude * (1 / 3))))
        .toList();

    Path path1 = Path()
      ..addPolygon(translatePoints1, false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path path2 = Path()
      ..addPolygon(translatePoints2, false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, _paint2);
    canvas.drawPath(path1, _paint1);
  }
}
