import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class RoutePushSubBPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubBPage(this.option) : super();

  @override
  _RoutePushSubBPageState createState() => _RoutePushSubBPageState();
}

class _RoutePushSubBPageState extends State<RoutePushSubBPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      child: Container(
        decoration: BoxDecoration(color: Colors.teal),
        alignment: Alignment.center,
        child: Text(
          "子頁面B",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }
}
