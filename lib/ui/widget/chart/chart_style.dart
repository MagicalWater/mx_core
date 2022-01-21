import 'package:flutter/material.dart' show Color, Colors;

enum ChartUpDown {
  /// 綠漲(賣)紅跌(買)
  greenUpRedDown,

  /// 紅漲(賣)綠跌(買)
  redUpGreenDown,
}

class KDJStyle {
  /// 副圖表的kdj線圖三種顏色
  final Color kColor;
  final Color dColor;
  final Color jColor;
  final Color textColor;

  const KDJStyle.dark({
    this.kColor = _ChartColors.kColor,
    this.dColor = _ChartColors.dColor,
    this.jColor = _ChartColors.jColor,
    this.textColor = _ChartColors.yAxisTextColor,
  });

  const KDJStyle.light({
    this.kColor = _ChartReverseColors.kColor,
    this.dColor = _ChartReverseColors.dColor,
    this.jColor = _ChartReverseColors.jColor,
    this.textColor = _ChartReverseColors.yAxisTextColor,
  });
}

class RSIStyle {
  final Color color;

  const RSIStyle.dark({
    this.color = _ChartColors.rsiColor,
  });

  const RSIStyle.light({
    this.color = _ChartReverseColors.rsiColor,
  });
}

class WRStyle {
  final Color color;

  const WRStyle.dark({
    this.color = _ChartColors.rsiColor,
  });

  const WRStyle.light({
    this.color = _ChartReverseColors.rsiColor,
  });
}

class MACDStyle {
  final Color difColor;
  final Color deaColor;

  final Color sellUpColor;
  final Color sellDownColor;

  final Color buyUpColor;
  final Color buyDownColor;

  final Color textColor1;
  final Color textColor2;

  const MACDStyle.dark({
    this.difColor = _ChartColors.difColor,
    this.deaColor = _ChartColors.deaColor,
    this.textColor1 = _ChartColors.yAxisTextColor,
    this.textColor2 = _ChartColors.macdColor,
    this.sellUpColor = _ChartReverseColors.macdSellUpColor,
    this.sellDownColor = _ChartReverseColors.macdSellDnColor,
    this.buyUpColor = _ChartReverseColors.macdBuyUpColor,
    this.buyDownColor = _ChartReverseColors.macdBuyDnColor,
  });

  const MACDStyle.light({
    this.difColor = _ChartReverseColors.difColor,
    this.deaColor = _ChartReverseColors.deaColor,
    this.textColor1 = _ChartReverseColors.yAxisTextColor,
    this.textColor2 = _ChartReverseColors.macdColor,
    this.sellUpColor = _ChartReverseColors.macdSellUpColor,
    this.sellDownColor = _ChartReverseColors.macdSellDnColor,
    this.buyUpColor = _ChartReverseColors.macdBuyUpColor,
    this.buyDownColor = _ChartReverseColors.macdBuyDnColor,
  });

  MACDStyle setUpDown(ChartUpDown chartUpDown) {
    return MACDStyle.light(
      difColor: difColor,
      deaColor: deaColor,
      textColor1: textColor1,
      textColor2: textColor2,
      sellUpColor:
          chartUpDown == ChartUpDown.greenUpRedDown ? sellUpColor : buyUpColor,
      sellDownColor: chartUpDown == ChartUpDown.greenUpRedDown
          ? sellDownColor
          : buyDownColor,
      buyUpColor:
          chartUpDown == ChartUpDown.greenUpRedDown ? buyUpColor : sellUpColor,
      buyDownColor: chartUpDown == ChartUpDown.greenUpRedDown
          ? buyDownColor
          : sellDownColor,
    );
  }
}

/// 買賣量圖表
class DepthStyle {
  /// 預設文字顏色
  final Color textColor;

  final Color buyColor;
  final Color sellColor;

  /// tooltip 彈窗背景
  final Color tooltipBgColor;

  /// tooltip 彈窗外誆
  final Color tooltipBorderColor;

  const DepthStyle.dark({
    this.textColor = Colors.white,
    this.buyColor = _ChartColors.depthBuyColor,
    this.sellColor = _ChartColors.depthSellColor,
    this.tooltipBgColor = _ChartColors.markerBgColor,
    this.tooltipBorderColor = _ChartColors.markerBorderColor,
  });

  const DepthStyle.light({
    this.textColor = Colors.white,
    this.buyColor = _ChartReverseColors.depthBuyColor,
    this.sellColor = _ChartReverseColors.depthSellColor,
    this.tooltipBgColor = _ChartReverseColors.markerBgColor,
    this.tooltipBorderColor = _ChartReverseColors.markerBorderColor,
  });
}

/// 子圖表樣式
class SubChartStyle {
  final MACDStyle macd;
  final RSIStyle rsi;
  final WRStyle wr;
  final KDJStyle kdj;

  const SubChartStyle.dark({
    this.macd = const MACDStyle.dark(),
    this.rsi = const RSIStyle.dark(),
    this.wr = const WRStyle.dark(),
    this.kdj = const KDJStyle.dark(),
  });

  const SubChartStyle.light({
    this.macd = const MACDStyle.light(),
    this.rsi = const RSIStyle.light(),
    this.wr = const WRStyle.light(),
    this.kdj = const KDJStyle.light(),
  });

  /// 設置轉換漲跌/買賣顏色
  SubChartStyle setUpDown(ChartUpDown chartUpDown) {
    return SubChartStyle.light(
      macd: macd.setUpDown(chartUpDown),
      rsi: rsi,
      wr: wr,
      kdj: kdj,
    );
  }
}

class BOLLStyle {
  final Color color;
  final Color lbColor;
  final Color upColor;

  const BOLLStyle.dark({
    this.color = _ChartColors.ma5Color,
    this.lbColor = _ChartColors.ma10Color,
    this.upColor = _ChartColors.ma30Color,
  });

  const BOLLStyle.light({
    this.color = _ChartReverseColors.ma5Color,
    this.lbColor = _ChartReverseColors.ma10Color,
    this.upColor = _ChartReverseColors.ma30Color,
  });
}

class MAStyle {
  final Color ma5Color;
  final Color ma10Color;
  final Color ma20Color;
  final Color ma30Color;

  const MAStyle.dark({
    this.ma5Color = _ChartColors.ma5Color,
    this.ma10Color = _ChartColors.ma10Color,
    this.ma20Color = _ChartColors.ma20Color,
    this.ma30Color = _ChartColors.ma30Color,
  });

  const MAStyle.light({
    this.ma5Color = _ChartReverseColors.ma5Color,
    this.ma10Color = _ChartReverseColors.ma10Color,
    this.ma20Color = _ChartReverseColors.ma20Color,
    this.ma30Color = _ChartReverseColors.ma30Color,
  });
}

/// 主圖表樣式
class MainChartStyle {
  /// 圖表顏色
  final Color bgColor;

  /// 右邊y軸文字顏色
  final Color yAxisTextColor;

  /// 下方x軸文字顏色
  final Color xAxisTextColor;

  /// 選中後的值背景顏色
  final Color markerBgColor;

  /// 選中後的值邊框顏色
  final Color markerBorderColor;

  /// 最小值/最大值的文字顏色
  final Color minTextColor, maxTextColor;

  /// 最新實時線的文字顏色(圖表滑到最新)
  final Color rightRealTimeTextColor;

  /// 最新實時線的線條顏色(圖表滑到最新)
  final Color rightRealTimeLineColor;

  /// 最新實時線的背景顏色(圖表滑到最新)
  final Color rightRealTimeBgColor;

  /// 實時線的線條顏色(圖表不在最新)
  final Color realTimeLineColor;

  /// 實時線的外框顏色(圖表不在最新)
  final Color realTimeTextBorderColor;

  /// 實時線的背景顏色(圖表不在最新)
  final Color realTimeBgColor;

  /// 實時線的文字顏色(圖表不在最新)
  final Color realTimeTextColor;

  /// 實時線三角形箭頭顏色(圖表不在最新)
  final Color realTimeTriangleColor;

  /// 格線顏色
  final Color gridColor;

  /// ma顏色
  final MAStyle maStyle;
  final BOLLStyle bollStyle;

  /// 漲跌顏色
  final Color upColor;
  final Color downColor;

  /// 買賣顏色, 通常顏色的方向會跟著漲跌顏色更改
  final Color buyInColor;
  final Color sellOutColor;

  /// 分時線顏色
  final Color timelineColor;

  /// 分時線漸變色
  final List<Color> timelineShadowColor;

  /// 買賣量文字顏色
  final Color volTextColor;

  /// tooltip k線彈窗背景
  final Color tooltipBgColor;

  /// tooltip k線彈窗外誆
  final Color tooltipBorderColor;

  /// tooltip 的前綴文字顏色
  final Color tooltipPrefixTextColor;

  /// 選中後的交叉線橫豎線
  final Color markerVerticalLineColor;
  final Color markerHorizontalLineColor;

  /// 選中後的交叉線文字顏色
  final Color markerVerticalTextColor;
  final Color markerHorizontalTextColor;

  /// 線圖的時的實價標點閃閃動畫顏色(圖表在最新)
  final List<Color> rightRealTimeFlashPointColor;

  /// tooltip 無漲跌時的文字顏色
  final Color tooltipNoUpDownTextColor;

  /// k線區塊的外框顏色
  final Color candleStrokeColor;

  const MainChartStyle.dark({
    this.bgColor = _ChartColors.bgColor,
    this.yAxisTextColor = _ChartColors.yAxisTextColor,
    this.xAxisTextColor = _ChartColors.xAxisTextColor,
    this.markerBgColor = _ChartColors.markerBgColor,
    this.markerBorderColor = _ChartColors.markerBorderColor,
    this.minTextColor = _ChartColors.maxMinTextColor,
    this.maxTextColor = _ChartColors.maxMinTextColor,
    this.rightRealTimeTextColor = _ChartColors.rightRealTimeTextColor,
    this.rightRealTimeLineColor = _ChartColors.realTimeLineColor,
    this.rightRealTimeBgColor = _ChartColors.realTimeBgColor,
    this.realTimeLineColor = _ChartColors.realTimeLongLineColor,
    this.realTimeTextBorderColor = _ChartColors.realTimeTextBorderColor,
    this.realTimeBgColor = _ChartColors.realTimeBgColor,
    this.realTimeTextColor = _ChartColors.realTimeTextColor,
    this.realTimeTriangleColor = _ChartColors.realTimeTextColor,
    this.gridColor = _ChartColors.gridColor,
    this.maStyle = const MAStyle.dark(),
    this.bollStyle = const BOLLStyle.dark(),
    this.upColor = _ChartColors.upColor,
    this.downColor = _ChartColors.dnColor,
    this.buyInColor = _ChartColors.buyInColor,
    this.sellOutColor = _ChartColors.sellOutColor,
    this.timelineColor = _ChartColors.kLineColor,
    this.timelineShadowColor = _ChartColors.kLineShadowColor,
    this.volTextColor = _ChartColors.volColor,
    this.tooltipBgColor = _ChartColors.markerBgColor,
    this.tooltipBorderColor = _ChartColors.markerBorderColor,
    this.tooltipPrefixTextColor = Colors.white,
    this.markerVerticalLineColor = Colors.white12,
    this.markerHorizontalLineColor = Colors.white,
    this.markerVerticalTextColor = Colors.white,
    this.markerHorizontalTextColor = Colors.white,
    this.rightRealTimeFlashPointColor = const [
      Colors.white,
      Colors.transparent
    ],
    this.tooltipNoUpDownTextColor = Colors.white,
    this.candleStrokeColor = _ChartReverseColors.candleBorderColor,
  });

  const MainChartStyle.light({
    this.bgColor = Colors.white,
    this.yAxisTextColor = _ChartReverseColors.yAxisTextColor,
    this.xAxisTextColor = _ChartReverseColors.xAxisTextColor,
    this.markerBgColor = _ChartReverseColors.markerBgColor,
    this.markerBorderColor = _ChartReverseColors.markerBorderColor,
    this.minTextColor = _ChartReverseColors.maxMinTextColor,
    this.maxTextColor = _ChartReverseColors.maxMinTextColor,
    this.rightRealTimeTextColor = _ChartReverseColors.rightRealTimeTextColor,
    this.rightRealTimeLineColor = _ChartReverseColors.realTimeLineColor,
    this.rightRealTimeBgColor = _ChartReverseColors.realTimeBgColor,
    this.realTimeLineColor = _ChartReverseColors.realTimeLongLineColor,
    this.realTimeTextBorderColor = _ChartReverseColors.realTimeTextBorderColor,
    this.realTimeBgColor = _ChartReverseColors.realTimeBgColor,
    this.realTimeTextColor = _ChartReverseColors.realTimeTextColor,
    this.realTimeTriangleColor = _ChartReverseColors.realTimeTextColor,
    this.gridColor = _ChartReverseColors.gridColor,
    this.maStyle = const MAStyle.light(),
    this.bollStyle = const BOLLStyle.light(),
    this.upColor = _ChartReverseColors.upColor,
    this.downColor = _ChartReverseColors.dnColor,
    this.buyInColor = _ChartReverseColors.buyInColor,
    this.sellOutColor = _ChartReverseColors.sellOutColor,
    this.timelineColor = _ChartReverseColors.kLineColor,
    this.timelineShadowColor = _ChartReverseColors.kLineShadowColor,
    this.volTextColor = _ChartReverseColors.volColor,
    this.tooltipBgColor = _ChartReverseColors.markerBgColor,
    this.tooltipBorderColor = _ChartReverseColors.markerBorderColor,
    this.tooltipPrefixTextColor = Colors.black,
    this.markerVerticalLineColor = Colors.black12,
    this.markerHorizontalLineColor = Colors.black,
    this.markerVerticalTextColor = Colors.black,
    this.markerHorizontalTextColor = Colors.black,
    this.rightRealTimeFlashPointColor = const [
      Colors.blueAccent,
      Color(0x00ffffff),
    ],
    this.tooltipNoUpDownTextColor = Colors.black,
    this.candleStrokeColor = _ChartReverseColors.candleBorderColor,
  });

  /// 設置轉換漲跌/買賣顏色
  MainChartStyle setUpDown(ChartUpDown chartUpDown) {
    return MainChartStyle.light(
      bgColor: bgColor,
      yAxisTextColor: yAxisTextColor,
      xAxisTextColor: xAxisTextColor,
      markerBgColor: markerBgColor,
      markerBorderColor: markerBorderColor,
      minTextColor: minTextColor,
      maxTextColor: maxTextColor,
      rightRealTimeTextColor: rightRealTimeTextColor,
      rightRealTimeLineColor: rightRealTimeLineColor,
      rightRealTimeBgColor: rightRealTimeBgColor,
      realTimeLineColor: realTimeLineColor,
      realTimeTextBorderColor: realTimeTextBorderColor,
      realTimeBgColor: realTimeBgColor,
      realTimeTextColor: realTimeTextColor,
      realTimeTriangleColor: realTimeTriangleColor,
      gridColor: gridColor,
      maStyle: maStyle,
      bollStyle: bollStyle,
      upColor: chartUpDown == ChartUpDown.greenUpRedDown ? upColor : downColor,
      downColor:
          chartUpDown == ChartUpDown.greenUpRedDown ? downColor : upColor,
      buyInColor:
          chartUpDown == ChartUpDown.greenUpRedDown ? buyInColor : sellOutColor,
      sellOutColor:
          chartUpDown == ChartUpDown.greenUpRedDown ? sellOutColor : buyInColor,
      timelineColor: timelineColor,
      timelineShadowColor: timelineShadowColor,
      volTextColor: volTextColor,
      tooltipBgColor: tooltipBgColor,
      tooltipBorderColor: tooltipBorderColor,
      tooltipPrefixTextColor: tooltipPrefixTextColor,
      markerVerticalLineColor: markerVerticalLineColor,
      markerHorizontalLineColor: markerHorizontalLineColor,
      markerVerticalTextColor: markerVerticalTextColor,
      markerHorizontalTextColor: markerHorizontalTextColor,
      rightRealTimeFlashPointColor: rightRealTimeFlashPointColor,
      tooltipNoUpDownTextColor: tooltipNoUpDownTextColor,
      candleStrokeColor: candleStrokeColor,
    );
  }
}

class _ChartColors {
  _ChartColors._();

  // static const dark01 = const Color(0xff171b26);
  // static const dark02 = const Color(0xff232632);
  // static const tealish01 = const Color(0xff26a39d);
  // static const pastelRed01 = const Color(0xffeb524f);
  // static const clearBlue01 = const Color(0xff229fff);
  // static const darkGreenBlue = const Color(0xff1c5e5e);
  // static const brownishPurple = const Color(0xff82363a);
  // static const pastelPink = const Color(0xffe5c9cc);
  // static const tealish02 = const Color(0xff26a79c);
  // static const lightGreyBlue01 = const Color(0xffb1c7c4);
  // static const darkishGreen = const Color(0xff1b612f);
  // static const rustyRed01 = const Color(0xffbf1c1c);
  // static const clearBlue02 = const Color(0xff2e8efb);

  //背景颜色
  static const Color bgColor = Color(0xff171b26);
  static const Color kLineColor = Color(0xff4C86CD);
  static const Color gridColor = Color(0xff2c303e);
  static const List<Color> kLineShadowColor = [
    Color(0x554C86CD),
    Color(0x00000000)
  ]; //k线阴影渐变
  static const Color ma5Color = Color(0xffb47731);
  static const Color ma10Color = Color(0xffae33ba);
  static const Color ma20Color = Color(0xff59d0d0);
  static const Color ma30Color = Color(0xff59d0d0);
  static const Color upColor = Color(0xff26a39d);
  static const Color dnColor = Color(0xffd55c5a);

  static const Color buyInColor = Color(0xff1d5f5e);
  static const Color sellOutColor = Color(0xff82363a);

  static const Color candleBorderColor = Color(0xff656565);

  static const Color volColor = Color(0xff4729AE);

  static const Color macdColor = Color(0xffb8d651);
  static const Color macdSellUpColor = Color(0xff1d5f5e);
  static const Color macdSellDnColor = Color(0xff3b9594);
  static const Color macdBuyUpColor = Color(0xff82363a);
  static const Color macdBuyDnColor = Color(0xffc6676c);
  static const Color difColor = Color(0xffae33ba);
  static const Color deaColor = Color(0xff59d0d0);

  static const Color kColor = Color(0xffb47731);
  static const Color dColor = Color(0xffae33ba);
  static const Color jColor = Color(0xff59d0d0);
  static const Color rsiColor = Color(0xffae33ba);

  static const Color yAxisTextColor = Color(0xff60738E); //右边y轴刻度
  static const Color xAxisTextColor = Color(0xff60738E); //下方时间刻度

  static const Color maxMinTextColor = Color(0xffffffff); //最大最小值的颜色

  //深度颜色
  static const Color depthBuyColor = Color(0xff60A893);
  static const Color depthSellColor = Color(0xffC15866);

  //选中后显示值边框颜色
  static const Color markerBorderColor = Color(0xff6C7A86);

  //选中后显示值背景的填充颜色
  static const Color markerBgColor = Color(0xff0D1722);

  //实时线颜色等
  static const Color realTimeBgColor = Color(0xff0D1722);
  static const Color rightRealTimeTextColor = Color(0xff4C86CD);
  static const Color realTimeTextBorderColor = Color(0xffffffff);
  static const Color realTimeTextColor = Color(0xffffffff);

  //实时线
  static const Color realTimeLineColor = Color(0xffffffff);
  static const Color realTimeLongLineColor = Color(0xff4C86CD);

  static const Color simpleLineUpColor = Color(0xff6CB0A6);
  static const Color simpleLineDnColor = Color(0xffC15466);
}

class _ChartReverseColors {
  _ChartReverseColors._();

  //背景颜色
  static const Color bgColor = Color(0xfff2ebe1);
  static const Color kLineColor = Color(0xff4C86CD);
  static const Color gridColor = Color(0xffe1ecf2);
  static const List<Color> kLineShadowColor = [
    Color(0x554C86CD),
    Color(0x00ffffff)
  ]; //k线阴影渐变
  static const Color ma5Color = Color(0xffb47731);
  static const Color ma10Color = Color(0xffae33ba);
  static const Color ma20Color = Color(0xff59d0d0);
  static const Color ma30Color = Color(0xff59d0d0);
  static const Color upColor = Color(0xff19aa1e);
  static const Color dnColor = Color(0xffd55c5a);
  static const Color buyInColor = Color(0xff1d5f5e);
  static const Color sellOutColor = Color(0xff82363a);
  static const Color candleBorderColor = Color(0xff656565);
  static const Color volColor = Color(0xffb8d651);

  static const Color macdColor = Color(0xffb8d651);
  static const Color macdSellUpColor = Color(0xff1d5f5e);
  static const Color macdSellDnColor = Color(0xff3b9594);
  static const Color macdBuyUpColor = Color(0xff82363a);
  static const Color macdBuyDnColor = Color(0xffc6676c);
  static const Color difColor = Color(0xffae33ba);
  static const Color deaColor = Color(0xff59d0d0);

  static const Color kColor = Color(0xffb47731);
  static const Color dColor = Color(0xffae33ba);
  static const Color jColor = Color(0xff59d0d0);
  static const Color rsiColor = Color(0xffae33ba);

  static const Color yAxisTextColor = Color(0xff9f8c71); //右边y轴刻度
  static const Color xAxisTextColor = Color(0xff9f8c71); //下方时间刻度

  static const Color maxMinTextColor = Color(0xff000000); //最大最小值的颜色

  //深度颜色
  static const Color depthBuyColor = Color(0xff9f576c);
  static const Color depthSellColor = Color(0xff938579);

  //选中后显示值边框颜色
  static const Color markerBorderColor = Color(0xff938579);

  //选中后显示值背景的填充颜色
  static const Color markerBgColor = Color(0xffffffff);

  //实时线颜色等
  static const Color realTimeBgColor = Color(0xfff2e8dd);
  static const Color rightRealTimeTextColor = Color(0xffb37932);
  static const Color realTimeTextBorderColor = Color(0xff000000);
  static const Color realTimeTextColor = Color(0xff000000);

  //实时线
  static const Color realTimeLineColor = Color(0xff000000);
  static const Color realTimeLongLineColor = Color(0xffb37932);

  static const Color simpleLineUpColor = Color(0xff934f59);
  static const Color simpleLineDnColor = Color(0xff3eab99);
}

class ChartStyle {
  ChartStyle._();

  //点与点的距离
  static const double pointWidth = 8.0;

  //蜡烛宽度
  static const double candleWidth = 7;

  //蜡烛中间线的宽度
  static const double candleLineWidth = 1.3;

  //vol柱子宽度
  static const double volWidth = 7;

  //macd柱子宽度
  static const double macdWidth = 7;

  //垂直交叉线宽度
  static const double vCrossWidth = 4.5;

  //水平交叉线宽度
  static const double hCrossWidth = 0.5;

  //网格
  static const int gridRows = 3, gridColumns = 4;

  static const double topPadding = 30.0,
      bottomDateHigh = 20.0,
      childPadding = 25.0;

  static const double defaultTextSize = 10.0;
}
