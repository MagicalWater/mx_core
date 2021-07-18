class ActionWidth {
  final int? flex;
  final bool? shrinkWrap;
  final double? fixed;

  /// 只有在 [AbstractTabWidget.scrollable] = false 時有效
  const ActionWidth.flex([this.flex = 1])
      : assert(flex != null),
        shrinkWrap = null,
        fixed = null;

  const ActionWidth.shrinkWrap()
      : this.shrinkWrap = true,
        flex = null,
        fixed = null;

  const ActionWidth.fixed(this.fixed)
      : assert(fixed != null),
        shrinkWrap = null,
        flex = null;
}
