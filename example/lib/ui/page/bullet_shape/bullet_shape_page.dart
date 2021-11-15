import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class BulletShapePage extends StatefulWidget {
  final RouteOption option;

  BulletShapePage(this.option) : super();

  @override
  _BulletShapePageState createState() => _BulletShapePageState();
}

class _BulletShapePageState extends State<BulletShapePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar('子彈渲染'),
      body: SafeArea(
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
