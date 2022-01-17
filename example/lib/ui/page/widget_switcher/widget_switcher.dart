import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

export 'widget_switcher_route.dart';

class WidgetSwitcherPage extends StatefulWidget {
  final RouteOption option;

  const WidgetSwitcherPage(this.option, {Key? key}) : super(key: key);

  @override
  _WidgetSwitcherPageState createState() => _WidgetSwitcherPageState();
}

class _WidgetSwitcherPageState extends State<WidgetSwitcherPage> {
  final controller = WidgetSwitchController<String>();

  int nowIndex = 0;

  Map<String, Color> _mapColor = {};

  Color getColor(String tag) {
    if (_mapColor.containsKey(tag)) {
      return _mapColor[tag]!;
    } else {
      final color = Color.fromARGB(
        255,
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
      );
      _mapColor[tag] = color;
      return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    if (controller.history.length == 1) {
                      print('沒有上一頁了');
                      return;
                    }
                    print('回退上一頁');
                    nowIndex--;
                    controller.pop();
                  },
                  child: Text('上一頁'),
                ),
                TextButton(
                  onPressed: () {
                    print('切換下一頁');
                    nowIndex++;
                    controller.push(nowIndex.toString());
                  },
                  child: Text('下一頁'),
                ),
              ],
            ),
            Expanded(
              child: WidgetSwitcher<String>(
                controller: controller,
                initTag: '初始頁面',
                translateIn: Offset(Screen.width, 0),
                translateOut: Offset(-40, 0),
                popDirection: AxisDirection.right,
                opacityIn: 1,
                opacityOut: 1,
                duration: Duration(seconds: 1),
                swipePopEnabled: false,
                builder: (BuildContext context, String tag) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: _StatfulText(
                      text: '頁面 $tag',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatfulText extends StatefulWidget {
  final String text;

  const _StatfulText({Key? key, required this.text}) : super(key: key);

  @override
  _StatfulTextState createState() => _StatfulTextState();
}

class _StatfulTextState extends State<_StatfulText> {
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tapCount++;
        setState(() {});
      },
      child: Text(
        '${widget.text} - $tapCount',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }
}
