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
  List<E> intersperse(E Function(int i) f) {
    return indexMap((e, i) {
      if (i == length - 1) {
        return [e];
      } else {
        return [e, f(i)];
      }
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
