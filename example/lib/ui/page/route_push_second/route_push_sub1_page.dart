import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/route_push_second/route_push_sub1_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.routePushSub1)
class RoutePushSub1Page extends StatefulWidget {
  final RouteOption option;

  RoutePushSub1Page(this.option) : super();

  @override
  _RoutePushSub1PageState createState() => _RoutePushSub1PageState();
}

class _RoutePushSub1PageState extends State<RoutePushSub1Page> {
  RoutePushSub1Bloc bloc;

  var index = 0;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushSub1Bloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.indigoAccent,
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            index++;
            setState(() {});
          },
          child: Text(
            "子頁面1 - $index",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      ),
    );
  }
}
