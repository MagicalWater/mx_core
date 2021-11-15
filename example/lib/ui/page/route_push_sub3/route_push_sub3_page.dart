import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

class RoutePushSub3Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSub3Page(this.option) : super();

  @override
  _RoutePushSub3PageState createState() => _RoutePushSub3PageState();
}

class _RoutePushSub3PageState extends State<RoutePushSub3Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.blueAccent,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Text(
        "子頁面3",
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
    );
  }
}
