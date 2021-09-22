class KlineBean {
  String? code;
  String? name;
  String? type;
  int? startTime;
  int? endTime;
  List<KlineDataBean>? data;

  KlineBean({
    this.code,
    this.name,
    this.type,
    this.startTime,
    this.endTime,
    this.data,
  });

  KlineBean.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    name = json['name']?.toString();
    type = json['type']?.toString();
    startTime = json['startTime'];
    endTime = json['endTime'];
    if (json['data'] != null) {
      data =
          (json['data'] as List).map((e) => KlineDataBean.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class KlineDataBean {
  double? open;
  double? high;
  double? low;
  double? close;
  double? vol;
  double? amount;
  int? count;
  int? date;

  KlineDataBean({
    this.open,
    this.high,
    this.low,
    this.close,
    this.vol,
    this.amount,
    this.count,
    this.date,
  });

  KlineDataBean.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble();
    high = json['high']?.toDouble();
    low = json['low']?.toDouble();
    close = json['close']?.toDouble();
    vol = json['vol']?.toDouble();
    amount = json['amount']?.toDouble();
    count = json['count'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': vol,
      'amount': amount,
      'count': count,
      'date': date,
    };
  }
}
