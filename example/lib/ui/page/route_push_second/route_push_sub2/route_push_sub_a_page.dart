import 'package:flutter/material.dart';
import 'package:annotation_route/route.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_a_bloc.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';

@ARoute(url: Pages.routePushSubA)
class RoutePushSubAPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubAPage(this.option): super();

  @override
  _RoutePushSubAPageState createState() => _RoutePushSubAPageState();
}

class _RoutePushSubAPageState extends State<RoutePushSubAPage> {
  RoutePushSubABloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushSubABloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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