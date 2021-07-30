import 'dart:convert';
import 'dart:math';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/k_chart_bloc.dart';

class KChartPage extends StatefulWidget {
  final RouteOption option;

  KChartPage(this.option) : super();

  @override
  _KChartPageState createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> with TickerProviderStateMixin {
  KChartBloc bloc;
  List<KLineEntity> datas;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = false;
  List<DepthEntity> _bids = [], _asks = [];

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<KChartBloc>(context);
    getData('1day');
    // rootBundle
    //     .loadString('assets/jsons/chart_example/depth.json')
    //     .then((result) {
    //   final parseJson = json.decode(result);
    //   Map tick = parseJson['tick'];
    //   var bids = tick['bids']
    //       .map((item) => DepthEntity(item[0], item[1]))
    //       .toList()
    //       .cast<DepthEntity>();
    //   var asks = tick['asks']
    //       .map((item) => DepthEntity(item[0], item[1]))
    //       .toList()
    //       .cast<DepthEntity>();
    //   initDepth(bids, asks);
    // });
  }

  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    double amount = 0.0;
    bids?.sort((left, right) => left.price.compareTo(right.price));
    //倒序循環 //累加買入委託量
    bids.reversed.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _bids.insert(0, item);
    });

    amount = 0.0;
    asks?.sort((left, right) => left.price.compareTo(right.price));
    //循環 //累加買入委託量
    asks?.forEach((item) {
      amount += item.amount;
      item.amount = amount;
      _asks.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (showLoading) {
      content = Container(
        height: 200.scaleA,
        alignment: Alignment.center,
      );
    } else {
      // inChartWidgetInit = true;
      content = Container(
        height: Screen.height * 2 / 3,
        child: KChart(
          datas ?? [],
          isLine: isLine,
          mainState: _mainState,
          secondaryState: _secondaryState,
          volState: VolState.VOL,
          fractionDigits: 4,
          longPressY: ChartLongPressY.absolute,
          maLine: [
            MALine.ma5,
            // MALine.ma10,
            // MALine.ma20,
            // MALine.ma30,
          ],
          onLoadMore: (isRight) {
            print('加載更多: $isRight');
          },
          onDataLessOnePage: () {
            print('資料未滿一頁');
          },
        ),
      );
    }

    return PageScaffold(
      color: Colors.white,
      haveAppBar: true,
      appBar: AppBar(title: Text('行情圖表')),
      child: ListView(
        children: <Widget>[
          Stack(children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              width: double.infinity,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                child: content,
              ),
            ),
            if (showLoading)
              Container(
                  width: double.infinity,
                  height: 450,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
          ]),
          buildButtons(),
          Container(
            height: 230,
            width: double.infinity,
            child: DepthChart(
              bids: _bids,
              asks: _asks,
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("分時", onPressed: () => isLine = true),
        button("k線", onPressed: () => isLine = false),
        button("MA", onPressed: () => _mainState = MainState.MA),
        button("BOLL", onPressed: () => _mainState = MainState.BOLL),
        button("隱藏", onPressed: () => _mainState = MainState.NONE),
        button("MACD", onPressed: () => _secondaryState = SecondaryState.MACD),
        button("KDJ", onPressed: () => _secondaryState = SecondaryState.KDJ),
        button("RSI", onPressed: () => _secondaryState = SecondaryState.RSI),
        button("WR", onPressed: () => _secondaryState = SecondaryState.WR),
        button("隱藏副視圖", onPressed: () => _secondaryState = SecondaryState.NONE),
        button("update", onPressed: () {
          //更新最後一條數據
          datas.last.close += (Random().nextInt(100) - 50).toDouble();
          datas.last.high = max(datas.last.high, datas.last.close);
          datas.last.low = min(datas.last.low, datas.last.close);
          ChartDataCalculator.updateLastData(datas);
        }),
        button("addData", onPressed: () {
          //拷貝一個對象，修改數據
          var kLineEntity = KLineEntity.fromJson(datas.last.toJson());
          kLineEntity.dateTime = kLineEntity.dateTime.add(Duration(days: 1));
          kLineEntity.open = kLineEntity.close;
          kLineEntity.close += (Random().nextInt(100) - 50).toDouble();
          datas.last.high = max(datas.last.high, datas.last.close);
          datas.last.low = min(datas.last.low, datas.last.close);
          ChartDataCalculator.addLastData(datas, kLineEntity);
        }),
        button("1month", onPressed: () async {
//              showLoading = true;
//              setState(() {});
          //getData('1mon');
          String result = await rootBundle
              .loadString('assets/jsons/chart_example/kmon.json');
          Map parseJson = json.decode(result);
          List list = parseJson['data'];
          datas = list
              .map((item) => KLineEntity.fromJson(item))
              .toList()
              .reversed
              .toList()
              .cast<KLineEntity>();
          ChartDataCalculator.calculate(datas);
        }),
        FlatButton(
            onPressed: () {
              showLoading = true;
              setState(() {});
              getData('1day');
            },
            child: Text("1day"),
            color: Colors.blue),
      ],
    );
  }

  Widget button(String text, {VoidCallback onPressed}) {
    return FlatButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        child: Text("$text"),
        color: Colors.blue);
  }

  void getData(String period) async {
    String result;
    result =
        await rootBundle.loadString('assets/jsons/chart_example/kline.json');
    Map parseJson = json.decode(result);
    List list = parseJson['data'];
    datas = list
        .map((item) => KLineEntity.fromJson(item))
        .toList();
    ChartDataCalculator.calculate(datas);
    showLoading = false;
    setState(() {});
    return;
  }
}
