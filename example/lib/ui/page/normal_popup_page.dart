import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/normal_popup_bloc.dart';
import 'package:mx_core_example/router/route.dart';

import 'introduction_page.dart';

@ARoute(url: Pages.normalPopup)
class NormalPopupPage extends StatefulWidget {
  final RouteOption option;

  NormalPopupPage(this.option) : super();

  @override
  _NormalPopupPageState createState() => _NormalPopupPageState();
}

class _NormalPopupPageState extends State<NormalPopupPage> {
  NormalPopupBloc bloc;

  var title = "一般彈窗";
  var content = """
  彈窗方式有兩種
  
  1. Popup.showRoute
     以 route 方式顯示彈跳視窗(無法使用穿透點擊, 可以視為一個新的頁面, 只是仍然渲染背景)
     
  2. Popup.showOverlay
     以 overlay entry 方式顯示彈跳視窗(可使用穿透點擊)
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<NormalPopupBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: "NormalPopup",
        child: Column(
          children: <Widget>[
            buildIntroduction(content),
            buildRouteButton(),
            buildOverlayButton(),
          ],
        ),
      ),
    );
  }

  /// 構建 route 彈窗按鈕
  Widget buildRouteButton() {
    return RaisedButton(
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
  Widget buildOverlayButton() {
    return RaisedButton(
      child: Text('Overlay Entry彈窗'),
      onPressed: () {
        Popup.showOverlay(
          builder: (controller) => SafeArea(
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
            print('點擊返回');
            controller.remove();
          },
        );
      },
    );
  }
}
