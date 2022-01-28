import 'dart:math';

import 'package:mx_core/ui/widget/k_line_chart/model/k_line_data/indicator/indicator.dart';
import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';

/// 圖表技術指標計算
class ChartIndicatorCalculator {
  // static calculate(List<KLineData> datas) {
  //   _calculateMA(datas);
  //   _calculateBOLL(datas);
  //   // _calcVolumeMA(datas);
  //   // _calcKDJ(datas);
  //   _calculateMACD(datas);
  //   // _calcRSI(datas);
  //   // _calcWR(datas);
  // }

  /// 計算收盤價均線
  static calculateMA(List<int> periods, List<KLineData> datas) {
    var periodMaValue = List<double>.generate(periods.length, (index) => 0);

    for (var i = 0; i < datas.length; i++) {
      final indicator = IndicatorMa();
      final data = datas[i];
      final close = data.close;

      periodMaValue = periodMaValue.map((e) => e + close).toList();

      for (var j = 0; j < periods.length; j++) {
        final period = periods[j];
        var value = periodMaValue[j];
        if (i == period - 1) {
          indicator.ma[period] = value / period;
        } else if (i >= period) {
          final removeValue = datas[i - period].close;
          value -= removeValue;
          periodMaValue[j] = value;
          indicator.ma[period] = value / period;
        }
      }

      data.indciatorData.ma = indicator;
    }
  }

  /// 計算boll線
  static void calculateBOLL(int period, List<KLineData> datas) {
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      // 先檢查是否有均線
      final indicatorMaValue = data.indciatorData.ma?.ma[period];
      if (indicatorMaValue == null) {
        continue;
      }

      double? mb, up, dn;
      if (i >= period) {
        double md = 0;
        for (var j = i - period + 1; j <= i; j++) {
          final c = datas[j].close;
          final value = c - indicatorMaValue;
          md += value * value;
        }
        md = md / (period - 1);
        md = sqrt(md);
        mb = indicatorMaValue;
        up = mb + 2.0 * md;
        dn = mb - 2.0 * md;

        data.indciatorData.boll = IndicatorBOLL(mb: mb, up: up, dn: dn);
      }
    }
  }

  static void calculateMACD(List<KLineData> datas) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final close = data.close;
      if (i == 0) {
        ema12 = close;
        ema26 = close;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + close * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + close * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;

      data.indciatorData.macd = IndicatorMACD(
        dea: dea,
        dif: dif,
        macd: macd,
        ema12: ema12,
        ema26: ema26,
      );
    }
  }

// static void _calcVolumeMA(List<KLineEntity> dataList, [bool isLast = false]) {
//   double volumeMa5 = 0;
//   double volumeMa10 = 0;
//
//   int i = 0;
//   if (isLast && dataList.length > 10) {
//     i = dataList.length - 1;
//     var data = dataList[dataList.length - 2];
//     volumeMa5 = data.ma5Volume * 5;
//     volumeMa10 = data.ma10Volume * 10;
//   }
//
//   for (; i < dataList.length; i++) {
//     KLineEntity entry = dataList[i];
//
//     volumeMa5 += entry.vol;
//     volumeMa10 += entry.vol;
//
//     if (i == 4) {
//       entry.ma5Volume = (volumeMa5 / 5);
//     } else if (i > 4) {
//       volumeMa5 -= dataList[i - 5].vol;
//       entry.ma5Volume = volumeMa5 / 5;
//     } else {
//       entry.ma5Volume = 0;
//     }
//
//     if (i == 9) {
//       entry.ma10Volume = volumeMa10 / 10;
//     } else if (i > 9) {
//       volumeMa10 -= dataList[i - 10].vol;
//       entry.ma10Volume = volumeMa10 / 10;
//     } else {
//       entry.ma10Volume = 0;
//     }
//   }
// }

// static void _calcRSI(List<KLineEntity> dataList, [bool isLast = false]) {
//   double rsi;
//   double rsiABSEma = 0;
//   double rsiMaxEma = 0;
//
//   int i = 0;
//   if (isLast && dataList.length > 1) {
//     i = dataList.length - 1;
//     var data = dataList[dataList.length - 2];
//     rsi = data.rsi;
//     rsiABSEma = data.rsiABSEma;
//     rsiMaxEma = data.rsiMaxEma;
//   }
//
//   for (; i < dataList.length; i++) {
//     KLineEntity entity = dataList[i];
//     final double closePrice = entity.close;
//     if (i == 0) {
//       rsi = 0;
//       rsiABSEma = 0;
//       rsiMaxEma = 0;
//     } else {
//       double rmax = max(0, closePrice - dataList[i - 1].close);
//       double rAbs = (closePrice - dataList[i - 1].close).abs();
//
//       rsiMaxEma = (rmax + (14 - 1) * rsiMaxEma) / 14;
//       rsiABSEma = (rAbs + (14 - 1) * rsiABSEma) / 14;
//       rsi = (rsiMaxEma / rsiABSEma) * 100;
//     }
//     if (i < 13) rsi = 0;
//     if (rsi.isNaN) rsi = 0;
//     entity.rsi = rsi;
//     entity.rsiABSEma = rsiABSEma;
//     entity.rsiMaxEma = rsiMaxEma;
//   }
// }
//
// static void _calcKDJ(List<KLineEntity> dataList, [bool isLast = false]) {
//   double k = 0;
//   double d = 0;
//
//   int i = 0;
//   if (isLast && dataList.length > 1) {
//     i = dataList.length - 1;
//     var data = dataList[dataList.length - 2];
//     k = data.k;
//     d = data.d;
//   }
//
//   for (; i < dataList.length; i++) {
//     KLineEntity entity = dataList[i];
//     final double closePrice = entity.close;
//     int startIndex = i - 13;
//     if (startIndex < 0) {
//       startIndex = 0;
//     }
//     double max14 = -double.maxFinite;
//     double min14 = double.maxFinite;
//     for (int index = startIndex; index <= i; index++) {
//       max14 = max(max14, dataList[index].high);
//       min14 = min(min14, dataList[index].low);
//     }
//     double rsv = 100 * (closePrice - min14) / (max14 - min14);
//     if (rsv.isNaN) {
//       rsv = 0;
//     }
//     if (i == 0) {
//       k = 50;
//       d = 50;
//     } else {
//       k = (rsv + 2 * k) / 3;
//       d = (k + 2 * d) / 3;
//     }
//     if (i < 13) {
//       entity.k = 0;
//       entity.d = 0;
//       entity.j = 0;
//     } else if (i == 13 || i == 14) {
//       entity.k = k;
//       entity.d = 0;
//       entity.j = 0;
//     } else {
//       entity.k = k;
//       entity.d = d;
//       entity.j = 3 * k - 2 * d;
//     }
//   }
// }
//
// //WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
// static void _calcWR(List<KLineEntity> dataList, [bool isLast = false]) {
//   int i = 0;
//   if (isLast && dataList.length > 1) {
//     i = dataList.length - 1;
//   }
//   for (; i < dataList.length; i++) {
//     KLineEntity entity = dataList[i];
//     int startIndex = i - 14;
//     if (startIndex < 0) {
//       startIndex = 0;
//     }
//     double max14 = -double.maxFinite;
//     double min14 = double.maxFinite;
//     for (int index = startIndex; index <= i; index++) {
//       max14 = max(max14, dataList[index].high);
//       min14 = min(min14, dataList[index].low);
//     }
//     if (i < 13) {
//       entity.r = 0;
//     } else {
//       if ((max14 - min14) == 0) {
//         entity.r = 0;
//       } else {
//         entity.r = 100 * (max14 - dataList[i].close) / (max14 - min14);
//       }
//     }
//   }
// }
}
