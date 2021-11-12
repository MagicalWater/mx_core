import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mx_core/mx_core.dart';

class LibEaseRefreshPage extends StatefulWidget {
  final RouteOption option;

  LibEaseRefreshPage(this.option) : super();

  @override
  _LibEaseRefreshPageState createState() => _LibEaseRefreshPageState();
}

class _LibEaseRefreshPageState extends State<LibEaseRefreshPage> {
  EasyRefreshController easyRefreshController = EasyRefreshController();

  @override
  void initState() {
    easyRefreshController = EasyRefreshController();
    Future.delayed(Duration(seconds: 2)).then((_) {
      print("刷1");
      easyRefreshController.callRefresh();
      print("刷2");
      easyRefreshController.finishRefresh();
      print("刷3");
//      easyRefreshController.callRefresh();
//      print("刷4");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh.custom(
        // 是否使用控制器結束刷新, 若為 false, 則默認 [onRefresh] 結束時結束刷新
        enableControlFinishRefresh: false,

        // 是否使用控制器結束加載更多, 若為 false, 則默認 [onLoad] 結束時結束刷新
        enableControlFinishLoad: false,

        // 當顯示空內容元件 [emptyWidget] 時, 在此 index 之上的元件會保留
        // 若設置了首次刷新 [firstRefresh], 此值非為0時會出錯
        headerIndex: 0,

        // 空內容顯示元件
        // 當此值不為空時只顯示此元件, 保留 [headerIndex] 以上的元件
        emptyWidget: null,

        controller: easyRefreshController,
        // 下拉刷新回調, 回彈將會在此 callback 結束後才進行
        onRefresh: () async {
          print("刷新拉");
          await Future.delayed(Duration(seconds: 10));
          // 設置刷新的狀態
          // 當 success 為 false 時, noMore 參數失效
          // 當 noMore 為 true 時, 無法再下拉刷新, 並且顯示沒有更多的文字
//              easyRefreshController.finishRefresh(success: true, noMore: false);

          // 恢復刷新的狀態
//              easyRefreshController.resetRefreshState();
        },
        // 加載更多回調, 回彈將會在此 callback 結束後才進行
        onLoad: () async {
          await Future.delayed(Duration(seconds: 2));
          // 設置加載更多的狀態
          // 當 success 為 false 時, noMore 參數失效
          // 當 noMore 為 true 時, 無法再下拉刷新, 並且顯示沒有更多的文字
          easyRefreshController.finishLoad(success: true, noMore: false);

          // 恢復加載更多的狀態
          easyRefreshController.resetRefreshState();
        },
        // Load 跟 Refresh 狀態獨立
        // 為 true 時, 代表能同時觸發, 否則只能一個
        taskIndependence: true,

        // 下拉刷新相關配置
        header: _header(),

        // 加載更多相關配置
        // 與 ClassicalHeader 參數名稱只差在 Load 與 Refresh, 不再重複說明
        footer: ClassicalFooter(),

        // 頂部回彈
        topBouncing: true,

        // 底部回彈
        bottomBouncing: true,

        // 滾動方向
        scrollDirection: Axis.vertical,

        // 是否初次載入有不同的刷新畫面
        firstRefresh: false,

        firstRefreshWidget: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Loading.roundSpring(duration: 2000),
                    Container(
                      child: Text('asdasdasd'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  height: 300,
                  color: Color.fromARGB(
                    255,
                    Random().nextInt(255),
                    Random().nextInt(255),
                    Random().nextInt(255),
                  ),
                );
              },
              childCount: 2,
            ),
          ),
        ],
      ),
    );
  }

  // 構建一般的 header
  ClassicalHeader _header() {
    return ClassicalHeader(
      // 刷新成功的提示文字
      refreshedText: "又成功了, 老子專業刷新",

      // 刷新中的提示文字
      refreshingText: "媽啊, 我在刷新誒～",

      // 刷新失敗提示文字
      refreshFailedText: "不可能, 我不會失敗！",

      // 放開進行刷新的提示文字
      refreshReadyText: "敢放開我就刷新給你看",

      // 繼續往下拉觸發刷新的提示文字
      refreshText: "再往下拉, 快點！！",

      // 提示文字的備註
      infoText: "提示文字的備註, 就問你怕不怕",

      // 沒有更多時顯示的文字
      noMoreText: "怎沒更多了！ 把更多還我！",

      // Header高
      extent: 100.0,

      // 下拉觸發刷新的高度, 必須比 [extent] 高
      triggerDistance: 150,

      // 完成後延時多久回彈
      completeDuration: Duration(seconds: 2),

      // 啟動無限刷新
      // 開啟時, 下拉刷新後, 不會回彈
      // 並且每次滑動到頂部都會直接觸發刷新
      enableInfiniteRefresh: true,

      // 是否開啟震動回饋
      enableHapticFeedback: true,

      // 暫無任何作用
      float: false,
    );
  }
}
