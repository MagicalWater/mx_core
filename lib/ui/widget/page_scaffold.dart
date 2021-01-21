import 'package:flutter/material.dart';
import 'package:mx_core/util/screen_util.dart';

import 'load_provider.dart';

/// 漸變顏色角度
AlignmentGeometry _defaultLinearBgBegin = Alignment.topCenter;
AlignmentGeometry _defaultLinearBgEnd = Alignment.bottomCenter;

/// 默認線性漸變顏色背景
List<Color> _defaultLinearBg = [Colors.white];

/// 默認 background, 優先度在 _defaultLinearBg 之上
WidgetBuilder _defaultBackgroundBuilder;

/// 默認 menu
WidgetBuilder _defaultMenuBuilder;

typedef PreferredSizeWidgetBuilder = PreferredSizeWidget Function(
  BuildContext context,
  Widget leading,
  String title,
  List<Widget> actions,
);

/// 默認 appBar
PreferredSizeWidgetBuilder _defaultAppBarBuilder;

/// 頁面基礎元件
class PageScaffold extends StatelessWidget {
  final Widget child;

  /// appBar的 leading, 當 [appBar] 有值時失效
  final Widget leading;

  /// 純文字抬頭, 當 [appBar] 有值時失效
  final String title;

  /// 抬頭元件, 優先於 [title]
  final PreferredSizeWidget appBar;

  /// loading 狀態顯示的 loading 元件大小
  final double loadSize;

  /// loading 狀態顯示的 loading 元件顏色
  final Color loadColor;

  /// loading 狀態串流, 以此控制loading狀態
  final Stream<bool> loadStream;

  /// 是否有 menu
  final bool showMenu;

  /// 是否有 appBar
  final bool showAppBar;

  /// 開啟 [menu] 時的背景遮罩顏色
  final Color drawerScrimColor;

  /// appBar 的 action
  /// 只有 呼叫了 [PageScaffold.setDefaultAppBar] 後才有效
  final List<Widget> actions;

  /// 背景顏色, 當 [background] 有值時失效
  final Color color;

  /// 背景元件, 優先於 [color]
  final Widget background;

  /// 側邊欄元件
  final Widget menu;

  /// 是否會因為鍵盤的盤出影響到布局
  /// 默認為 true
  final bool resizeToAvoidBottomPadding;

  /// 下方導航欄
  final Widget bottomNavigationBar;

  /// 背景是否蓋住 app bar
  final bool backgroundCoverAppbar;

  PageScaffold._({
    @required this.child,
    this.showMenu = true,
    this.showAppBar = true,
    this.loadStream,
    this.loadSize,
    this.loadColor,
    this.color,
    this.appBar,
    this.menu,
    this.leading,
    this.title,
    this.background,
    this.backgroundCoverAppbar,
    this.drawerScrimColor,
    this.resizeToAvoidBottomPadding,
    this.bottomNavigationBar,
    this.actions,
  });

  factory PageScaffold({
    Widget child,
    bool haveMenu = true,
    bool haveAppBar = true,
    Color color,
    PreferredSizeWidget appBar,
    Widget menu,
    Widget leading,
    String title,
    Widget background,
    bool backgroundCoverAppbar = false,
    Color drawerScrimColor,
    bool resizeToAvoidBottomPadding = true,
    Widget bottomNavigationBar,
    List<Widget> actions,
  }) {
    // 假如有帶入 appbar 或 menu, 則對應的 haveAppBar 即 haveMenu 強制設定為 true
    if (appBar != null) haveAppBar = true;
    if (menu != null) haveMenu = true;

    return PageScaffold._(
      child: child,
      showAppBar: haveAppBar,
      showMenu: haveMenu,
      color: color,
      appBar: appBar,
      menu: menu,
      leading: leading,
      title: title,
      background: background,
      backgroundCoverAppbar: backgroundCoverAppbar,
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      drawerScrimColor: drawerScrimColor,
      bottomNavigationBar: bottomNavigationBar,
      actions: actions,
    );
  }

  /// 預設背景元件, [builder] 優先度大於 [colors]
  /// [colors] - 線性漸變背景
  /// [builder] - 元件構建類
  static void setDefaultBackground({
    List<Color> linearColors = const [],
    AlignmentGeometry linearBegin = Alignment.topCenter,
    AlignmentGeometry linearEnd = Alignment.bottomCenter,
    WidgetBuilder builder,
  }) {
    if (linearColors.isEmpty) {
      _defaultLinearBg = [Colors.transparent];
    } else {
      _defaultLinearBg = linearColors;
    }
    _defaultLinearBgBegin = linearBegin;
    _defaultLinearBgEnd = linearEnd;
    _defaultBackgroundBuilder = builder;
  }

  static void setDefaultMenu(WidgetBuilder builder) {
    _defaultMenuBuilder = builder;
  }

  /// 設置預設 appBar
  /// 其中 build 的 title 參數
  /// * 若是帶 title, 則會包裝成 Text
  /// * 若是帶 titleWidget, 則直接傳入
  static void setDefaultAppBar(PreferredSizeWidgetBuilder builder) {
    _defaultAppBarBuilder = builder;
  }

  @override
  Widget build(BuildContext context) {
    final menuShow = showMenu && (menu != null || _defaultMenuBuilder != null);
    final appBarShow = showAppBar &&
        (appBar != null || _defaultAppBarBuilder != null || title != null);

    // 最後顯示的 menu
    Widget lastShowMenu;
    if (menuShow) {
      lastShowMenu = menu ?? _defaultMenuBuilder(context);
    }

    // 最後顯示的 appBar
    PreferredSizeWidget lastShowAppBar;
    if (appBarShow) {
      if (appBar != null) {
        lastShowAppBar = appBar;
      } else {
        lastShowAppBar = _defaultAppBarBuilder(
          context,
          leading,
          title ?? "",
          actions,
        );
      }
    }

    Widget backgroundWidget;

    if (background != null) {
      // 有背景元件
      backgroundWidget = background;
    } else if (color != null) {
      // 有背景顏色
      backgroundWidget = Container(
        color: color,
      );
    } else if (_defaultBackgroundBuilder != null) {
      // 使用預設背景元件構建類
      backgroundWidget = _defaultBackgroundBuilder(context);
    } else if (!(_defaultLinearBg.length == 1 &&
        _defaultLinearBg[0] == Colors.transparent)) {
      // _defaultLinearBg 不為空, 並且不是只有單值且顏色為透明
      if (_defaultLinearBg.length == 1) {
        // 只有單顏色, 使用 color
        backgroundWidget = Container(
          color: _defaultLinearBg[0],
        );
      } else {
        backgroundWidget = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _defaultLinearBgBegin,
              end: _defaultLinearBgEnd,
              colors: _defaultLinearBg,
            ),
          ),
        );
      }
    }

//    print("是否顯示appbar = ${lastShowAppBar}");

    Widget bodyWidget = Scaffold(
      drawerScrimColor: drawerScrimColor,
      backgroundColor: Colors.transparent,
      drawer: lastShowMenu,
      appBar: lastShowAppBar,
      resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );

    if (loadStream != null) {
      bodyWidget = LoadProvider(
        child: bodyWidget,
        loadStream: loadStream,
        style: LoadStyle(
          color: loadColor ?? Colors.blueAccent,
          size: loadSize ?? 50,
        ),
      );
    }

    List<Widget> showWidgets = [];
    if (backgroundWidget != null) {
      if (!backgroundCoverAppbar && appBar != null) {
        backgroundWidget = Container(
          padding: EdgeInsets.only(
            top: appBar.preferredSize.height + Screen.statusBarHeight,
          ),
          child: backgroundWidget,
        );
      }
      showWidgets.add(backgroundWidget);
    }

    showWidgets.add(bodyWidget);

    return Stack(
      fit: StackFit.expand,
      children: showWidgets,
    );
  }
}
