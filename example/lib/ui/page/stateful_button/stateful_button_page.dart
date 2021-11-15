import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class StatefulButtonPage extends StatefulWidget {
  final RouteOption option;

  StatefulButtonPage(this.option) : super();

  @override
  _StatefulButtonPageState createState() => _StatefulButtonPageState();
}

class _StatefulButtonPageState extends State<StatefulButtonPage> {
  var title = "有狀態的按鈕";
  var content = """
  有狀態的按鈕
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: baseAppBar(title),
      body: Column(
        children: <Widget>[
          TopDesc(content: content),
          Expanded(
            child: _loadingButton(),
          ),
        ],
      ),
    );
  }

  Widget _loadingButton() {
    return Center(
      child: StatefulButton(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(40),
          color: Color(0xffff6464),
        ),
        child: Center(
          child: Text(
            "開始使用",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        loadStyle: StateStyle(color: Colors.white, size: 60),
        initAnimated: false,
        onTap: (controller) {
          print('當前狀態: ${controller.isLoading}');
          if (controller.isLoading) {
            BotToast.showText(text: '正在讀取中, 請稍候');
            return;
          }
          print('點點中');
          controller.setLoad(true);
          Future.delayed(Duration(milliseconds: 500)).then((_) {
            controller.setLoad(false);
          });
        },
      ),
    );
  }
}
