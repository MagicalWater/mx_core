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
          _contentLayout(context),
          // ForceCenterLayout(
          //   direction: Axis.horizontal,
          //   leading: Container(
          //     color: Colors.purpleAccent,
          //     child: Material(
          //       color: Colors.transparent,
          //       type: MaterialType.transparency,
          //       child: InkWell(
          //         onTap: () {
          //           print('點擊');
          //         },
          //         child: Container(
          //           width: 50,
          //           height: 200,
          //           // color: ,
          //         ),
          //       ),
          //     ),
          //   ),
          //   center: Container(
          //     color: Colors.blueAccent,
          //     width: 100,
          //     child: Text(
          //       '文字,文字,文字,文字,文字',
          //       style: TextStyle(fontSize: 15, color: Colors.white),
          //       maxLines: 10,
          //     ),
          //   ),
          //   trailing: Container(
          //     width: 100,
          //     height: 100,
          //     color: Colors.redAccent,
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: Container(
          //             height: 10,
          //             color: Colors.purpleAccent,
          //           ),
          //         ),
          //         Expanded(
          //           child: Container(
          //             width: 20,
          //             height: 10,
          //             color: Colors.lightGreenAccent,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          //   gapSpace: 10,
          //   // centerConstraint: BoxConstraints(maxHeight: 20),
          //   spaceUsedPriority: SpaceUsedPriority.bothEndsFirst,
          //   mainShrinkWrap: true,
          //   crossShrinkWrap: true,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          // )
        ],
      ),
    );
  }

  /// 決定appBar顯示樣式的佈局
  Widget _contentLayout(BuildContext context) {
    final barHeight = 50.0;
    final decoration = (const BoxDecoration(color: Colors.blueAccent));

    return SafeArea(
      child: Container(
        height: barHeight,
        decoration: decoration,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            SizedBox(
              height: barHeight,
              child: ForceCenterLayout(
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 40,
                      color: Colors.yellow,
                    ),
                  ],
                ),
                center: Text(
                  'context',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: Colors.black87,
                    ),
                  ],
                ),
                spaceUsedPriority: SpaceUsedPriority.bothEndsFirst,
                gapSpace: 10,
                mainShrinkWrap: false,
                crossShrinkWrap: false,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
