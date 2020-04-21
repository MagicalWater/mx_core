
/// page 在此處定義
/// 會自動創建 bloc route_mixin page
class Pages {
  /// 介紹頁(入口頁)
  static const introduction = "/introduction";

  /// 輔助按鈕
  static const assistTouch = "/assistTouch";

  /// 座標佈局
  static const coordinateLayout = "/coordinateLayout";

  /// 讀取動畫
  static const loading = "/loading";

  /// loading提供元件
  static const loadProvider = "/loadProvider";

  /// 跑馬燈
  static const marquee = "/marquee";

  /// 粒子動畫
  static const particleAnimation = "/particleAnimation";

  /// 倒數計時
  static const timer = "/timer";

  /// SliverView 列表元件
  static const sliver = "/sliver";

  /// 動畫核心
  static const animatedCore = "/animatedCore";

  /// 箭頭容器
  static const arrowContainer = "/arrowContainer";

  /// 一般彈窗
  static const normalPopup = "/normalPopup";

  /// 箭頭彈窗
  static const arrowPopup = "/arrowPopup";

  /// 路由頁面跳轉 大頁面入口
  static const routePushEntry = "/routePushEntry";

  /// 路由頁面跳轉 第二大頁面
  static const routePushSecond = "/routePushSecond";

  /// 路由頁面跳轉 第二大頁面 => 子頁面1
  static const routePushSub1 = "$routePushSecond/routePushSub1";

  /// 路由頁面跳轉 第二大頁面 => 子頁面2
  static const routePushSub2 = "$routePushSecond/routePushSub2";

  /// 路由頁面跳轉 第二大頁面 => 子頁面2 => 子頁面a
  static const routePushSubA = "$routePushSub2/routePushSubA";

  /// 路由頁面跳轉 第二大頁面 => 子頁面2 => 子頁面b
  static const routePushSubB = "$routePushSub2/routePushSubB";

  /// 路由頁面跳轉 第二大頁面 => 子頁面3
  static const routePushSub3 = "$routePushSecond/routePushSub3";

  /// 路由頁面跳轉 第三大頁面
  static const routePushThird = "/routePushThird";

  /// 擁有讀取狀態的按鈕
  static const statefulButton = "/statefulButton";

  /// 波浪進度條
  static const waveProgress = "/waveProgress";

  /// 測試頁
  static const test = "/test";

  /// 刷新元件 refreshView
  static const refreshView = "/refreshView";

  /// 介紹第三方庫 flutter_easyrefresh
  static const libEaseRefresh = "/libEaseRefresh";

  /// SpanGrid
  static const spanGrid = "/spanGrid";

  Pages._();
}

/// bloc 需要從 router 取用的 query key
class BlocKeys {
  static const exKey = "exKey";

  BlocKeys._();
}

/// page 需要從 router 取用的 query key
class PageKeys {
  static const exKey = "exKey";

  PageKeys._();
}