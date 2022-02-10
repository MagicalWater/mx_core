// extension OrNullList<E> on Iterable<E> {
//   E? get lastOrNull {
//     Iterator<E> it = iterator;
//     if (!it.moveNext()) {
//       return null;
//     }
//     E result;
//     do {
//       result = it.current;
//     } while (it.moveNext());
//     return result;
//   }
//
//   E? get firstOrNull {
//     Iterator<E> it = iterator;
//     if (!it.moveNext()) {
//       return null;
//     }
//     return it.current;
//   }
// }

extension IntersperseList<E> on List<E> {
  /// 在每個元素之間穿插
  /// [leading] - 列表開頭是否插入, 當列表為空時無效
  /// [trailing] - 列表結尾是否插入, 當列表為空時無效
  List<E> intersperse(E Function(int i) f, {
    bool leading = false,
    bool trailing = false,
  }) {
    return indexMap((e, i) {
      final elements = <E>[];
      if (i == 0 && leading) {
        elements.add(f(-1));
      }
      elements.add(e);
      if (trailing || i != length - 1) {
        elements.add(f(i));
      }
      return elements;
    }).expand((element) => element).toList();
  }

  List<T> indexMap<T>(T Function(E e, int i) f) {
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

extension InnerList on List {
  /// 兩層 list 的長度
  int get innerLen {
    var count = 0;
    forEach((element) {
      if (element is List) {
        count += element.length;
      }
    });
    return count;
  }
}
