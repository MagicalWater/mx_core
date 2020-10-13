import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/line_indicator_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.lineIndicator)
class LineIndicatorPage extends StatefulWidget {
  final RouteOption option;

  LineIndicatorPage(this.option) : super();

  @override
  _LineIndicatorPageState createState() => _LineIndicatorPageState();
}

class _LineIndicatorPageState extends State<LineIndicatorPage> {
  LineIndicatorBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<LineIndicatorBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: "LineIndicator",
        child: Container(
//          color: Colors.blueAccent,
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
//                LineIndicator(
//                  color: Colors.green,
//                  start: 0.2,
//                  end: 0.5,
//                ),
              LineIndicator(
                color: Colors.blue,
                start: 0.1,
                end: 1,
                size: 10.scaleA,
                direction: Axis.vertical,
                alignment: Alignment.topRight,
                duration: Duration(seconds: 5),
                appearAnimation: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
