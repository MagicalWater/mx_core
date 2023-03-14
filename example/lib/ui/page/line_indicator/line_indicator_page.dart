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
  Color lineColor = Colors.blue;

  double lineStart = 0.1;
  double lineEnd = 1;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar("LineIndicator"),
      body: GestureDetector(
        onTap: () {
          lineColor = Colors.red;
          lineStart = 0.3;
          lineEnd = 0.8;
          setState(() {

          });
        },
        child: Container(
//          color: Colors.blueAccent,
          alignment: Alignment.center,
          child: Column(
            children: [
              const Text('線條指示'),
              Expanded(
                child: LineIndicator(
                  color: lineColor,
                  start: lineStart,
                  end: lineEnd,
                  size: 10.scaleA,
                  direction: Axis.horizontal,
                  alignment: Alignment.topRight,
                  duration: const Duration(seconds: 5),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.blueAccent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  ),
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
                  dashStyle: const DashStyle(
                    20, 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
