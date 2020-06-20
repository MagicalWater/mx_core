import 'package:flutter/material.dart';
import 'package:mx_core/popup/arrow_style.dart';
import 'package:mx_core/popup/impl.dart';
import 'package:mx_core/ui/widget/material_layer.dart';

import 'animated_comb/animated_comb.dart';

/// 封裝了 箭頭彈出視窗 的元件
class ArrowPopupButton extends StatefulWidget {
  /// 點擊回饋, 當 [feedbackType] = [FeedbackType.material] 時失效
  final HitFeedback feedback;

  /// 點擊回饋的行為類型
  /// 當 type = [FeedbackType.material] 時, [feedback] 失效
  final FeedbackType feedbackType;

  /// 彈出視窗的構建
  final PopupWidgetBuilder popupBuilder;

  /// 彈出視窗的相關 style
  final ArrowPopupStyle popupStyle;

  /// 子元件
  final Widget child;

  /// 點擊控制器, 只有在 [feedbackType] = [FeedbackType.toggle] 時有效
  final PopupAction controller;

  final Color maskColor;

  ArrowPopupButton._({
    this.child,
    @required this.popupBuilder,
    this.feedback = const HitFeedback(),
    this.feedbackType = FeedbackType.toggle,
    this.popupStyle = const ArrowPopupStyle(),
    this.controller,
    this.maskColor,
  });

  factory ArrowPopupButton({
    Widget child,
    @required PopupWidgetBuilder popupBuilder,
    HitFeedback feedback = const HitFeedback(),
    FeedbackType feedbackType = FeedbackType.toggle,
    ArrowPopupStyle popupStyle = const ArrowPopupStyle(),
    PopupAction controller,
    Color maskColor,
  }) {
    return ArrowPopupButton._(
      child: AbsorbPointer(
        child: child,
      ),
      popupBuilder: popupBuilder,
      feedback: feedback,
      feedbackType: feedbackType,
      popupStyle: popupStyle,
      controller: controller,
      maskColor: maskColor,
    );
  }

  @override
  _ArrowPopupButtonState createState() => _ArrowPopupButtonState();
}

class _ArrowPopupButtonState extends State<ArrowPopupButton> {
  AnimatedSyncTick toggleController;
  PopupController popupController;

  @override
  void initState() {
    toggleController = AnimatedSyncTick.identity(type: AnimatedType.toggle);
    if (widget.feedbackType == FeedbackType.toggle) {
      widget.controller?._bind(
        show: () async {
          toggleController?.toggle(true);
          _showArrowPopup();
        },
        hide: () async {
          await toggleController?.toggle(false);
          await popupController.remove();
          popupController = null;
        },
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?._unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.feedbackType) {
      case FeedbackType.toggle:
        return AnimatedComb(
          child: widget.child,
          sync: toggleController,
          animatedList: _getFeedbackAnimated(),
          onTap: () {
            toggleController?.toggle(true);
            _showArrowPopup();
          },
        );
        break;
      case FeedbackType.tap:
        return AnimatedComb(
          type: AnimatedType.tap,
          child: widget.child,
          animatedList: _getFeedbackAnimated(),
          onTap: _showArrowPopup,
        );
        break;
      case FeedbackType.material:
        return MaterialLayer.single(
          child: widget.child,
          onTap: _showArrowPopup,
        );
        break;
    }
    return Container();
  }

  List<Comb> _getFeedbackAnimated() {
    List<Comb> list = [];
    if (widget.feedback.opacity != null) {
      var animated = Comb.opacity(end: widget.feedback.opacity);
      list.add(animated);
    }
    if (widget.feedback.scale != null) {
      var animated = Comb.scale(
        end: Size.square(widget.feedback.scale),
      );
      list.add(animated);
    }
    if (widget.feedback.rotate != null) {
      var animated = Comb.rotateZ(end: widget.feedback.rotate);
      list.add(animated);
    }
    return [Comb.parallel(animatedList: list)];
  }

  void _showArrowPopup() {
//    print("顯示popup");
    Popup.showArrow(
      context: context,
      onTapSpace: (controller) => controller.remove(),
      style: widget.popupStyle,
      maskColor: widget.maskColor,
      builder: (controller) {
        popupController = controller;
        // 若 FeedbackType 的類型為 toggle
        // 則需要註冊監聽關閉事件, 這樣此處才可以進行控制
        (controller as OverlayController).registerRemoveEventCallback(() {
          toggleController?.toggle();
        });
        return widget.popupBuilder(controller);
      },
    );
  }
}

/// 點擊回饋
class HitFeedback {
  final double opacity;
  final double scale;
  final double rotate;

  const HitFeedback({
    this.opacity = 0.8,
    this.scale = 1.5,
    this.rotate,
  });
}

/// 點擊回饋類型
enum FeedbackType {
  toggle,
  tap,
  material,
}

class PopupAction {
  Future<void> Function() _show;
  Future<void> Function() _hide;

  Future<void> show() async {
    if (_show != null) {
      return _show();
    }
  }

  Future<void> hide() async {
    if (_hide != null) {
      return _hide();
    }
  }

  void _bind({Future<void> Function() show, Future<void> Function() hide}) {
    _show = show;
    _hide = hide;
  }

  void _unbind() {
    _show = null;
    _hide = null;
  }
}
