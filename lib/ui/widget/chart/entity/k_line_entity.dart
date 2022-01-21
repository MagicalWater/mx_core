import '../entity/k_entity.dart';

class KLineEntity implements KEntity {
  @override
  double open;

  @override
  double high;

  @override
  double low;

  @override
  double close;

  @override
  double vol;

  @override
  late double d;

  @override
  late double dea;

  @override
  late double dif;

  @override
  late double dn;

  @override
  late double ema12;

  @override
  late double ema26;

  @override
  late double j;

  @override
  late double k;

  @override
  late double ma10Price;

  @override
  late double ma10Volume;

  @override
  late double ma20Price;

  @override
  late double ma30Price;

  @override
  late double ma5Price;

  @override
  late double ma5Volume;

  @override
  late double macd;

  @override
  late double mb;

  @override
  late double r;

  @override
  late double rsi;

  @override
  late double rsiABSEma;

  @override
  late double rsiMaxEma;

  @override
  late double up;

  final double amount;
  final int count;
  DateTime dateTime;

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

  factory KLineEntity.fromJson(Map<String, dynamic> json) {
    final milliSecond = (json['date'] as num).toInt();
    return KLineEntity(
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      vol: (json['vol'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      dateTime: DateTime.fromMillisecondsSinceEpoch(milliSecond),
    );
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
