class KmonBean {
  String? status;
  String? ch;
  int? ts;
  List<KmonDataBean>? data;

  KmonBean({
    this.status,
    this.ch,
    this.ts,
    this.data,
  });

  KmonBean.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    ch = json['ch']?.toString();
    ts = json['ts'];
    if (json['data'] != null) {
      data =
          (json['data'] as List).map((e) => KmonDataBean.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'ch': ch,
      'ts': ts,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class KmonDataBean {
  double? amount;
  double? open;
  double? close;
  double? high;
  int? id;
  int? count;
  double? low;
  double? vol;

  KmonDataBean({
    this.amount,
    this.open,
    this.close,
    this.high,
    this.id,
    this.count,
    this.low,
    this.vol,
  });

  KmonDataBean.fromJson(Map<String, dynamic> json) {
    amount = json['amount']?.toDouble();
    open = json['open']?.toDouble();
    close = json['close']?.toDouble();
    high = json['high']?.toDouble();
    id = json['id'];
    count = json['count'];
    low = json['low']?.toDouble();
    vol = json['vol']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'open': open,
      'close': close,
      'high': high,
      'id': id,
      'count': count,
      'low': low,
      'vol': vol,
    };
  }
}
