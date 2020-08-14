class ActionWidth {
  final int flex;
  final bool shrinkWrap;
  final double fixed;

  /// 只有在 [AbstractTabWidget.scrollable] = true 時
  ActionWidth.flex([this.flex = 1])
      : assert(flex != null),
        shrinkWrap = null,
        fixed = null;

  ActionWidth.shrinkWrap()
      : this.shrinkWrap = true,
        flex = null,
        fixed = null;

  ActionWidth.fixed(this.fixed)
      : assert(fixed != null),
        shrinkWrap = null,
        flex = null;
}
