import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class LineIndicatorPage extends StatefulWidget {
  final RouteOption option;

  LineIndicatorPage(this.option) : super();

  @override
  _LineIndicatorPageState createState() => _LineIndicatorPageState();
}

class _LineIndicatorPageState extends State<LineIndicatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar("LineIndicator"),
      body: Container(
//          color: Colors.blueAccent,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('線條指示'),
            Container(
              color: Colors.red,
              child: LineIndicator(
                color: Colors.blue.withOpacity(0.9),
                start: 0.1,
                end: 1,
                size: 10.scaleA,
                direction: Axis.horizontal,
                alignment: Alignment.topRight,
                duration: Duration(seconds: 5),
                appearAnimation: false,
                places: [
                  LinePlace(
                    start: 0.25,
                    end: 0.28,
                    color: Colors.green,
                    placeUp: true,
                  ),
                  LinePlace(
                    start: 0.65,
                    end: 0.90,
                    color: Colors.black,
                    placeUp: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}