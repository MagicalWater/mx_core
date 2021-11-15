import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class RoutePushThirdPage extends StatefulWidget {
  final RouteOption option;

  RoutePushThirdPage(this.option) : super();

  @override
  _RoutePushThirdPageState createState() => _RoutePushThirdPageState();
}

class _RoutePushThirdPageState extends State<RoutePushThirdPage> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      title: "RoutePushThird",
      child: Container(
        child: TextButton(
          onPressed: () {
//              bloc.popAndPushPage(route, context)
          },
          child: Text('回退到上個頁面的紫頁面'),
        ),
      ),
    );
  }
}
