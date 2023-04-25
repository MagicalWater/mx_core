import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class RoutePushSubB2Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSubB2Page(this.option) : super();

  @override
  _RoutePushSubB2PageState createState() => _RoutePushSubB2PageState();
}

class _RoutePushSubB2PageState extends State<RoutePushSubB2Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      child: Container(
        decoration: BoxDecoration(color: Colors.blueGrey),
        alignment: Alignment.center,
        child: Text(
          "子頁面B2",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }
}
