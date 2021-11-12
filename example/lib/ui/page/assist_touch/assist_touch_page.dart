import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

import 'assist_touch_cubit.dart';

/// 展示輔助按鈕
class AssistTouchPage extends StatefulWidget {
  final RouteOption option;

  AssistTouchPage(this.option) : super();

  @override
  _AssistTouchPageState createState() => _AssistTouchPageState();
}

class _AssistTouchPageState extends State<AssistTouchPage> {
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
    return BlocProvider(
      create: (context) => AssistTouchCubit(),
      child: _view(),
    );
  }

  Widget _view() {
    return BlocBuilder<AssistTouchCubit, AssistTouchState>(
      builder: (context, state) {
        return PageScaffold(
          haveAppBar: true,
          color: Colors.white,
          title: state.title,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                TopDesc(content: state.content),
                _item(),
//            RaisedButton(
//              onPressed: () {
//                Popup.showOverlay(
//                  context,
//                  hitRule: HitRule.childIntercept,
//                  builder: (controller) {
//                    return buildAssistTouch();
//                  }
//                );
//              },
//              child: Text('點我跳輔助按鈕'),
//            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _item() {
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
