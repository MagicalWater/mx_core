import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  @override
  late double open;
  @override
  late double high;
  @override
  late double low;
  @override
  late double close;

  late double vol;
  late double amount;
  late int count;
  late DateTime dateTime;

  KLineEntity({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.vol,
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
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['count'] = this.count;
    return data;
  }

  @override
  String toString() {
    int id = dateTime.millisecondsSinceEpoch ~/ 1000;
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}
