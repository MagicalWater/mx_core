import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/loading_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

/// 展示讀取動畫
@ARoute(url: Pages.loading)
class LoadingPage extends StatefulWidget {
  final RouteOption option;

  LoadingPage(this.option) : super();

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  LoadingBloc bloc;

  var title = "讀取動畫";
  var content = """
  讀取動畫
  1. 現有 ${LoadingType.values.length} 種讀取動畫
  2. LoadingProvider 讀取提供元件默認使用 Ball
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<LoadingBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      color: Colors.white,
      title: title,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            buildIntroduction(content),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 3,
                  children:
                      LoadingType.values.map((e) => buildLoading(e)).toList(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading(LoadingType type) {
    switch (type) {
      // case LoadingType.spring:
      //   return buildSpring();
      //   break;
      // case LoadingType.roundSpring:
      //   return buildRoundSpring();
      //   break;
      case LoadingType.circle:
        return buildCircle();
        break;
      default:
        break;
    }
    return Container();
  }

  Widget buildSpring() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.spring(
        color: Color(0xffac8048),
        size: 20,
        duration: 500,
      ),
    );
  }

  Widget buildRoundSpring() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.roundSpring(
        ballCount: 2,
        color: Color(0xffac8048),
        size: 20,
        duration: 1000,
      ),
    );
  }

  Widget buildCircle() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Loading.circle(
        color: Color(0xffac8048),
        size: 50,
        duration: 1000,
        headCount: 1,
      ),
    );
  }
}

enum LoadingType {
  spring,
  roundSpring,
  circle,
}
