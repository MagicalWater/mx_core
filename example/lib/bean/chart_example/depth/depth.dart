class DepthBean {
  String? status;
  String? ch;
  int? ts;
  DepthTickBean? tick;

  DepthBean({
    this.status,
    this.ch,
    this.ts,
    this.tick,
  });

  DepthBean.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    ch = json['ch']?.toString();
    ts = json['ts'];
    tick = json['tick'] != null ? DepthTickBean.fromJson(json['tick']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'ch': ch,
      'ts': ts,
      'tick': tick?.toJson(),
    };
  }
}

class DepthTickBean {
  List<List<double>?>? bids;
  List<List<double>?>? asks;
  int? ts;
  int? version;

  DepthTickBean({
    this.bids,
    this.asks,
    this.ts,
    this.version,
  });

  DepthTickBean.fromJson(Map<String, dynamic> json) {
    if (json['bids'] != null) {
      bids = (json['bids'] as List)
          .map((e) => (e as List).map<double>((e) => e.toDouble()).toList())
          .toList();
    }
    if (json['asks'] != null) {
      asks = (json['asks'] as List)
          .map((e) => (e as List).map<double>((e) => e.toDouble()).toList())
          .toList();
    }
    ts = json['ts'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    return {
      'bids': bids,
      'asks': asks,
      'ts': ts,
      'version': version,
    };
  }
}
