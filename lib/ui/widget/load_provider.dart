//import 'dart:async';
//import 'dart:math';
//
//import 'package:flutter/material.dart';
//import 'package:mx_core/mx_core.dart';
//import 'package:mx_core/popup/controller.dart';
//
///// 根節點的 loadController
//LoadController _rootLoadController;
//
///// 設置根節點的 load 顯示與否
//Future<void> setRootLoad(
//  bool show, {
//  BuildContext context,
//  String tag,
//  double size,
//  Color color,
//  bool tapThrough,
//  Duration animationDuration = const Duration(milliseconds: 500),
//}) async {
//  if (_rootLoadController == null) {
//    print("找不到根節點的 load, 設置失效");
//  } else {
//    if (show) {
//      await _rootLoadController.show(
//        context: context,
//        tag: tag,
//        size: size,
//        color: color,
//        tapThrough: tapThrough,
//        animationDuration: animationDuration,
//      );
//    } else {
//      await _rootLoadController.hide(tag: tag);
//    }
//  }
//}
//
///// 根節點的 load_provider 是否已經初始化完成
//bool _isRootLoadInitSuccess = false;
//
///// loading 元件提供元件
///// <p> 有兩種方法可以控制 loading 的顯示隱藏 </p>
///// 1. 透過 onCreated 獲取 LoadController, 對 LoadController 進行操作
/////   * 較麻煩, 但是可以針對每個 loading 附加 tag 以及 context 進行更細部的操作
///// 2. 透過 Stream 直接下達命令
/////   * 較簡單, 但是只能有一個 loading, 並且無法進行較細部的配置(例如 size / 位置)
//class LoadProvider extends StatefulWidget {
//  final Widget child;
//  final void Function(LoadController controller) onCreated;
//  final Stream<bool> loadStream;
//
//  /// 是否放置在根節點
//  final bool root;
//
//  final LoadStyle style;
//
//  /// 初始化後經過多少時間才可以正常顯示
//  /// 防止元件上未初始化完成size的問題
//  final Duration waitInit;
//
//  LoadProvider({
//    this.child,
//    this.onCreated,
//    this.loadStream,
//    this.root = false,
//    this.waitInit,
//    this.style,
//  });
//
//  @override
//  _LoadProviderState createState() => _LoadProviderState();
//}
//
//class _LoadProviderState extends State<LoadProvider> implements LoadController {
//  String _defaultTag = "LoadProvider Default Tag";
//  Map<String, Future<PopupController>> loadingEntrys = {};
//
//  GlobalKey<OverlayState> overlayKey;
//
//  DateTime createTime;
//
//  LoadStyle _currentStyle;
//
//  @override
//  void initState() {
//    _currentStyle = widget.style ?? LoadStyle();
//    createTime = DateTime.now();
//    if (widget.root) {
//      overlayKey = GlobalKey();
//      _rootLoadController = this;
//      if (!_isRootLoadInitSuccess) {
//        WidgetsBinding.instance
//            .addPostFrameCallback((_) => _isRootLoadInitSuccess = true);
//      }
//    }
//
//    if (widget.onCreated != null) {
//      widget.onCreated(this);
//    }
//
//    widget.loadStream?.listen((e) {
//      if (e) {
//        show();
//      } else {
//        hide();
//      }
//    });
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (widget.root) {
//      // 如果此 load provider 加在根節點
//      // 則在顯示 loading 時, 無法使用 Overlay.of(context) 取得 OverlayState
//      // 因為 context 為根, 並且網上沒有 Overlay
//      // 因此需要在此放入 Overlay 元件, 並透過 global key 取得 OverlayState
//      // 而最外層的 Directionality 則是因為 Overlay 沒有基本需要的文字方向屬性
//      // 若 Overlay 直接放在根節點會出現 direction = null 的錯誤
//      // 因此最外層再包入 Directionality
//      return Directionality(
//        textDirection: TextDirection.ltr,
//        child: Overlay(
//          key: overlayKey,
//          initialEntries: [
//            OverlayEntry(builder: (context) => widget.child),
//          ],
//        ),
//      );
//    } else {
//      return widget.child;
//    }
//  }
//
//  @override
//  void dispose() {
//    loadingEntrys.values.forEach((e) async {
//      (await e)?.remove();
//    });
//    loadingEntrys.clear();
//    super.dispose();
//  }
//
//  @override
//  bool isShowing({String tag}) {
//    var entryTag = tag ?? _defaultTag;
//    return loadingEntrys.containsKey(entryTag) &&
//        loadingEntrys[entryTag] != null;
//  }
//
//  @override
//  Future<void> toggle({BuildContext context, String tag}) {
//    if (isShowing(tag: tag)) {
//      return hide(tag: tag);
//    } else {
//      return show(context: context, tag: tag);
//    }
//  }
//
//  @override
//  Future<void> show({
//    BuildContext context,
//    String tag,
//    double size,
//    Color color,
//    bool tapThrough,
//    Duration animationDuration = const Duration(milliseconds: 500),
//  }) async {
//    if (widget.waitInit != null) {
//      // 如果距離剛創建時間不夠, 則進行等待
//      var nowTime = DateTime.now();
//      var duration = nowTime.difference(createTime);
//      if (duration < widget.waitInit) {
////      print("創建時間未達 ${widget.waitInit}, (當前 ${duration.inMilliseconds}毫秒), 等待後顯示");
//        await Future.delayed(widget.waitInit - duration);
//      } else {
////      print("創建時間超過 ${widget.waitInit}, 可以正常顯示");
//      }
//    }
//
//    await hide(tag: tag);
//
//    // 假如是根節點load的話
//    // 會使用 overlayKey 獲取 OverlayState 進行 浮出視窗的顯示
//    // 因此在這邊進行等待 render(代表 globalKey 賦予給 widget 並渲染完成)
//    if (widget.root && !_isRootLoadInitSuccess) {
//      await _waitWidgetRender();
//      _isRootLoadInitSuccess = true;
//    }
//
//    var entry = _showLoading(
//      context ?? this.context,
//      overlayState: overlayKey?.currentState,
//      size: size ?? _currentStyle.size,
//      color: color ?? _currentStyle.color,
//      tapThrough: tapThrough ?? _currentStyle.tapThrough,
//      animationDuration: animationDuration ?? _currentStyle.animationDuration,
//    );
//    loadingEntrys[tag ?? _defaultTag] = entry;
//  }
//
//  @override
//  Future<void> hide({String tag}) async {
//    var entryTag = tag ?? _defaultTag;
//    if (loadingEntrys.containsKey(entryTag)) {
//      var entry = loadingEntrys.remove(entryTag);
//      (await entry)?.remove();
//    }
//  }
//}
//
//abstract class LoadController {
//  /// 當前是某正在顯示中
//  bool isShowing({String tag});
//
//  /// 切換loading開關
//  Future<void> toggle({
//    BuildContext context,
//    String tag,
//  });
//
//  /// [tag] => 給此次顯示的 load 加上 tag
//  /// [size] => loading 元件的大小
//  /// [color] => loading 元件的顏色
//  /// [tapThrough] => 點擊穿透, 默認 false
//  /// /// [animationDuration] => 顯示/隱藏的動畫時間
//  Future<void> show({
//    BuildContext context,
//    String tag,
//    double size,
//    Color color,
//    bool tapThrough,
//    Duration animationDuration,
//  });
//
//  Future<void> hide({String tag});
//}
//
///// 提供給外部快捷顯示 loading 的方式
/////
///// 為了 loading 的生命週期, 建議使用 [LoadProvider]
/////
///// [size] => loading 元件的大小
///// [color] => loading 元件的顏色
///// [tapThrough] => 點擊穿透, 默認 false
///// [animationDuration] => 顯示/隱藏的動畫時間
//Future<OverlayController> showLoading(
//  BuildContext context, {
//  double size = 50,
//  Color color = Colors.blueAccent,
//  bool tapThrough = false,
//  Duration animationDuration = const Duration(milliseconds: 500),
//}) async {
//  return await _showLoading(
//    context,
//    size: size,
//    color: color,
//    tapThrough: tapThrough,
//    animationDuration: animationDuration,
//  );
//}
//
///// 與 showLoading 相比多了 overlayState
///// 目的是為了當 context 的元件為根節點時, 無法透過 Overlay.of(context) 取得 state
///// 當 視窗建立失敗, 則回傳 null
//Future<PopupController> _showLoading(
//  BuildContext context, {
//  OverlayState overlayState,
//  double size = 50,
//  Color color = Colors.blueAccent,
//  bool tapThrough = false,
//  Duration animationDuration = const Duration(milliseconds: 500),
//}) async {
//  Screen.init();
//
//  var loadingOverlay = OverlayController();
//  AnimatedSyncTick sync = AnimatedSyncTick.identity(
//    type: AnimatedType.toggle,
//    initToggle: true,
//  );
//  loadingOverlay.registerController(sync);
//
//  size ??= 50;
//  color ??= Colors.blueAccent;
//  tapThrough ??= false;
//
//  RenderBox selfBox = context.findRenderObject();
//  if (selfBox == null || !selfBox.hasSize) {
//    print("box 為 null 或尚未有 size, 進行等待");
//    await _waitWidgetRender();
//    selfBox = context.findRenderObject();
//  }
//
//  RenderBox parentScrollBox = context
//      .findAncestorStateOfType<ScrollableState>()
//      ?.context
//      ?.findRenderObject();
//
//  var selfPos = selfBox.localToGlobal(Offset.zero);
//  var selfSize = selfBox.size;
//  var parentSize = parentScrollBox?.size;
////  print("檢測 兒子 size = $selfSize, pos = $selfPos");
//
//  if (parentSize != null) {
//    var parentPos = parentScrollBox.localToGlobal(Offset.zero);
//    var parentSize = parentScrollBox.size;
//
//    var left = max(selfPos.dx, parentPos.dx);
//    var top = max(selfPos.dy, parentPos.dy);
//
//    var right = min(
//      selfPos.dx + selfSize.width,
//      parentPos.dx + parentSize.width,
//    );
//
//    var bottom = min(
//      selfPos.dy + selfSize.height,
//      parentPos.dy + parentSize.height,
//    );
//
////    print("檢測 父親 size = $parentSize, pos = $parentPos");
//
//    selfPos = Offset(left, top);
//    selfSize = Size(right - left, bottom - top);
//  }
//
////  print("檢測 顯示: size = $selfSize, size = $selfPos");
//
//  // 生成 overlay entrys
//  var entry = OverlayEntry(
//    builder: (context) {
////      print("create");
//      if (tapThrough) {
//        return Positioned(
//          left: selfPos.dx + (selfSize.width / 2) - (size / 2),
//          top: selfPos.dy + (selfSize.height / 2) - (size / 2),
//          child: AnimatedComb(
//            sync: sync,
//            animatedList: [
//              Comb.parallel(
//                duration: 700,
//                curve: Curves.easeInOutCubic,
//                animatedList: [
//                  Comb.opacity(begin: 0),
//                  Comb.scale(begin: Size.zero),
//                ],
//              ),
//            ],
//            child: Loading.circle(
//              color: color,
//              size: size,
//            ),
//          ),
//        );
//      } else {
//        return Positioned(
//          left: selfPos.dx,
//          top: selfPos.dy,
//          child: AnimatedComb(
//            sync: sync,
//            animatedList: [
//              Comb.parallel(
//                duration: 700,
//                curve: Curves.elasticInOut,
//                animatedList: [
//                  Comb.opacity(begin: 0),
//                  Comb.scale(begin: Size.zero),
//                ],
//              ),
//            ],
//            child: Container(
//              width: selfSize.width,
//              height: selfSize.height,
//              alignment: Alignment.center,
//              color: Colors.transparent,
//              child: Loading.circle(
//                color: color,
//                size: size,
//              ),
//            ),
//          ),
//        );
//      }
//    },
//  );
//
//  if (overlayState == null) {
//    overlayState = Overlay.of(context);
//    if (overlayState == null) {
//      print(
//          "警告 - loading 顯示錯誤, Overlay.of(context) 為 null, 若 Loading 元件處於入口點, 請將 LoadProvider.root 參數設置為 true");
//    }
//  }
//
//  overlayState?.insert(entry);
//
//  if (overlayState == null) {
//    return null;
//  } else {
//    loadingOverlay.setEntry(entry);
//    return loadingOverlay;
//  }
//}
//
///// 等待元件渲染
//Future<void> _waitWidgetRender() async {
//  var waitRender = Completer<void>();
//  WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
//    waitRender.complete(null);
//  });
//  return waitRender.future;
//}
//
//class LoadStyle {
//  /// loading 元件的大小
//  final double size;
//
//  /// loading 元件的顏色
//  final Color color;
//
//  /// 點擊穿透, 默認 false
//  final bool tapThrough;
//
//  /// 顯示/隱藏的動畫時間
//  final Duration animationDuration;
//
//  /// 背景遮罩顏色
//  final Color maskColor;
//
//  LoadStyle({
//    this.size = 50,
//    this.color = Colors.blueAccent,
//    this.tapThrough = false,
//    this.animationDuration = const Duration(milliseconds: 500),
//    this.maskColor,
//  });
//}
