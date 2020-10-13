extension BoundExtension on DateTime {
  DateTime get dayStart {
    return DateTime(year, month, day, 0, 0, 0);
  }

  DateTime get dayEnd {
    return DateTime(year, month, day, 23, 59, 59);
  }
}
