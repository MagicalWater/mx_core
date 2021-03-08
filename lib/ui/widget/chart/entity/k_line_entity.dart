import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  double open;
  double high;
  double low;
  double close;
  double vol;
  double amount;
  int count;
  DateTime dateTime;

  KLineEntity({
    this.open,
    this.high,
    this.low,
    this.close,
    this.vol,
    this.amount,
    this.count,
    this.dateTime,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = (json['open'] as num)?.toDouble();
    high = (json['high'] as num)?.toDouble();
    low = (json['low'] as num)?.toDouble();
    close = (json['close'] as num)?.toDouble();
    vol = (json['vol'] as num)?.toDouble();
    amount = (json['amount'] as num)?.toDouble();
    count = (json['count'] as num)?.toInt();
    var second = (json['id'] as num)?.toInt();
    if (second != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(second * 1000);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (dateTime != null) {
      data['id'] = dateTime.millisecondsSinceEpoch ~/ 1000;
    }
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
    int id;
    if (dateTime != null) {
      id = dateTime.millisecondsSinceEpoch ~/ 1000;
    }
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}
