import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/route_push_sub2/route_push_sub2.dart';

class RoutePushSubB1Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSubB1Page(this.option) : super();

  @override
  _RoutePushSubB1PageState createState() => _RoutePushSubB1PageState();
}

class _RoutePushSubB1PageState extends State<RoutePushSubB1Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    targetB1 = DateTime.now();
    print('跳轉B目標延遲時間: ${targetB1!.difference(startB!)}');
    super.build(context);
    return Align(
      child: Container(
        decoration: BoxDecoration(color: Colors.blueGrey),
        alignment: Alignment.center,
        child: Text(
          "子頁面B1",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
    );
  }
}
