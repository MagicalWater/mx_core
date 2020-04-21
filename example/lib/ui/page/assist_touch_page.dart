import 'dart:math';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mx_core/mx_core.dart';

import '../../router/route.dart';
import 'introduction_page.dart';

/// 展示輔助按鈕
@ARoute(url: Pages.assistTouch)
class AssistTouchPage extends StatefulWidget {
  final RouteOption option;

  AssistTouchPage(this.option) : super();

  @override
  _AssistTouchPageState createState() => _AssistTouchPageState();
}

class _AssistTouchPageState extends State<AssistTouchPage> {
  var title = "輔助按鈕";
  var content = """
  輔助按鈕
  1. 類似於ios小白點
  2. 可依照展開進度給予不同的操作面板
  """;

  var style = TextStyle(
    color: Colors.white,
  );

  Color get randomColor {
    return Color.fromARGB(
      255,
      Random().nextInt(100) + 30,
      Random().nextInt(100) + 30,
      Random().nextInt(100) + 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      color: Colors.white,
      title: title,
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            buildIntroduction(content),
            buildAssistTouch(),
          ],
        ),
      ),
    );
  }

  Widget buildAssistTouch() {
    return AssistTouch(
      initOffset: Offset(0, 200),
      maskColor: Colors.black,
      maskOpacity: 0.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xfffcd098),
            Color(0xfff85f62),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: BoxShape.circle,
      ),
      child: Align(
        child: Text(
          "主按鈕",
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
      rotateAction: false,
      size: 100,
      actionSize: 50,
      boardRadius: 150,
      expandRadius: 100,
      animationDuration: Duration(milliseconds: 500),
      boardBuilder: (BuildContext context, double progress) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xfff85f62).withAlpha(50),
            shape: BoxShape.circle,
          ),
          width: 400 * progress,
          height: 400 * progress,
        );
      },
      actions: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffcca068),
                Color(0xff8c6018),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            child: Text(
              "按鈕1",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffcca068),
                Color(0xff8c6018),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            child: Text(
              "按鈕2",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffcca068),
                Color(0xff8c6018),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            child: Text(
              "按鈕3",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffcca068),
                Color(0xff8c6018),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
          ),
          child: Align(
            child: Text(
              "按鈕4",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
