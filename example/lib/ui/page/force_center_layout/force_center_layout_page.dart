import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class ForceCenterLayoutPage extends StatefulWidget {
  final RouteOption option;

  ForceCenterLayoutPage(this.option) : super();

  @override
  _ForceCenterLayoutPageState createState() => _ForceCenterLayoutPageState();
}

class _ForceCenterLayoutPageState extends State<ForceCenterLayoutPage> {
  var title = "強制置中元件";
  var content = """
  左右兩個元件等寬, 中間元件置中於外層元件
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: baseAppBar(title),
      body: Column(
        children: <Widget>[
          TopDesc(content: content),
          Container(
            alignment: Alignment.bottomCenter,
            width: 10.scaleA,
            height: 10.scaleA,
            color: Colors.grey,
          ),
          ForceCenterLayout(
            direction: Axis.horizontal,
            leading: Container(
              width: 50,
              height: 200,
              color: Colors.purpleAccent,
            ),
            center: Container(
              color: Colors.blueAccent,
              width: 100,
              child: Text(
                '文字,文字,文字,文字,文字',
                style: TextStyle(fontSize: 15, color: Colors.white),
                maxLines: 10,
              ),
            ),
            trailing: Container(
              width: 100,
              height: 100,
              color: Colors.redAccent,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 10,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 20,
                      height: 10,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ],
              ),
            ),
            gapSpace: 10,
            // centerConstraint: BoxConstraints(maxHeight: 20),
            spaceUsedPriority: SpaceUsedPriority.bothEndsFirst,
            mainShrinkWrap: true,
            crossShrinkWrap: false,
            crossAxisAlignment: CrossAxisAlignment.end,
          )
        ],
      ),
    );
  }
}
