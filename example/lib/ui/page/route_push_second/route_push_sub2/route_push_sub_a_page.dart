import 'package:flutter/material.dart';
import 'package:mx_core_example/router/router.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_a_bloc.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';

class RoutePushSubAPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubAPage(this.option): super();

  @override
  _RoutePushSubAPageState createState() => _RoutePushSubAPageState();
}

class _RoutePushSubAPageState extends State<RoutePushSubAPage>  with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late RoutePushSubABloc bloc;

  @override
  void initState() {
    bloc = PageRouteBuilder.of<RoutePushSubABloc>(context)!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: Align(
        child: Container(
          decoration: BoxDecoration(color: Colors.brown),
          alignment: Alignment.center,
          child: Text(
            "子頁面A",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      ),
    );
  }
}