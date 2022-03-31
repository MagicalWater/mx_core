import 'package:flutter/material.dart';
import 'package:mx_core/ui/clipper/point_clipper.dart';

class CustomGlobalPriceTag extends StatelessWidget {
  final String tag;
  final TextStyle tagStyle;
  final Color themeColor;
  final Size arrowSize;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const CustomGlobalPriceTag({
    Key? key,
    required this.tag,
    this.themeColor = Colors.blueAccent,
    this.tagStyle = const TextStyle(fontSize: 10, color: Colors.white),
    this.padding = const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
    this.arrowSize = const Size(8, 10),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: themeColor,
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: padding,
                child: Text(tag, style: tagStyle),
              ),
            ),
          ),
        ),
        SizedBox(width: padding.horizontal / 2),
        _triangle(themeColor, arrowSize),
      ],
    );
  }

  Widget _triangle(Color color, Size size) {
    return ClipPath(
      clipper: PointClipper(
        points: [
          [
            const Offset(0, 0),
            const Offset(1, 0.5),
            const Offset(0, 1),
          ],
        ],
      ),
      child: Container(
        width: size.width,
        height: size.height,
        color: color,
      ),
    );
  }
}
