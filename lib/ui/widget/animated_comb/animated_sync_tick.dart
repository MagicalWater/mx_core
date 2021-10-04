part of 'animated_comb.dart';

/// 多動畫元件的同步 tick
class AnimatedSyncTick implements AnimatedCombController {
  /// 當前已經分發到多少個獨立 id
  int _currentUnique = 0;

  /// 動畫控制核心
  AnimationController? _controller;

  /// 觸發動畫 tick 的串流
  StreamController<void> _tickController = StreamController.broadcast();

  /// 觸發動畫 tick Stream
  Stream<void> get tickStream => _tickController.stream;

  /// 動畫群組列表
  Map<int, _AnimatedComb> _animatedMap = {};

  /// 儲存動畫群組列表解析後的 data
  Map<int, AnimationData> _animatedParseMap = {};

  List<AnimationStatusListener> _outsideStatusListener = [];

  /// 動畫開關初始值
  /// 當 [type] 為 [AnimatedBehavior.toggle] 時有效
  final bool initToggle;

  /// 初始動畫開關是否使用動畫過度
  final bool initAnimated;

  /// 是否自動開始動畫
  /// 當動畫類行為 [AnimatedType.once] 以及 [AnimatedType.repeat] 時有效
  final bool autoStart;

  /// 動畫行為
  AnimatedType _type;

  /// 當前動畫行為模式
  AnimatedType get type => _type;

  /// 當前動畫的運行 Method
  late AnimationMethod _currentMethod;

  /// 當前動畫開關是否開啟
  bool get currentToggle => _currentToggle;

  /// 當前動畫開關是否開啟
  bool _currentToggle = false;

  /// 是否由內部自行註冊 [TickerProvider]
  bool _isNeedRegisterTicker;

  /// 是否動畫中
  @override
  bool get isAnimating =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;

  /// 動畫狀態
  @override
  AnimationStatus? get status => _controller?.status;

  AnimatedSyncTick._({
    this.initToggle = false,
    this.initAnimated = true,
    this.autoStart = true,
    required AnimatedType type,
  })  : this._controller = null,
        this._isNeedRegisterTicker = true,
        this._type = type {
    _syncCurrentMethod();
  }

  /// [vsync] - 動畫控制器 [TickerProvider]
  /// 帶入 [vsync] 可達到多個元件同步動畫 tick 的效果
  /// [type] - 動畫類型,
  AnimatedSyncTick({
    required AnimatedType type,
    required TickerProvider vsync,
    this.initToggle = false,
    this.initAnimated = true,
    this.autoStart = true,
  })  : this._isNeedRegisterTicker = false,
        this._type = type,
        this._controller = AnimationController(
          duration: Duration.zero,
          vsync: vsync,
        ) {
    _syncCurrentMethod();
    this._controller!
      ..addListener(_controllerListener)
      ..addStatusListener(_statusListener);
  }

  /// 單純構建動畫控制器
  /// 但 ticker 仍然掛在 [AnimatedComb] 內部
  /// 因此由此類生成的物件不可給多個元件使用
  /// * [initToggle] - 若動畫類型行為 [AnimatedType.toggle], 則此值有效
  factory AnimatedSyncTick.identity({
    required AnimatedType type,
    bool initToggle = false,
    bool initAnimated = true,
    bool autoStart = true,
  }) {
    return AnimatedSyncTick._(
      initToggle: initToggle,
      initAnimated: initAnimated,
      autoStart: autoStart,
      type: type,
    );
  }

  /// 控制器的 ticker 監聽
  void _controllerListener() {
    var currentTick = _controller!.value;
    _animatedParseMap.values.forEach((e) {
      e.syncTickValue(currentTick);
    });
    _tickController.add('');
  }

  /// 動畫狀態監聽
  void _statusListener(AnimationStatus status) {
    //        print("動畫狀態變更");
    _handleAnimatedStatusChanged(status);
  }

  void addStatusListener(AnimationStatusListener listener) {
    _outsideStatusListener.add(listener);
    _controller?.addStatusListener(listener);
  }

  /// 重設所有資料
  /// 只給 identity 工廠方法使用內部呼叫的
  void _reset() {
    dispose();
    _currentUnique = 0;
    _tickController = StreamController.broadcast();
    _currentToggle = false;
    _isNeedRegisterTicker = true;
  }

  /// 註冊動畫 Ticker
  /// 只由 [AnimatedComb] 內部檢測到 ticker 狀態參數 [_isNeedRegisterTicker]
  /// 為 true 時才觸發
  void _registerTicker(
    TickerProvider vsync,
  ) {
    if (_isNeedRegisterTicker && this._controller != null) {
      // 代表已經註冊過了, 不可再註冊, 拋出錯誤
      // 同時也代表外部將 AnimatedCombController 丟給多個元件
      // 這是錯誤的
      throw FlutterError("AnimatedCombController.identity 生成的動畫控制器不可同時給多個元件使用");
    }
    this._controller = AnimationController(
      duration: Duration.zero,
      vsync: vsync,
    )
      ..addListener(_controllerListener)
      ..addStatusListener(_statusListener);

    _outsideStatusListener.forEach((element) {
      this._controller!.addStatusListener(element);
    });
  }

  /// 取得 [AnimationData]
  AnimationData _getAnimationData(int id) {
    return _animatedParseMap[id]!..current._toggle = _currentToggle;
  }

  /// 註冊動畫, 回傳一個註冊的 id
  /// 元件之後要獲取自己的動畫列表需透過此 id
  int _registerAnimated({
    required List<Comb> animateList,
    required int duration,
    required Curve curve,
    required int shiftDuration,
    int? id,
  }) {
    var animatedComb = _AnimatedComb(
      animateList: animateList,
      curve: curve,
      duration: duration,
      shiftDuration: shiftDuration,
    );
    if (id != null) {
      _animatedMap[id] = animatedComb;
    } else {
      id = _getNewId();
      _animatedMap[id] = animatedComb;
    }
    // 計算動畫需要花費的時間
    _settingAnimated();
    return id;
  }

  /// 告知可以開始進行動畫
  void _start() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_controller == null) {
        return;
      }
      _controller!.reset();
      switch (type) {
        case AnimatedType.repeatReverse:
          _currentMethod = AnimationMethod.repeatReverse;
          if (autoStart) {
            _controller!.repeat(reverse: true);
          }
          break;
        case AnimatedType.repeat:
          _currentMethod = AnimationMethod.repeat;
          if (autoStart) {
            _controller!.repeat(reverse: false);
          }
          break;
        case AnimatedType.onceReverse:
          _currentMethod = AnimationMethod.onceReverse;
          if (autoStart) {
            if (initAnimated) {
              _controller!.forward();
            } else {
              _controller!.value = 1;
            }
          }
          break;
        case AnimatedType.once:
          _currentMethod = AnimationMethod.once;
          if (autoStart) {
            if (initAnimated) {
              _controller!.forward();
            } else {
              _controller!.value = 1;
            }
          }
          break;
        case AnimatedType.toggle:
          if (initToggle) {
            _currentMethod = AnimationMethod.once;
            if (initAnimated) {
              _controller!.forward();
            } else {
              _controller!.value = 1;
            }
          }
          break;
        case AnimatedType.tap:
          break;
      }
    });
  }

  void _syncCurrentMethod() {
    switch (type) {
      case AnimatedType.repeatReverse:
        _currentMethod = AnimationMethod.repeatReverse;
        break;
      case AnimatedType.repeat:
        _currentMethod = AnimationMethod.repeat;
        break;
      case AnimatedType.onceReverse:
        _currentMethod = AnimationMethod.onceReverse;
        break;
      case AnimatedType.once:
        _currentMethod = AnimationMethod.once;
        break;
      case AnimatedType.toggle:
        _currentMethod = AnimationMethod.toggle;
        break;
      case AnimatedType.tap:
        _currentMethod = AnimationMethod.toggle;
        break;
    }
  }

  /// 執行單次動畫
  TickerFuture _forward() {
    return _controller!.forward();
  }

  /// 反轉動畫
  TickerFuture _reverse() {
    return _controller!.reverse();
  }

  /// 停止
  void stop() {
    _controller?.stop();
  }

  /// 呼叫動畫開始執行
  // TickerFuture _repeat(bool reverse) {
  //   return _controller!.repeat(reverse: reverse);
  // }

  /// 獲取一組新的獨立id
  int _getNewId() {
    return _currentUnique++;
  }

  /// 解析所有動畫, 將 [List<Comb>] 轉為 [AnimationData]
  /// 並且依照需要花費的時間, 重新設置 [AnimationController] 的時長
  void _settingAnimated() {
    var totalMilliseconds = _getTotalDuration();
    _controller!.duration = Duration(milliseconds: totalMilliseconds);

    _animatedParseMap = _animatedMap.map((id, animateComb) {
      var animatedData = _convertToAnimatedData(
        totalMilliseconds,
        animateComb,
        id,
      );
      animatedData.syncTickValue(0);
      return MapEntry(id, animatedData);
    });
  }

  /// 取得 animated list 的總total時長
  /// 回傳 milliseconds
  int _getTotalDuration() {
    var maxDuration = 0;

    _animatedMap.forEach((id, animateComb) {
      int duration = 0;
      animateComb.animateList.forEach((e) {
        duration += ((e.delayed ?? 0) + e.totalDuration(animateComb.duration));
      });

      maxDuration = max(duration, maxDuration);
    });

    return maxDuration;
  }

  /// 將 [List<Comb>] 轉為 [AnimationData]
  /// 首先依照動畫時間分割執行時段
  /// 最後生成對應的 [AnimationData]
  AnimationData _convertToAnimatedData(
    int totalDuration,
    _AnimatedComb animatedComb,
    int id,
  ) {
    var animationData = AnimationData();

    // 實際開始時間
    double start = 0;

    // 實際結束時間
    double end = 0;

    // 取得動畫開始偏移時間餘數
    // 因為偏移時間不得大於總時間
//    double shiftRemainder =
//        animatedComb.shiftDuration.toDouble() % totalDuration.toDouble();

    double shiftPercent =
        animatedComb.shiftDuration.toDouble() / totalDuration.toDouble();

    // print("延遲百分比: $shiftPercent");

    // 遍歷動畫列表, 轉為對應的 animation
    animatedComb.animateList.forEach((e) async {
      // Interval 是個 Curve, 且可設置 開始/結束 時間
      // 可藉此達到 delay 的效果
      // 開始/結束 時間是依照比例, 因此需要再除以 total 時間
      start = (e.delayed ?? 0) + end;
      var duration = e.totalDuration(animatedComb.duration).toDouble();
      end = start + duration;
//      print("打印: total = $total, start = $start, end = $end");
      if (e is CombParallel) {
        e.animatedList.forEach((ce) async {
          var duration = ce.duration ?? e.duration ?? animatedComb.duration;
          var delay = ce.delayed ?? 0;
          var tempStart = delay + start;
          var tempEnd = tempStart + duration;
          var tempCurve = ce.curve ?? e.curve ?? animatedComb.curve;

          if (!(ce is CombDelay)) {
            await _addCombToAnimationData(
              animationData: animationData,
              value: ce,
              start: tempStart / totalDuration.toDouble(),
              end: tempEnd / totalDuration.toDouble(),
              curve: tempCurve,
              shiftPercent: shiftPercent,
            );
          }
        });
      } else if (!(e is CombDelay)) {
        var tempCurve = e.curve ?? animatedComb.curve;
//        var shiftPercent = 0.0;
//        if (shiftRemainder > start) {
//          // 位移百分比
//          var specialShiftRemainder = shiftRemainder - start;
//          shiftPercent = (specialShiftRemainder / duration).clamp(0.0, 1.0);
//          print("位移百分比22: $shiftPercent");
//        }
        await _addCombToAnimationData(
          animationData: animationData,
          value: e,
          start: start / totalDuration.toDouble(),
          end: end / totalDuration.toDouble(),
          curve: tempCurve,
          shiftPercent: shiftPercent,
        );
      }
    });

    return animationData;
  }

  /// 把動畫加入到 [AnimationData]
  /// 會依照動畫的類型以及屬性加入到 [AnimationData] 底下的對應變數
  /// [value] - 動畫屬性
  /// [start], [end] - 動畫開始/結束時間(為佔整體時間的比例, 並非是真正意義上的時間)
  /// [delayPercent] - 動畫延遲百分比
  Future<void> _addCombToAnimationData({
    required AnimationData animationData,
    required Comb value,
    required double start,
    required double end,
    required Curve curve,
    required double shiftPercent,
  }) async {
    var beginValue = value.begin;
    var endValue = value.end;

    var bindInterval = Interval(start, end, curve: curve);

    late Tween tween;

    ShiftAnimation intervalAnimation = ShiftAnimation(
      parent: _controller!,
      curve: bindInterval,
      methodGetter: _currentAnimatedMethod,
      shift: shiftPercent,
    );

    switch (value.runtimeType) {
      case CombScale:
      case CombSize:
        tween = Tween<Size>(begin: beginValue, end: endValue);
        break;
      case CombOpacity:
      case CombRotate:
        tween = Tween<double>(begin: beginValue, end: endValue);
        break;
      case CombTranslate:
        tween = Tween<Offset>(begin: beginValue, end: endValue);
        break;
      case CombColor:
        tween = ColorTween(begin: beginValue, end: endValue);
        break;
    }

    Animation animation = tween.animate(intervalAnimation);

    switch (value.runtimeType) {
      case CombScale:
        AnimationBinder<Size> binder = AnimationBinder(
          animation: animation as Animation<Size>,
          interval: bindInterval,
          shift: intervalAnimation,
          scaleType: (value as CombScale).type,
          endValue: endValue,
        );
        animationData._scaleList.add(binder);
        break;
      case CombRotate:
        AnimationBinder<double> binder = AnimationBinder(
          animation: animation as Animation<double>,
          interval: bindInterval,
          shift: intervalAnimation,
          endValue: endValue,
        );
        switch ((value as CombRotate).type) {
          case RotateType.x:
            // 垂直翻轉
            animationData._rotateXList.add(binder);
            break;
          case RotateType.y:
            // 水平翻轉
            animationData._rotateYList.add(binder);
            break;
          case RotateType.z:
            // 旋轉
            animationData._rotateZList.add(binder);
            break;
        }
        break;
      case CombTranslate:
        AnimationBinder<Offset> binder = AnimationBinder(
          animation: animation as Animation<Offset>,
          interval: bindInterval,
          shift: intervalAnimation,
          transType: (value as CombTranslate).type,
          endValue: endValue,
        );
        animationData._offsetList.add(binder);
        break;
      case CombOpacity:
        AnimationBinder<double> binder = AnimationBinder(
          animation: animation as Animation<double>,
          interval: bindInterval,
          shift: intervalAnimation,
          endValue: endValue,
        );
        // 透明值為一個絕對的數值, 因此不需要層層疊加, 只需要一個當前值
        // 因此由此監聽值的改變不斷設值
        animationData._opacityList.add(binder);
        break;
      case CombSize:
        AnimationBinder<Size> binder = AnimationBinder(
          animation: animation as Animation<Size>,
          interval: bindInterval,
          shift: intervalAnimation,
          sizeType: (value as CombSize).type,
          endValue: endValue,
        );
        animationData._sizeList.add(binder);
        break;
      case CombColor:
        AnimationBinder<Color?> binder = AnimationBinder(
          animation: animation as Animation<Color?>,
          interval: bindInterval,
          shift: intervalAnimation,
          endValue: endValue,
        );
        animationData._colorList.add(binder);
        break;
    }
  }

  /// 同步當前開關應該有的動畫
  Future<void> _syncToggleStatus() async {
    if (_controller != null) {
      switch (_controller!.status) {
        case AnimationStatus.dismissed:
        case AnimationStatus.reverse:
          if (_currentToggle) {
            _currentMethod = AnimationMethod.toggle;
            await _controller?.forward();
          }
          break;
        case AnimationStatus.forward:
        case AnimationStatus.completed:
          if (!_currentToggle) {
            _currentMethod = AnimationMethod.toggle;
//            print("返回動畫");
            await _controller?.reverse();
          }
          break;
      }
    }
  }

  /// 取得當前動畫用的 method
  AnimationMethod _currentAnimatedMethod() => _currentMethod;

  /// 動畫狀態改變, 根據 behavior 行為進行相關處理
  /// 以下兩個狀態代表動畫停止
  /// * [AnimationStatus.dismissed] - 動畫停止在剛開始
  /// * [AnimationStatus.completed] - 動畫停止在結束位置
  /// 因此需要根據動畫行為 [AnimatedType] 進行相應動作
  Future<void> _handleAnimatedStatusChanged(AnimationStatus status) async {
    switch (status) {
      case AnimationStatus.dismissed:
        _currentToggle = false;
        break;
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
        _currentToggle = true;
        if (_type == AnimatedType.onceReverse) {
          _currentToggle = false;
          await _controller?.reverse();
        }
        break;
    }
  }

  /// 執行一次動畫
  /// 當動畫行為是為以下幾種時有效
  /// * [AnimatedType.toggle]
  /// * [AnimatedType.tap]
  /// * [AnimatedType.once]
  /// * [AnimatedType.onceReverse]
  @override
  Future<void> once() async {
    switch (_type) {
      case AnimatedType.once:
        _currentMethod = AnimationMethod.once;
        _controller?.reset();
        await _controller?.forward();
        break;
      case AnimatedType.onceReverse:
        _currentMethod = AnimationMethod.onceReverse;
        _controller?.reset();
        await _controller?.forward();
        break;
      case AnimatedType.toggle:
        // 先儲存當前的 toggle 狀態
        var oriToggle = _currentToggle;
        _currentMethod = AnimationMethod.toggle;
        _controller?.reset();
        await _controller?.forward();
        await _controller?.reverse();
        _currentToggle = oriToggle;
        break;
      case AnimatedType.tap:
        _currentMethod = AnimationMethod.onceReverse;
        _controller?.reset();
        await _controller?.forward();
        await _controller?.reverse();
        break;
      default:
        break;
    }
  }

  /// 設置動畫行為
  @override
  Future<void> setType(AnimatedType type, [bool? toggle]) async {
    _type = type;
    if (_type == AnimatedType.toggle) {
      if (toggle != null) {
        await _syncToggleStatus();
      }
    } else {
      await _handleAnimatedStatusChanged(_controller!.status);
    }
  }

  /// 動畫開關(只在動畫行為是 [AnimatedBehavior.toggle] 時有效)
  /// 當 [value] 為 null 時直接切換開關
  /// 不為 null 則直接設置
  @override
  Future<void> toggle([bool? value]) async {
    if (type == AnimatedType.toggle) {
      _currentToggle = value ?? !_currentToggle;
      await _syncToggleStatus();
    } else {
      print(
          "警告: 當前動畫行為並非是 AnimatedType.toggle, 無法藉由 toggle 開關動畫(請先呼叫 setType() 設置動畫行為模式)");
    }
  }

  /// 釋放動畫串流
  void dispose() {
    _outsideStatusListener.forEach((element) {
      _controller?.removeStatusListener(element);
    });
    _outsideStatusListener.clear();
    _controller?.removeListener(_controllerListener);
    _controller?.removeStatusListener(_statusListener);
    _controller?.dispose();
    _controller = null;
    _tickController.close();
    _animatedMap.clear();
    _animatedParseMap.clear();
  }
}

class _AnimatedComb {
  final List<Comb> animateList;

  /// 動畫的預設差值器
  final Curve curve;

  /// 動畫的預設 duration
  final int duration;

  /// 動畫偏移時間
  final int shiftDuration;

  _AnimatedComb({
    required this.animateList,
    required this.curve,
    required this.duration,
    required this.shiftDuration,
  });
}

class AnimValue {
  /// 偏移
  Offset? get offset => _offset;

  /// 旋轉
  double? get rotateZ => _rotateZ;

  /// 水平翻轉
  double? get rotateY => _rotateY;

  /// 垂直翻轉
  double? get rotateX => _rotateX;

  /// 縮放
  Size? get scale => _scale;

  /// 透明
  double? get opacity => _opacity;

  /// size
  Size? get size => _size;

  /// 顏色
  Color? get color => _color;

  /// 動畫 toggle
  bool? get toggle => _toggle;

  Offset? _offset;
  double? _rotateZ;
  double? _rotateY;
  double? _rotateX;
  Size? _scale;
  double? _opacity;
  Size? _size;
  Color? _color;
  bool? _toggle;
  Alignment? _alignment;

  /// 將動畫數值組裝為元件
  Widget component(Widget child) {
    var childChain = child;

    var transform = Matrix4.identity();

    if (rotateX != null) {
      transform.rotateX(rotateX!);
    }

    if (rotateY != null) {
      transform.rotateY(rotateY!);
    }

    if (rotateZ != null) {
      transform.rotateZ(rotateZ!);
    }

    if (offset != null) {
      transform.translate(offset!.dx, offset!.dy);
    }

    if (scale != null) {
      transform.scale(scale!.width, scale!.height);
    }

    // 添加透明動畫
    childChain = Opacity(
      opacity: opacity ?? 1,
      child: childChain,
    );

    // 添加 size 動畫
    childChain = Container(
      color: color,
      width: size?.width,
      height: size?.height,
      child: childChain,
    );

    childChain = Transform(
      alignment: _alignment,
      transform: transform,
      child: childChain,
    );

    return childChain;
  }
}

/// List<Comb> 轉化而成的真正執行動畫的類別
class AnimationData {
  /// 縮放動畫列表, 用 Size 的方式實現x, y的分別控制
  @protected
  List<AnimationBinder<Size>> _scaleList = [];

  /// 旋轉動畫列表
  @protected
  List<AnimationBinder<double>> _rotateZList = [];

  /// 垂直翻轉動畫
  @protected
  List<AnimationBinder<double>> _rotateXList = [];

  /// 水平翻轉動畫
  @protected
  List<AnimationBinder<double>> _rotateYList = [];

  /// 偏移動畫列表
  @protected
  List<AnimationBinder<Offset>> _offsetList = [];

  /// 透明值動畫
  @protected
  List<AnimationBinder<double>> _opacityList = [];

  ///  寬動畫
  @protected
  List<AnimationBinder<Size>> _sizeList = [];

  ///  背景顏色動畫
  @protected
  List<AnimationBinder<Color?>> _colorList = [];

  /// 當前動畫數值
  AnimValue current = AnimValue();

  /// 當前動畫最後數值
  AnimValue _last = AnimValue();

  /// 同步 [AnimationController] 的 value
  void syncTickValue(double t) {
    var scaleAnimComb = _scaleList.where((e) => e._isActive(t));
    var rotateXAnim = _rotateXList.firstWhereOrNull((e) => e._isActive(t));
    var rotateYAnim = _rotateYList.firstWhereOrNull((e) => e._isActive(t));
    var rotateZAnim = _rotateZList.firstWhereOrNull((e) => e._isActive(t));
    var offsetAnimComb = _offsetList.where((e) => e._isActive(t));
    var opacityAnim = _opacityList.firstWhereOrNull((e) => e._isActive(t));
    var sizeAnimComb = _sizeList.where((e) => e._isActive(t));
    var colorAnim = _colorList.firstWhereOrNull((e) => e._isActive(t));

    if (scaleAnimComb.isNotEmpty) {
      var first = scaleAnimComb.first;
      switch (first.scaleType!) {
        case ScaleType.all:
          current._scale = first.animation.value;
          _last._scale = first.endValue;
          break;
        case ScaleType.width:
          var second = scaleAnimComb.firstWhereOrNull(
            (e) => e.scaleType == ScaleType.height,
          );
          if (second != null) {
            current._scale = Size(
              first.animation.value.width,
              second.animation.value.height,
            );
            _last._scale = Size(
              first.endValue.width,
              second.endValue.height,
            );
          } else {
            current._scale = first.animation.value;
            _last._scale = first.endValue;
          }
          break;
        case ScaleType.height:
          var second = scaleAnimComb.firstWhereOrNull(
            (e) => e.scaleType == ScaleType.width,
          );
          if (second != null) {
            current._scale = Size(
              second.animation.value.width,
              first.animation.value.height,
            );
            _last._scale = Size(
              second.endValue.width,
              first.endValue.height,
            );
          } else {
            current._scale = first.animation.value;
            _last._scale = first.endValue;
          }
          break;
      }
    } else {
      current._scale = _last._scale;
    }

    if (sizeAnimComb.isNotEmpty) {
      var first = sizeAnimComb.first;
      switch (first.sizeType!) {
        case SizeType.all:
          current._size = first.animation.value;
          _last._size = first.endValue;
          break;
        case SizeType.width:
          var second = sizeAnimComb.firstWhereOrNull(
            (e) => e.sizeType == SizeType.height,
          );
          if (second != null) {
            current._size = Size(
              first.animation.value.width,
              second.animation.value.height,
            );
            _last._size = Size(
              first.endValue.width,
              second.endValue.height,
            );
          } else {
            current._size = first.animation.value;
            _last._size = first.endValue;
          }
          break;
        case SizeType.height:
          var second = sizeAnimComb.firstWhereOrNull(
            (e) => e.sizeType == SizeType.width,
          );
          if (second != null) {
            current._size = Size(
              second.animation.value.width,
              first.animation.value.height,
            );
            _last._size = Size(
              second.endValue.width,
              first.endValue.height,
            );
          } else {
            current._size = first.animation.value;
            _last._size = first.endValue;
          }
          break;
      }
    } else {
      current._size = _last._size;
    }

    if (rotateXAnim != null) {
      current._rotateX = rotateXAnim.animation.value;
      _last._rotateX = rotateXAnim.endValue;
    } else {
      current._rotateX = _last._rotateX;
    }

    if (rotateYAnim != null) {
      current._rotateY = rotateYAnim.animation.value;
      _last._rotateY = rotateYAnim.endValue;
    } else {
      current._rotateY = _last._rotateY;
    }

    if (rotateZAnim != null) {
      current._rotateZ = rotateZAnim.animation.value;
      _last._rotateZ = rotateZAnim.endValue;
    } else {
      current._rotateZ = _last._rotateZ;
    }

    if (colorAnim != null) {
      current._color = colorAnim.animation.value;
      _last._color = colorAnim.endValue;
    } else {
      current._color = _last._color;
    }

    if (offsetAnimComb.isNotEmpty) {
      var first = offsetAnimComb.first;
      switch (first.transType!) {
        case TransType.all:
          current._offset = first.animation.value;
          _last._offset = first.endValue;
          break;
        case TransType.x:
          var second = offsetAnimComb.firstWhereOrNull(
            (e) => e.transType == TransType.y,
          );
          if (second != null) {
            current._offset = Offset(
              first.animation.value.dx,
              second.animation.value.dy,
            );
            _last._offset = Offset(
              first.endValue.dx,
              second.endValue.dy,
            );
          } else {
            current._offset = first.animation.value;
            _last._offset = first.endValue;
          }
          break;
        case TransType.y:
          var second = offsetAnimComb.firstWhereOrNull(
            (e) => e.transType == TransType.x,
          );
          if (second != null) {
            current._offset = Offset(
              second.animation.value.dx,
              first.animation.value.dy,
            );
            _last._offset = Offset(
              second.endValue.dx,
              first.endValue.dy,
            );
          } else {
            current._offset = first.animation.value;
            _last._offset = first.endValue;
          }
          break;
      }
    } else {
      current._offset = _last._offset;
    }

    if (opacityAnim != null) {
      current._opacity = opacityAnim.animation.value.clamp(0.0, 1.0);
      _last._opacity = opacityAnim.endValue.clamp(0.0, 1.0);
    } else {
      current._opacity = _last._opacity;
    }
  }
}

class AnimationBinder<T> {
  ShiftAnimation shift;
  Animation<T> animation;
  Interval interval;

  SizeType? sizeType;
  ScaleType? scaleType;
  TransType? transType;

  T endValue;

  double get endTime => interval.end;

  AnimationBinder({
    required this.animation,
    required this.interval,
    required this.shift,
    required this.endValue,
    this.sizeType,
    this.scaleType,
    this.transType,
  });

  bool _isActive(double t) {
    var shiftT = shift.getShiftT(t);
    return shiftT >= interval.begin && shiftT <= interval.end;
  }

  double getEndTime() {
    return interval.end;
  }
}

/// 動畫類型
enum AnimatedType {
  /// 重複執行(會動畫恢復)
  repeatReverse,

  /// 重複執行(不動畫恢復)
  repeat,

  /// 只執行一次(會動畫恢復)
  onceReverse,

  /// 只執行一次
  once,

  /// 動畫擁有開關設置[ToggleController], 由外部決定行為
  toggle,

  /// 按下執行動畫, 放開結束動畫
  tap,
}
