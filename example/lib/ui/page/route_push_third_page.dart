import 'package:mx_core_example/router/router.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/route_push_third_bloc.dart';

class RoutePushThirdPage extends StatefulWidget {
  final RouteOption option;

  RoutePushThirdPage(this.option) : super();

  @override
  _RoutePushThirdPageState createState() => _RoutePushThirdPageState();
}

class _RoutePushThirdPageState extends State<RoutePushThirdPage> {
  RoutePushThirdBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<RoutePushThirdBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: "RoutePushThird",
        child: Container(
          child: RaisedButton(
            onPressed: () {
//              bloc.popAndPushPage(route, context)
            },
            child: Text('回退到上個頁面的紫頁面'),
          ),
        ),
      ),
    );
  }
}
