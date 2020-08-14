extension IntersperseList<E> on List<E> {
  /// 在每個元素之間穿插
  List<E> intersperse(E f(int i)) {
    return indexMap((e, i) {
      if (i == length - 1) {
        return [e];
      } else {
        return [e, f(i)];
      }
    }).expand((element) => element).toList();

  }

  List<T> indexMap<T>(T f(E e, int i)) {
    var index = 0;
    var mapsData = <T>[];
    for (var element in this) {
      var data = f(element, index);
      mapsData.add(data);
      index++;
    }
    return mapsData;
  }
}
