class ExApiBean {
  int? code;
  String? data;

  ExApiBean({
    this.code,
    this.data,
  });

  ExApiBean.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data,
    };
  }
}
