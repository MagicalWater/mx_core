part of 'introduction_cubit.dart';

@immutable
abstract class IntroductionState {
  final List<PageInfo> pageRoutes;

  IntroductionState(this.pageRoutes);
}

class IntroductionInitial extends IntroductionState {
  IntroductionInitial()
      : super([
          PageInfo(Pages.kChart, "行情圖表"),
          PageInfo(Pages.bulletShape, "彈頭渲染"),
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
        ]);
}
