class TagStacks<T> {
  /// 完整歷史中的index
  final int historyIndex;

  /// 顯示中的index
  final int displayIndex;

  final T tag;

  TagStacks({
    required this.historyIndex,
    required this.displayIndex,
    required this.tag,
  });
}
