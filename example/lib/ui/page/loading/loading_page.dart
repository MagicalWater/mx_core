import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

/// 展示讀取動畫
class LoadingPage extends StatefulWidget {
  final RouteOption option;

  LoadingPage(this.option) : super();

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  var title = "讀取動畫";
  var content = """
  讀取動畫
  1. 現有 ${LoadingType.values.length} 種讀取動畫
  2. LoadingProvider 讀取提供元件默認使用 Ball
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baseAppBar(title),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopDesc(content: content),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 3,
                  children:
                      LoadingType.values.map((e) => buildLoading(e)).toList(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading(LoadingType type) {
    switch (type) {
      case LoadingType.spring:
        return buildSpring();
      case LoadingType.roundSpring:
        return buildRoundSpring();
      case LoadingType.circle:
        return buildCircle();
    }
  }

  Widget buildSpring() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.spring(
        color: Color(0xffac8048),
        size: 20,
        duration: 500,
      ),
    );
  }

  Widget buildRoundSpring() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.roundSpring(
        ballCount: 2,
        color: Color(0xffac8048),
        size: 20,
        duration: 1000,
      ),
    );
  }

  Widget buildCircle() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.circle(
        color: Color(0xffac8048),
        size: 50,
        duration: 1000,
        headCount: 1,
      ),
    );
  }
}

enum LoadingType {
  spring,
  roundSpring,
  circle,
}
