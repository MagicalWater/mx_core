import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/app_bloc.dart';
import 'package:mx_core_example/bloc/page/introduction_bloc.dart';

import '../../router/route.dart';

List<String> autoPushPage = [
//  Pages.test,
];

/// 功能介紹頁面
@ARoute(url: Pages.introduction)
class IntroductionPage extends StatefulWidget {
  final RouteOption option;

  IntroductionPage(this.option) : super();

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  IntroductionBloc bloc;

  List<PageInfo> textMap = [
    PageInfo(Pages.test, "測試頁面"),
    PageInfo(Pages.lineIndicator, "線條指示器"),
    PageInfo(Pages.tabBar, "Tab元件"),
    PageInfo(Pages.spanGrid, "空間切割佈局"),
    PageInfo(Pages.coordinateLayout, "座標佈局"),
    PageInfo(Pages.assistTouch, "輔助按鈕"),
    PageInfo(Pages.loading, "讀取動畫"),
    PageInfo(Pages.loadProvider, "Load元件提供器"),
    PageInfo(Pages.marquee, "跑馬燈"),
    PageInfo(Pages.particleAnimation, "粒子動畫"),
    PageInfo(Pages.timer, "倒數計時"),
    PageInfo(Pages.animatedCore, "動畫核心"),
    PageInfo(Pages.arrowContainer, "箭頭容器"),
    PageInfo(Pages.arrowPopup, "箭頭彈窗"),
    PageInfo(Pages.normalPopup, "一般彈窗"),
    PageInfo(Pages.routePushEntry, "頁面跳轉機制"),
    PageInfo(Pages.statefulButton, "有讀取狀態的按鈕"),
    PageInfo(Pages.waveProgress, "波浪進度條"),
    PageInfo(Pages.refreshView, "刷新元件"),
    PageInfo(Pages.libEaseRefresh, "第三方庫: 列表元件 flutter_easyrefresh"),
  ];

  @override
  void initState() {
    bloc = BlocProvider.of<IntroductionBloc>(context);
    if (autoPushPage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleIntroductionTap(autoPushPage[0]);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "展示列表",
      color: Colors.black,
      child: Container(
        child: SingleChildScrollView(
          child: Wrap(
            children: textMap.map((e) => _buildButton(e)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    PageInfo pageInfo,
  ) {
    return AnimatedComb(
      child: Container(
        width: (Screen.width - 48) / 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff2b9eda),
              Color(0xff68c3fb),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
        padding: EdgeInsets.all(12),
        child: Text(
          pageInfo.desc,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      type: AnimatedType.tap,
      duration: 1000,
      curve: Curves.elasticOut,
      animatedList: [
        Comb.scale(end: Size.square(0.8)),
      ],
      onTap: () {
        var i = 0;
        assert(i == 0);
        _handleIntroductionTap(pageInfo.page);
      },
    );
  }

  void _handleIntroductionTap(String page) {
    print('點跳跳: $page');
    AppBloc().pushPage(page);
  }

  @override
  void deactivate() {
    print('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }
}

/// 構建說明文字
Widget buildIntroduction(String content) {
  return InfoPopup(
    child: FractionallySizedBox(
      widthFactor: 1,
      child: AnimatedComb.quick(
        scale: Comb.scale(begin: Size.zero, end: Size.square(1)),
        type: AnimatedType.once,
        duration: 2000,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff2b9eda),
                Color(0xff68c3fb),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          child: Text(
            content,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        curve: Curves.elasticOut,
      ),
    ),
  );
}

class PageInfo {
  String desc;
  String page;

  PageInfo(this.page, this.desc);
}
