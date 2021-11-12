import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mx_core/mx_core.dart';

class ChartRepository {
  Future<List<KLineEntity>> getData() async {
    String result;
    result =
        await rootBundle.loadString('assets/jsons/chart_example/kline.json');
    var parseJson = json.decode(result);
    List list = parseJson['data'];
    var datas = list.map((item) => KLineEntity.fromJson(item)).toList();
    ChartDataCalculator.calculate(datas);
    return datas;
  }
}
