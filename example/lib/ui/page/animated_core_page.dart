import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/animated_core_bloc.dart';
import 'package:mx_core_example/router/route.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

@ARoute(url: Pages.animatedCore)
class AnimatedCorePage extends StatefulWidget {
  final RouteOption option;

  AnimatedCorePage(this.option) : super();

  @override
  _AnimatedCorePageState createState() => _AnimatedCorePageState();
}

class _AnimatedCorePageState extends State<AnimatedCorePage>
    with SingleTickerProviderStateMixin {
  AnimatedCoreBloc bloc;

  /// tab 控制器
  TabController tabController;

  /// 動畫 key, 由於所有動畫的節點都是同一個元件, 加入 key 使其刷新 State
  Map<AnimatedType, Key> animatedKey;

  /// 動畫控制器, 此處只用在 toggle 動畫
  AnimatedCoreController animatedCoreController;

  /// 取得當前的動畫行為
  AnimatedType get currentAnimatedType =>
      AnimatedType.values[tabController.index];

  /// 動畫屬性各個 [TextField] 的控制器
  TextEditingController scaleController = TextEditingController(text: "1.5");
  TextEditingController opacityController = TextEditingController(text: "0.5");
  TextEditingController rotateZController = TextEditingController(text: "0.0");
  TextEditingController rotateXController = TextEditingController(text: "0.0");
  TextEditingController rotateYController = TextEditingController(text: "0.0");
  TextEditingController translateXController =
      TextEditingController(text: "0.0");
  TextEditingController translateYController =
      TextEditingController(text: "0.0");

  double scaleValue = 1.5;
  double opacityValue = 0.5;
  double rotateXValue = 0;
  double rotateYValue = 0;
  double rotateZValue = 0;
  Offset _TranslateValue = Offset.zero;

  double scale = 1.0, opacity = 1.0;

  AnimatedValue get animatedValue {
    return AnimatedValue.collection(animatedList: [
      AnimatedValue.scale(end: scaleValue),
      AnimatedValue.opacity(end: opacityValue),
      AnimatedValue.rotateX(end: rotateXValue),
      AnimatedValue.rotateY(end: rotateYValue),
      AnimatedValue.rotateZ(end: rotateZValue),
      AnimatedValue.translate(begin: Offset.zero, end: _TranslateValue),
    ]);
  }

  var title = "動畫核心";
  var content = """
  動畫核心
  a. 所有的動畫皆基於此之上製作, 包含以下
    1. LoadingAnimation - 讀取動畫
    2. ParticleAnimation - 粒子動畫
    
  b. 動畫有以下幾種行為
    1. AnimatedCore.tap - 點擊
    2. AnimatedCore.toggle - 開關
    3. AnimatedCore.once - 入場時執行一次
    4. AnimatedCore.repeat - 不斷重複執行
    
  c. 目前可使用的動畫屬性
    1. AnimatedValue.scale - 縮放
    2. AnimatedValue.rotate - 旋轉 / 翻轉
    3. AnimatedValue.translate - 位移
    4. AnimatedValue.direction - 方向位移
    5. AnimatedValue.opacity - 透明度
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<AnimatedCoreBloc>(context);
    tabController =
        TabController(length: AnimatedType.values.length, vsync: this);
    animatedKey = {
      AnimatedType.repeat: ValueKey(0),
      AnimatedType.once: ValueKey(1),
      AnimatedType.tap: ValueKey(2),
      AnimatedType.toggle: ValueKey(3),
    };
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        color: Colors.black,
        haveAppBar: true,
        resizeToAvoidBottomPadding: true,
        title: title,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            padding: EdgeInsets.all(12),
            child: SliverView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: buildIntroduction(content),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.only(top: 24),
                    child: buildParam(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: buildBehaviorTab(),
                ),
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      key: animatedKey[currentAnimatedType],
                      height: 100,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xff8c6018),
                            Color(0xff8c6018),
                          ],
                        ),
                      ),
                      child: buildAnimated(),
                    ),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return AxisTransition(
                        position: animation,
                        child: child,
                        slideIn: TransDirection.right,
                        slideOut: TransDirection.left,
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 設置當前動畫參數
  Widget buildParam() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Text(
            "動畫屬性",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        Container(
          child: buildParamSetting(
            "縮放",
            controller: scaleController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("縮放: $v");
                scaleValue = v;
                setState(() {});
              }
            },
          ),
        ),
        Container(
          child: buildParamSetting(
            "旋轉",
            controller: rotateZController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("旋轉: $v");
                rotateZValue = v;
                setState(() {});
              }
            },
          ),
        ),
        Container(
          child: buildParamSetting(
            "垂直翻轉",
            controller: rotateXController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("垂直翻轉: $v");
                rotateXValue = v;
                setState(() {});
              }
            },
          ),
        ),
        Container(
          child: buildParamSetting(
            "水平旋轉",
            controller: rotateYController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("水平翻轉: $v");
                rotateYValue = v;
                setState(() {});
              }
            },
          ),
        ),
        Container(
          child: buildParamSetting(
            "x軸位移",
            controller: translateXController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("x軸位移: $v");
                _TranslateValue = Offset(v, _TranslateValue.dy);
                setState(() {});
              }
            },
          ),
        ),
        Container(
          child: buildParamSetting(
            "y軸位移",
            controller: translateYController,
            onChanged: (value) {
              var v = double.tryParse(value);
              if (v != null) {
                print("y軸位移: $v");
                _TranslateValue = Offset(_TranslateValue.dx, v);
                setState(() {});
              }
            },
          ),
        ),
        Container(
          height: 24,
        ),
      ],
    );
  }

  /// 構建設定動畫屬性參數的元件
  Widget buildParamSetting(String title,
      {TextEditingController controller, ValueChanged<String> onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        Expanded(
            child: Container(
          width: 20,
        )),
        Container(
          width: 50,
          child: TextField(
            maxLines: 1,
            maxLength: 3,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(4),
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellowAccent[700]),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// 設置當前動畫行為
  Widget buildBehaviorTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Text(
            "動畫行為",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        TabBar(
          controller: tabController,
          indicatorColor: Color(0xff8c6018),
          indicatorWeight: 4,
          labelStyle: TextStyle(color: Colors.white, fontSize: 18),
          unselectedLabelStyle: TextStyle(color: Colors.grey, fontSize: 14),
          tabs: List.generate(
              AnimatedType.values.length,
              (index) => Tab(
                    text: getBehaviorText(AnimatedType.values[index]),
                  )),
          onTap: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }

  /// 取得動畫行為對應的文字
  String getBehaviorText(AnimatedType type) {
    switch (type) {
      case AnimatedType.tap:
        return "點擊";
      case AnimatedType.repeat:
        return "重複";
      case AnimatedType.once:
        return "單次";
      case AnimatedType.toggle:
        return "開關";
    }
    return '';
  }

  /// 構建動畫
  /// 根據 tab index 構建不同的類型
  Widget buildAnimated() {
    switch (currentAnimatedType) {
      case AnimatedType.tap:
        return AnimatedCore.tap(
          multipleAnimationController: true,
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              "點擊 - 按下開始 / 放開結束",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          animatedList: [
            animatedValue,
          ],
          onTap: () {
            print("開始執行結束動畫");
          },
          onTapAfterAnimated: () {
            print("結束動畫執行結束");
          },
        );
        break;
      case AnimatedType.toggle:
        return AnimatedCore.toggle(
          multipleAnimationController: true,
          initToggle: false,
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              "開關 - 點擊切換開關",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          animatedList: [
            animatedValue,
          ],
          onCreated: (controller) {
            animatedCoreController = controller;
          },
          onTap: () {
            animatedCoreController.toggle();
          },
        );
        break;
      case AnimatedType.once:
        return AnimatedCore.once(
          multipleAnimationController: true,
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              "自動執行一次動畫",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          animatedList: [
            animatedValue,
          ],
        );
      case AnimatedType.repeat:
        return AnimatedCore.repeat(
          multipleAnimationController: true,
          child: Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Text(
              "自動重複執行動畫",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          animatedList: [
            animatedValue,
          ],
        );
    }
    return null;
  }
}

/// 動畫類型
enum AnimatedType {
  tap,
  toggle,
  repeat,
  once,
}

/// 動畫屬性
enum AnimatedParam {
  scale,
  direction,
  opacity,
  rotate,
}
