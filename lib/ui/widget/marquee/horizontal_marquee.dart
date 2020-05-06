part of 'marquee.dart';

class HorizontalMarquee extends StatefulWidget {
  /// 元件
  final List<Widget> children;

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

  HorizontalMarquee._({
    @required this.children,
    Key key,
    this.auto = true,
    this.times,
    this.onCreated,
    this.onStart,
    this.onEnd,
    this.velocity = 100,
    this.interval = const Duration(milliseconds: 1000),
    this.nextDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _HorizontalMarqueeState createState() => _HorizontalMarqueeState();
}

class _HorizontalMarqueeState extends State<HorizontalMarquee>
    with RectProviderMixin
    implements MarqueeController {
  ScrollController scrollController = ScrollController();

  bool scrollEnabled = true;

  bool isScrolling = false;

  /// 所有元件的 size
  List<Rect> childrenSize;

  /// 所有元件的 size 是否都已經到手了
  bool get isAllSizeGet => !(childrenSize.any((e) => e == null));

  @override
  Duration delayGetRect() => Duration(seconds: 1);

  @override
  void initState() {
    childrenSize = List.generate(widget.children.length, (_) => null);
    widgetRectStream.listen((_) => setState(() {}));

    if (widget.onCreated != null) {
      widget.onCreated(this);
    }

    initScroll();
    super.initState();
  }

  @override
  void didUpdateWidget(HorizontalMarquee oldWidget) {
    clearWidgetRect();
    super.didUpdateWidget(oldWidget);
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
  Future<bool> waitScrollControllerAttach() async {
    while (scrollController != null && !scrollController.hasClients) {
      await Future.delayed(Duration(seconds: 1));
    }
    if (scrollController == null) {
      return false;
    }
    while (widgetRect == null) {
      await Future.delayed(Duration(seconds: 1));
      if (scrollController == null) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widgetRect == null) {
      // 尚未取得元件的寬高, 先取得元件寬高在進行後續處理
      return getShaderMask(child: ListView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: widget.children[0],
          ),
        ],
      ),);
    } else if (!isAllSizeGet) {
      // 取得元件寬高, 但需要再取得底下所有元件寬高計算位置
      List<Widget> rectChildren = [];
      widget.children.forEach((e) {
        var index = rectChildren.length;

//        print("最小寬度: ${widgetRect.width}");
        Widget widgetChain = Container(
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(minWidth: widgetRect.width),
          child: e,
        );

        widgetChain = RectProvider(
          child: widgetChain,
          delayGetRect: Duration(seconds: 1),
          onRect: (rect) {
            childrenSize[index] = rect;

            if (isAllSizeGet) {
              var xTranslateDiff = childrenSize[0].left;

              childrenSize[0] = childrenSize[0].translate(-xTranslateDiff, 0);

              for (int i = 1; i < childrenSize.length; i++) {
                childrenSize[i] = childrenSize[i]
                    .translate(childrenSize[i - 1].right - xTranslateDiff, 0);
              }
              setState(() {});
            }
          },
        );

        if (index != 0) {
          widgetChain = Opacity(
            opacity: 0,
            child: widgetChain,
          );
        }

        rectChildren.add(widgetChain);
      });
      return getShaderMask(child: ListView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Stack(
            fit: StackFit.passthrough,
            children: rectChildren,
          ),
        ],
      ),);
    } else {
      // 一切準備好, 可以開始進行跑馬燈的顯示
      return getShaderMask(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          controller: scrollController,
          children: widget.children
              .map((e) =>
              Container(
                alignment: Alignment.centerLeft,
                constraints: BoxConstraints(minWidth: widgetRect.width),
                child: e,
              ))
              .toList(),
          scrollDirection: Axis.horizontal,
        ),
      );
    }
  }

  Widget getShaderMask({Widget child}) {
    return child;
//    return ShaderMask(
//      shaderCallback: (Rect bounds) {
//        return LinearGradient(
//          begin: Alignment.centerLeft,
//          end: Alignment.centerRight,
//          colors: <Color>[
//            Colors.transparent,
//            Colors.white,
//            Colors.white,
//            Colors.transparent,
//          ],
//          stops: [0, 0.01, 0.99, 1],
//        ).createShader(bounds.shift(Offset(-bounds.left, -bounds.top)));
//      },
//      blendMode: BlendMode.dstIn,
//      child: child,
//    );
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
      // 依序慢慢滾動
      for (int i = 0; i < childrenSize.length; i++) {
        await Future.delayed(widget.interval);

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        var widgetWidth = widgetRect.width;

        // 取得滾動到下一個位置的距離
        var rect = childrenSize[i];
//        print("元件: ${rect.width}, 整體: ${widgetRect}");
        if (rect.width > widgetRect.width) {
          double startDistance = rect.right - widgetWidth;
          double currentDistance = scrollController.position.pixels;

          var millDuration =
              ((startDistance - currentDistance) / widget.velocity) * 1000;

          var startDuration = Duration(milliseconds: millDuration.toInt());
//        print("開始滾動: $startDistance, ${startDuration.inMilliseconds}");

          if (startDuration != Duration.zero) {
            await scrollController.animateTo(
              startDistance,
              duration: startDuration,
              curve: Curves.linear,
            );
          }
        }

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        await Future.delayed(widget.interval);

        // 現在位於結尾, 需要讓下個列表 standby
        var nextRect = childrenSize[i + 1];
//        print("下個節點: ${nextRect.left}");
        var nextPosition = nextRect.left;
//        var nextDistance = nextPosition - startDistance;

//        print("newxt = ${nextRect.left}");

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        await scrollController.animateTo(
          nextPosition,
          duration: widget.nextDuration,
          curve: Curves.easeOut,
        );

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        if (i == childrenSize.length - 2) {
          // 全部的跑馬燈滾動完成了
          scrollController.jumpTo(0);
          break;
        }
      }

      currentTimes += 1;

      // 檢查滑動次數
//      print("檢查滑動次數: ${widget.times}, 當前 ${currentTimes}");
      if (widget.times != null && currentTimes >= widget.times) {
        // 如果滑動次數到了, 則停止滑動
        // 通知外部 onEnd 在 isScrolling 設置後呼叫
        keepScroll = false;
      } else {
        if (widget.onEnd != null) {
          widget.onEnd(currentTimes);
        }
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
    scrollController?.dispose();
    scrollController = null;
    super.dispose();
  }
}
