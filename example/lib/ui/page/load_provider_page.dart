import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/load_provider_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

/// 展示load提供元件
@ARoute(url: Pages.loadProvider)
class LoadProviderPage extends StatefulWidget {
  final RouteOption option;

  LoadProviderPage(this.option) : super();

  @override
  _LoadProviderPageState createState() => _LoadProviderPageState();
}

class _LoadProviderPageState extends State<LoadProviderPage> {
  LoadProviderBloc bloc;
  LoadController loadController;

  var title = "Load提供元件";
  var content = """
  Load提供元件
  1. 接受 stream 或者 controller 方式顯示讀取
  2. 可1個LoadProvider對應多個顯示Load的元件
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<LoadProviderBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      style: LoadStyle(
        tapThrough: true,
        maskColor: Colors.blueAccent.withAlpha(100),
      ),
      onCreated: (controller) {
        loadController = controller;
      },
      child: PageScaffold(
        title: title,
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            buildIntroduction(content),
            buildLoadableContainer(0),
            buildLoadableContainer(1),
            buildLoadableContainer(2),
          ],
        ),
      ),
    );
  }

  Widget buildLoadableContainer(int index) {
    BuildContext currentContext;
    return MaterialLayer.single(
      layer: LayerProperties(
        margin: EdgeInsets.only(left: 20, top: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color(0xff8c6018),
              Color(0xff8c6018),
            ],
          ),
        ),
      ),
      child: Builder(
        builder: (context) {
          currentContext = context;
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              "點擊 ${loadController.isShowing() ? "隱藏" : "顯示"} 讀取元件",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          );
        },
      ),
      onTap: () {
        loadController.toggle(attach: currentContext);
        setState(() {});
      },
    );
  }
}
