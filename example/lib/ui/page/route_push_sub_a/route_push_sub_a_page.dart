import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class RoutePushSubAPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubAPage(this.option) : super();

  @override
  _RoutePushSubAPageState createState() => _RoutePushSubAPageState();
}

class _RoutePushSubAPageState extends State<RoutePushSubAPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      child: Container(
        decoration: BoxDecoration(color: Colors.brown),
        alignment: Alignment.center,
        child: Text(
          "子頁面A",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }
}
