import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

/// 展示load提供元件
class LoadProviderPage extends StatefulWidget {
  final RouteOption option;

  LoadProviderPage(this.option) : super();

  @override
  _LoadProviderPageState createState() => _LoadProviderPageState();
}

class _LoadProviderPageState extends State<LoadProviderPage> {
  LoadController loadController = LoadController();

  var title = "Load提供元件";
  var content = """
  Load提供元件
  1. 接受 stream 或者 controller 方式顯示讀取
  2. 可1個LoadProvider對應多個顯示Load的元件
  """;

  bool singleLoadValue = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      style: LoadStyle(
        maskColor: Colors.blueAccent.withAlpha(100),
      ),
      tapThrough: true,
      controller: loadController,
      child: Scaffold(
        appBar: baseAppBar(title),
        backgroundColor: Colors.black,
        body: ListView(
          children: <Widget>[
            TopDesc(content: content),
            _withValue(),
            _withContainer(0),
            _withContainer(1),
            _withContainer(2),
          ],
        ),
      ),
    );
  }

  Widget _withValue() {
    return LoadProvider.value(
      value: singleLoadValue,
      tapThrough: true,
      style: LoadStyle(
        maskColor: Colors.blueAccent.withAlpha(100),
      ),
      child: MaterialLayer.single(
        layer: LayerProperties(
          margin: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Color(0xff8c6018), Color(0xff8c6018)],
            ),
          ),
        ),
        child: Builder(
          builder: (context) {
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                "點擊 ${singleLoadValue ? "隱藏" : "顯示"} 讀取元件",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            );
          },
        ),
        onTap: () {
          singleLoadValue = !singleLoadValue;
          setState(() {});
        },
      ),
    );
  }

  Widget _withContainer(int index) {
    late BuildContext currentContext;
    return MaterialLayer.single(
      layer: LayerProperties(
        margin: EdgeInsets.only(left: 20, top: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Color(0xff8c6018), Color(0xff8c6018)],
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
      },
    );
  }
}
