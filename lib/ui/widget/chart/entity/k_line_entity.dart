import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  @override
  // ignore: overridden_fields
  late double open;
  @override
  // ignore: overridden_fields
  late double high;
  @override
  // ignore: overridden_fields
  late double low;
  @override
  // ignore: overridden_fields
  late double close;

  @override
  // ignore: overridden_fields
  late double vol;
  late double amount;
  late int count;
  late DateTime dateTime;

  KLineEntity({
    required double open,
    required double high,
    required double low,
    required double close,
    required double vol,
    required this.amount,
    required this.count,
    required this.dateTime,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = (json['open'] as num).toDouble();
    high = (json['high'] as num).toDouble();
    low = (json['low'] as num).toDouble();
    close = (json['close'] as num).toDouble();
    vol = (json['vol'] as num).toDouble();
    amount = (json['amount'] as num).toDouble();
    count = (json['count'] as num).toInt();
    var milliSecond = (json['date'] as num).toInt();
    dateTime = DateTime.fromMillisecondsSinceEpoch(milliSecond);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['date'] = dateTime.millisecondsSinceEpoch;
    data['open'] = open;
    data['close'] = close;
    data['high'] = high;
    data['low'] = low;
    data['vol'] = vol;
    data['amount'] = amount;
    data['count'] = count;
    return data;
  }

  @override
  String toString() {
    int id = dateTime.millisecondsSinceEpoch ~/ 1000;
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}
