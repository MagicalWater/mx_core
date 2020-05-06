part of 'marquee.dart';

class VerticalMarquee extends StatefulWidget {
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

  VerticalMarquee._({
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
  _VerticalMarqueeState createState() => _VerticalMarqueeState();
}

class _VerticalMarqueeState extends State<VerticalMarquee>
    with RectProviderMixin
    implements MarqueeController {
  /// 控制是否可滾動
  bool scrollEnabled = true;

  /// 列表的位置控制
  ScrollController mainScrollController = ScrollController();

  /// 每個列表的滾動控制
  List<ScrollController> itemScrollController;

  /// 當前是否正在滾動中
  bool isScrolling = false;

  @override
  Duration delayGetRect() => Duration(seconds: 1);

  @override
  void initState() {
    itemScrollController =
        List.generate(widget.children.length, (_) => ScrollController());
    widgetRectStream.listen((_) => setState(() {}));

    if (widget.onCreated != null) {
      widget.onCreated(this);
    }

    initScroll();
    super.initState();
  }

  @override
  void didUpdateWidget(VerticalMarquee oldWidget) {
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
    while (widgetRect == null) {
      await Future.delayed(Duration(seconds: 1));
      if (detectController() == null) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widgetRect == null) {
      // 尚未取得元件的寬高, 先取得元件寬高在進行後續處理
      return SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          child: widget.children[0],
        ),
      );
    } else {
      var index = 0;
      // 一切準備好, 可以開始進行跑馬燈的顯示
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        controller: mainScrollController,
        children: widget.children.map((e) {
          var controller = itemScrollController[index];
          index += 1;
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: controller,
            child: Container(
              alignment: Alignment.centerLeft,
              height: widgetRect.height,
              constraints: BoxConstraints(minWidth: widgetRect.width),
              child: e,
            ),
          );
        }).toList(),
        scrollDirection: Axis.vertical,
      );
    }
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
      for (int i = 0; i < widget.children.length; i++) {
        await Future.delayed(widget.interval);

        // 取得當前位置的滾動控制器
        var currentController = itemScrollController[i];

        // 等待 scrollController attach 到 view 上
        if (!(await waitScrollControllerAttach(i))) return;

        var widgetHeight = widgetRect.height;

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

        // 現在位於結尾, 需要讓下個列表 standby
        // 操作 mainScrollController 至下個列表的位置
        var nextPosition = widgetHeight * (i + 1);

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        // 滾動視圖到下個列表
        await mainScrollController.animateTo(
          nextPosition,
          duration: widget.nextDuration,
          curve: Curves.easeOut,
        );

        if (!(await waitScrollControllerAttach(i))) return;

        // 恢復當前跑馬燈的位置
        currentController.jumpTo(0);

        // 檢查是否可滑動
        if (!(await waitScrollControllerAttach())) return;

        if (i == widget.children.length - 2) {
          // 全部的跑馬燈滾動完成了
          mainScrollController.jumpTo(0);
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

    mainScrollController?.dispose();
    mainScrollController = null;

    itemScrollController.forEach((e) => e?.dispose());
    itemScrollController = itemScrollController.map((e) => null).toList();

    super.dispose();
  }
}
