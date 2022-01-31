import 'dart:math';

import 'package:mx_core/ui/widget/k_line_chart/model/model.dart';

import 'indicator/indicator_kdj.dart';
import 'indicator/indicator_rsi.dart';
import 'indicator/indicator_wr.dart';

/// 圖表技術指標計算
class ChartIndicatorCalculator {
  /// 計算所有技術指標
  /// [maPeriods] - 收盤均線週期
  /// [bollPeriod] - boll線週期
  static calculateAllIndicator(
    List<KLineData> datas, {
    List<int> maPeriods = const [5, 10, 20],
    int bollPeriod = 20,
  }) {
    calculateMA(maPeriods, datas);
    calculateBOLL(bollPeriod, datas);
    calculateMACD(datas);
    calculateKDJ(datas);
    calculateRSI(datas);
    calculateWR(datas);
  }

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

  /// 計算指數平滑異同移動平均線
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

  /// 計算相對強弱指標
  static void calculateRSI(List<KLineData> datas) {
    double rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;

    for (var i = 1; i < datas.length; i++) {
      final data = datas[i];
      final closePrice = data.close;
      final rmax = max(0, closePrice - datas[i - 1].close);
      final rAbs = (closePrice - datas[i - 1].close).abs();

      rsiMaxEma = (rmax + (14 - 1) * rsiMaxEma) / 14;
      rsiABSEma = (rAbs + (14 - 1) * rsiABSEma) / 14;
      if (i < 13 || rsiABSEma == 0) {
        rsi = 0;
      } else {
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }

      data.indciatorData.rsi = IndicatorRSI(
        rsi: rsi,
        rsiABSEma: rsiABSEma,
        rsiMaxEma: rsiMaxEma,
      );
    }
  }

  /// 計算隨機指標
  static void calculateKDJ(List<KLineData> datas) {
    double k = 0;
    double d = 0;

    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      final closePrice = data.close;
      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      var max14 = -double.maxFinite;
      var min14 = double.maxFinite;
      for (var index = startIndex; index <= i; index++) {
        max14 = max(max14, datas[index].high);
        min14 = min(min14, datas[index].low);
      }

      double rsv;
      if (max14 == min14) {
        rsv = 0;
      } else {
        rsv = 100 * (closePrice - min14) / (max14 - min14);
      }

      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }

      if (i == 13 || i == 14) {
        data.indciatorData.kdj = IndicatorKDJ(k: k, d: 0, j: 0);
      } else if (i > 14) {
        data.indciatorData.kdj = IndicatorKDJ(k: k, d: d, j: 3 * k - 2 * d);
      }
    }
  }

  /// 計算威廉指標(兼具超買超賣和強弱分界的指標)
  /// WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
  static void calculateWR(List<KLineData> datas) {
    for (var i = 0; i < datas.length; i++) {
      final data = datas[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      var max14 = -double.maxFinite;
      var min14 = double.maxFinite;
      for (var index = startIndex; index <= i; index++) {
        max14 = max(max14, datas[index].high);
        min14 = min(min14, datas[index].low);
      }

      if (i >= 14) {
        final double r;
        if ((max14 - min14) == 0) {
          r = 0;
        } else {
          r = 100 * (max14 - datas[i].close) / (max14 - min14);
        }
        data.indciatorData.wr = IndicatorWR(r: r);
      }
    }
  }
}
