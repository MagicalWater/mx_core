import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class BulletShapePage extends StatefulWidget {
  final RouteOption option;

  BulletShapePage(this.option) : super();

  @override
  _BulletShapePageState createState() => _BulletShapePageState();
}

class _BulletShapePageState extends State<BulletShapePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      title: '子彈渲染',
      child: SafeArea(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.black,
          child: BulletPaint(
            direction: AxisDirection.left,
          ),
        ),
      ),
    );
  }
}
