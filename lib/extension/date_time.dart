extension BoundExtension on DateTime {
  DateTime get dayStart {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    } else {
      return DateTime(year, month, day);
    }
  }

  DateTime get dayEnd {
    if (isUtc) {
      return DateTime.utc(year, month, day, 23, 59, 59);
    } else {
      return DateTime(year, month, day, 23, 59, 59);
    }
  }
}
