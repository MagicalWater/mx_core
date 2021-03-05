import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mx_core/extension/extension.dart';

class Marquee extends StatefulWidget {
  /// 元件
  final List<Widget> children;

  /// 預設[邊緣]元件
  final Widget preset;

  /// 滾動速率
  final int velocity;

  /// 每次跑馬燈啟動的間隔時間
  final Duration interval;

  /// 跑馬燈滾動到下個條目的動畫時間
  final Duration nextDuration;

  /// 是否自動啟動跑馬燈
  final bool auto;

  /// 跑馬燈幾次循環, null 為無限次數
  final int times;

  /// 跑馬燈每次結束的回調
  final void Function(int times) onEnd;

  /// 跑馬燈開始時回調
  final void Function() onStart;

  /// 跑馬燈控制器
  final Function(MarqueeController controller) onCreated;

  /// 跑馬燈高度
  final double height;

  /// 邊緣透明
  final bool fadeSide;

  final Function(int index) onTap;

  Marquee({
    @required this.children,
    Key key,
    this.height,
    this.preset,
    this.fadeSide = true,
    this.auto = true,
    this.times,
    this.onCreated,
    this.onStart,
    this.onEnd,
    this.onTap,
    this.velocity = 100,
    this.interval = const Duration(milliseconds: 1000),
    this.nextDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  factory Marquee.text({
    @required List<String> texts,
    String preset,
    double height,
    TextStyle style,
    Key key,
    bool auto = true,
    int times,
    final Function(MarqueeController controller) onCreated,
    VoidCallback onStart,
    Function(int times) onEnd,
    Function(int index) onTap,
    int velocity = 100,
    Duration interval = const Duration(milliseconds: 1000),
    Duration nextDuration = const Duration(milliseconds: 500),
  }) {
    return Marquee(
      children: texts
          .map((e) => Text(
                e,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ))
          .toList(),
      preset: preset != null
          ? Text(
              preset,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.clip,
            )
          : null,
      height: height,
      key: key,
      auto: auto,
      times: times,
      onCreated: onCreated,
      onStart: onStart,
      onEnd: onEnd,
      onTap: onTap,
      velocity: velocity,
      interval: interval,
      nextDuration: nextDuration,
    );
  }

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> implements MarqueeController {
  Map<int, Widget> replacement = {};

  /// 控制是否可滾動
  bool scrollEnabled = true;

  /// 列表的位置控制
  ScrollController mainScrollController;

  /// 每個列表的滾動控制
  List<ScrollController> itemScrollController;

  /// 當前是否正在滾動中
  bool isScrolling = false;

  /// 顯示元件列表
  List<Widget> showWidget;

  Widget get sideWidget => widget.preset != null
      ? _coverWidget(widget.preset)
      : Container(height: widget.height);

  int scrollStartIndex;

  bool childrenUpdate = false;
  bool sideUpdate1 = false;
  bool sideUpdate2 = false;

  @override
  void initState() {
    mainScrollController = ScrollController(initialScrollOffset: widget.height);
    scrollStartIndex = 1;

    showWidget = List.from(widget.children)
        .indexMap((e, i) => _coverWidget(e, index: i))
        .toList();

    showWidget
      ..insert(0, sideWidget)
      ..add(sideWidget);

    itemScrollController =
        List.generate(showWidget.length, (_) => ScrollController());

    if (widget.onCreated != null) {
      widget.onCreated(this);
    }

    initScroll();
    super.initState();
  }

  Widget _coverWidget(Widget child, {int index}) {
    var conver = Container(
      color: Colors.transparent,
      height: widget.height,
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (index != null) {
      return GestureDetector(
        onTap: () {
          widget.onTap?.call(index);
        },
        child: conver,
      );
    } else {
      return conver;
    }
  }

  @override
  void didUpdateWidget(Marquee oldWidget) {
    childrenUpdate = true;
    sideUpdate1 = true;
    sideUpdate2 = true;
    super.didUpdateWidget(oldWidget);
  }

  void _syncChildren() {
    // 記錄下需要替換的 widget
    // replacement = Map<int, Widget>.from(this.widget.children.asMap())
    //     .map((key, value) => MapEntry(key + 1, _coverWidget(value)));

    // 先去除showWidget頭尾
    var oldSide1 = showWidget.removeAt(0);
    var oldSide2 = showWidget.removeLast();

    showWidget = List.from(widget.children)
        .indexMap((e, i) => _coverWidget(e, index: i))
        .toList();

    // if (showWidget.length> replacement.length) {
    //   showWidget = showWidget.sublist(0, replacement.length);
    // } else if (showWidget.length < replacement.length) {
    //   for (var i = showWidget.length ; i < replacement.length; i++) {
    //     showWidget.add(replacement.remove(i));
    //   }
    // }

    // 再重新加入頭尾
    showWidget
      ..insert(0, oldSide1)
      ..add(oldSide2);

    var currentControllerLen = itemScrollController.length;
    var needLen = showWidget.length;
    if (currentControllerLen > needLen) {
      var diff = currentControllerLen - needLen;
      for (var i = 0; i < diff; i++) {
        var lastController = itemScrollController.removeLast();
        lastController.dispose();
      }
    } else if (needLen > currentControllerLen) {
      var diff = needLen - currentControllerLen;
      for (var i = 0; i < diff; i++) {
        var newController = ScrollController();
        itemScrollController.add(newController);
      }
    }

    print('跑馬燈長度: ${showWidget.length}');
  }

  /// 初始化滾動設置
  void initScroll() async {
    if (widget.auto) {
      startScroll();
    }
  }

  /// 順帶檢測 widgetRect 是否已經取得
  /// 等待 scrollController attach 到view上
  /// 回傳是否可正常往下執行
  Future<bool> waitScrollControllerAttach([int index]) async {
    ScrollController detectController() {
      return index == null ? mainScrollController : itemScrollController[index];
    }

    while (detectController() != null && !detectController().hasClients) {
      await Future.delayed(Duration(seconds: 1));
    }
    if (detectController() == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        height: widget.height,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          controller: mainScrollController,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: showWidget.indexMap((e, i) {
                var controller = itemScrollController[i];

                if (widget.fadeSide) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0, 0.01, 0.99, 1],
                      ).createShader(
                          bounds.shift(Offset(-bounds.left, -bounds.top)));
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      controller: controller,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: e,
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    child: e,
                  );
                }
              }).toList(),
            ),
          ),
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  bool updateShow() {
    if (mounted) {
      setState(() {});
      return true;
    }
    return false;
  }

  /// 開始滾動
  Future<void> startScroll() async {
    if (isScrolling) {
      return;
    }

    isScrolling = true;

    // 等待 scrollController attach 到 view 上
    if (!(await waitScrollControllerAttach())) return;

    if (widget.onStart != null) {
      widget.onStart();
    }

    var keepScroll = true;
    var currentTimes = 0;

    while (keepScroll && scrollEnabled) {
      var onlyTwo = showWidget.length == 2;
      if (onlyTwo) {
        if (sideUpdate2) {
          showWidget[showWidget.length - 1] = sideWidget;
          sideUpdate2 = false;
          if (!updateShow()) return;
        }

        await Future.delayed(widget.interval);

        if (!(await waitScrollControllerAttach())) return;

        // 滾動視圖到下個列表
        await mainScrollController.animateTo(
          widget.height,
          duration: widget.nextDuration,
          curve: Curves.easeOut,
        );

        if (sideUpdate1) {
          showWidget[0] = sideWidget;
          sideUpdate1 = false;
          if (!updateShow()) return;
          await Future.delayed(Duration(seconds: 1));
        }

        if (!(await waitScrollControllerAttach())) return;

        // 恢復當前跑馬燈的位置
        mainScrollController.jumpTo(0);
      } else {
        // 依序慢慢滾動
        for (int i = scrollStartIndex; i < showWidget.length - 1; i++) {
          var nextPosition = widget.height * (i + 1);

          if (i != 0) {
            await Future.delayed(widget.interval);
          } else {
            // 第0個位置直接衝到1
            // 檢查是否可滑動
            if (!(await waitScrollControllerAttach())) return;

            var nextDuration = Duration(
              milliseconds: widget.nextDuration.inMilliseconds ~/ 2,
            );

            // 滾動視圖到下個列表
            await mainScrollController.animateTo(
              nextPosition,
              duration: nextDuration,
              curve: Curves.easeOut,
            );

            if (sideUpdate1 || sideUpdate2) {
              showWidget[0] = sideWidget;
              showWidget[showWidget.length - 1] = sideWidget;
              if (!updateShow()) return;
            }

            continue;
          }

          // 取得當前位置的滾動控制器
          var currentController = itemScrollController[i];

          // 等待 scrollController attach 到 view 上
          if (!(await waitScrollControllerAttach(i))) return;

          var millDuration =
              (currentController.position.maxScrollExtent / widget.velocity) *
                  1000;

          var startDuration = Duration(milliseconds: millDuration.toInt());
//        print("開始滾動: $startDistance, ${startDuration.inMilliseconds}");

          if (startDuration != Duration.zero) {
            await currentController.animateTo(
              currentController.position.maxScrollExtent,
              duration: startDuration,
              curve: Curves.linear,
            );
          }

          await Future.delayed(widget.interval);

          // 檢查是否可滑動
          if (!(await waitScrollControllerAttach())) return;

          // print('滾動到下個位置: $nextPosition');

          // 現在位於結尾, 需要讓下個列表 standby
          // 操作 mainScrollController 至下個列表的位置
          var nextDuration = i > showWidget.length - 2
              ? Duration(milliseconds: widget.nextDuration.inMilliseconds ~/ 2)
              : widget.nextDuration;

          var nextCurve =
              i > showWidget.length - 2 ? Curves.easeIn : Curves.easeOut;

          // 滾動視圖到下個列表
          await mainScrollController.animateTo(
            nextPosition,
            duration: nextDuration,
            curve: nextCurve,
          );

          if (!(await waitScrollControllerAttach(i))) return;

          // 恢復當前跑馬燈的位置
          currentController.jumpTo(0);

          // 檢查是否有需要替換的跑馬燈元件
          // 替換掉跑馬燈元件
          // if (replacement.containsKey(i)) {
          //   showWidget[i] = replacement.remove(i);
          //   setState(() {});
          // }

          // 檢查是否可滑動
          if (!(await waitScrollControllerAttach())) return;

          if (i == showWidget.length - 2) {
            // 全部的跑馬燈滾動完成了
            mainScrollController.jumpTo(0);
            // print('滾動回首置');
            break;
          }
        }
      }

      if (childrenUpdate) {
        _syncChildren();
        childrenUpdate = false;
        if (!updateShow()) return;
      }

      scrollStartIndex = 0;

      if (widget.times != null) {
        if (currentTimes >= widget.times) {
          // 如果滑動次數到了, 則停止滑動
          // 通知外部 onEnd 在 isScrolling 設置後呼叫
          keepScroll = false;
        } else {
          currentTimes += 1;
          widget.onEnd?.call(currentTimes);
        }
      } else {
        widget.onEnd?.call(currentTimes);
      }
    }

    isScrolling = false;
    if (widget.onEnd != null) {
      widget.onEnd(currentTimes);
    }
  }

  @override
  void start() {
    scrollEnabled = true;
    if (!isScrolling) {
      startScroll();
    }
  }

  @override
  void end() {
    scrollEnabled = false;
  }

  @override
  void dispose() {
    scrollEnabled = false;

    mainScrollController?.dispose();
    mainScrollController = null;

    itemScrollController.forEach((e) => e?.dispose());
    itemScrollController = itemScrollController.map((e) => null).toList();

    super.dispose();
  }
}

abstract class MarqueeController {
  void start();

  void end();
}
