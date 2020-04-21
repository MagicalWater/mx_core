import 'package:flutter/material.dart';
import 'package:annotation_route/route.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub2/route_push_sub_b_bloc.dart';
import 'package:mx_core_example/bloc/application_bloc.dart';

@ARoute(url: Pages.routePushSubB)
class RoutePushSubBPage extends StatefulWidget {
  final RouteOption option;

  RoutePushSubBPage(this.option): super();

  @override
  _RoutePushSubBPageState createState() => _RoutePushSubBPageState();
}

class _RoutePushSubBPageState extends State<RoutePushSubBPage> {
  RoutePushSubBBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushSubBBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: Align(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
          alignment: Alignment.center,
          child: Text(
            "子頁面B",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      ),
    );
  }
}