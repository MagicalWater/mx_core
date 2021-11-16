import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class NormalPopupPage extends StatefulWidget {
  final RouteOption option;

  NormalPopupPage(this.option) : super();

  @override
  _NormalPopupPageState createState() => _NormalPopupPageState();
}

class _NormalPopupPageState extends State<NormalPopupPage> {
  var title = "一般彈窗";
  var content = """
  彈窗方式有兩種
  
  1. Popup.showRoute
     以 route 方式顯示彈跳視窗(無法使用穿透點擊, 可以視為一個新的頁面, 只是仍然渲染背景)
     
  2. Popup.showOverlay
     以 overlay entry 方式顯示彈跳視窗(可使用穿透點擊)
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar('NormalPopup'),
      body: InkWell(
        onTap: () {
          print('背景');
        },
        child: Column(
          children: <Widget>[
            TopDesc(content: content),
            routeButton(),
            overlayButton(),
          ],
        ),
      ),
    );
  }

  /// 構建 route 彈窗按鈕
  Widget routeButton() {
    return ElevatedButton(
      child: Text('Route彈窗'),
      onPressed: () {
        Popup.showRoute(
          builder: (controller) => SafeArea(
            child: Align(
              child: Container(
                width: 200,
                height: 200,
                child: Center(child: Text('這是Route彈窗')),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(),
                  ],
                ),
              ),
            ),
          ),
          option: PopupOption(
            maskColor: Colors.redAccent.withAlpha(100),
            alignment: Alignment.center,
          ),
          onTapSpace: (controller) {
            print('點擊空白處');
            controller.remove();
          },
          onTapBack: (controller) {
            print('點擊返回');
            controller.remove();
          },
        );
      },
    );
  }

  /// 構建 overlay entry 彈窗按鈕
  Widget overlayButton() {
    return ElevatedButton(
      child: Text('Overlay Entry彈窗'),
      onPressed: () {
        Popup.showOverlay(
          builder: (controller) => GestureDetector(
            onTap: () {
              print('嗨嗨');
            },
            child: SafeArea(
              child: Align(
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(child: Text('Overlay Entry彈窗')),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          hitRule: HitRule.intercept,
          option: PopupOption(
            maskColor: Colors.blueAccent.withAlpha(100),
            alignment: Alignment.center,
          ),
          onTapSpace: (controller) {
            print('點擊空白處');
            controller.remove();
          },
          onTapBack: (controller) {
            print('點擊返回11');
            controller.remove();
            print('點擊返回22');
          },
        );
      },
    );
  }
}
