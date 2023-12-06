
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

export 'route.dart';

class PointPaintPage extends StatefulWidget {
  final RouteOption option;

  const PointPaintPage(this.option, {Key? key}) : super(key: key);

  @override
  State<PointPaintPage> createState() => _PointPaintPageState();
}

class _PointPaintPageState extends State<PointPaintPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PointPaint(
          width: 100,
          height: 100,
          points: [
            [
              Offset(0,0),
              Offset(1,0),
              Offset(1,1),
              Offset(0,1),
            ],
          ],
          strokeWidth: 1,
          strokeColor: Colors.blueAccent.withOpacity(1),
          fillColor: Colors.greenAccent.withOpacity(0.5),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.purpleAccent.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}