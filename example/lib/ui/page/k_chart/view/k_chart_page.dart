import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/repository/chart_repository.dart';
import 'package:mx_core_example/ui/page/k_chart/bloc/k_chart_bloc.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class KChartPage extends StatefulWidget {
  final RouteOption option;

  KChartPage(this.option) : super();

  @override
  _KChartPageState createState() => _KChartPageState();
}

class Test extends CustomPainter {
  var aa = 1;
  int? bb;

  @override
  void paint(Canvas canvas, Size size) {
    print('paint start: $aa, $bb');
    aa += 1;
    bb = 1;
    print('paint end: $aa, $bb');
  }

  @override
  bool shouldRepaint(covariant Test oldDelegate) {
    print(
        'shouldRepaint: $aa, $bb, old = ${oldDelegate.aa}, ${oldDelegate.bb}');
    return true;
  }
}

class _KChartPageState extends State<KChartPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          KChartBloc(ChartRepository())..add(KChartInitEvent()),
      child: _view(),
    );
  }

  Widget _view() {
    Widget _content(KChartState state) {
      if (state.isLoading) {
        return Container(
          height: 200.scaleA,
          alignment: Alignment.center,
        );
      } else {
        return Container(
          height: Screen.height * 2 / 3,
          child: KLineChart(
            datas: state.datas,
            mainChartState: state.mainChartState,
            volumeChartState: state.volumeChartState,
            indicatorChartState: state.indicatorChartState,
            chartUiStyle: KLineChartUiStyle(
              colorSetting: ChartColorSetting(),
              sizeSetting: ChartSizeSetting(),
              heightRatioSetting: ChartHeightRatioSetting(
                mainRatio: 0.7,
                volumeRatio: 0.15,
                indicatorRatio: 0.15,
              ),
            ),
            mainChartUiStyle: MainChartUiStyle(
              colorSetting: MainChartColorSetting(),
              sizeSetting: MainChartSizeSetting(),
            ),
            volumeChartUiStyle: VolumeChartUiStyle(
              colorSetting: VolumeChartColorSetting(),
              sizeSetting: VolumeChartSizeSetting(),
            ),
            macdChartUiStyle: MACDChartUiStyle(
              colorSetting: MACDChartColorSetting(),
              sizeSetting: MACDChartSizeSetting(),
            ),
            rsiChartUiStyle: RSIChartUiStyle(
              colorSetting: RSIChartColorSetting(),
              sizeSetting: RSIChartSizeSetting(),
            ),
            wrChartUiStyle: WRChartUiStyle(
              colorSetting: WRChartColorSetting(),
              sizeSetting: WRChartSizeSetting(),
            ),
            kdjChartUiStyle: KDJChartUiStyle(
              colorSetting: KDJChartColorSetting(),
              sizeSetting: KDJChartSizeSetting(),
            ),
            maPeriods: [5, 10, 20],
            priceFormatter: (price) => price.toStringAsFixed(2),
            volumeFormatter: (volume) {
              if (volume > 10000 && volume < 999999) {
                final d = volume / 1000;
                return '${d.toStringAsFixed(2)}K';
              } else if (volume > 1000000) {
                final d = volume / 1000000;
                return '${d.toStringAsFixed(2)}M';
              }
              return volume.toStringAsFixed(2);
            },
            xAxisDateTimeFormatter: (dateTime) => dateTime.getDateStr(
              format: 'MM-dd mm:ss',
            ),
            onLoadMore: (value) {
              print('加載更多: $value');
            },
            tooltipBuilder: (context, longPressData) {
              return KLineDataInfoTooltip(
                longPressData: longPressData,
              );
            },
          ),
        );
      }
    }

    return Scaffold(
      // backgroundColor: Color(0xff1e2129),
      backgroundColor: Colors.white,
      appBar: baseAppBar('行情圖表'),
      body: BlocBuilder<KChartBloc, KChartState>(
        builder: (context, state) {
          // print('是線條嗎: ${stateIsLine}');
          return ListView(
            children: <Widget>[
              Stack(children: <Widget>[
                Container(
                  width: double.infinity,
                  child: AnimatedSize(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    child: _content(state),
                  ),
                ),
                if (state.isLoading)
                  Container(
                      width: double.infinity,
                      height: 450,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
              ]),
              _buttons(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buttons(BuildContext context, KChartState state) {
    KChartBloc bloc() => context.read<KChartBloc>();

    Widget button(String text, {VoidCallback? onPressed}) {
      return TextButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        child: Text("$text"),
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button(
          "分時",
          onPressed: () {
            final chartState = List<MainChartState>.from(state.mainChartState);
            if (chartState.contains(MainChartState.lineIndex)) {
              chartState.remove(MainChartState.lineIndex);
              if (!chartState.contains(MainChartState.kLine)) {
                chartState.add(MainChartState.kLine);
              }
            } else {
              chartState.add(MainChartState.lineIndex);
              if (chartState.contains(MainChartState.kLine)) {
                chartState.remove(MainChartState.kLine);
              }
            }
            bloc().add(KChartMainStateEvent(state: chartState));
          },
        ),
        button(
          "k線",
          onPressed: () {
            final chartState = List<MainChartState>.from(state.mainChartState);
            if (chartState.contains(MainChartState.kLine)) {
              chartState.remove(MainChartState.kLine);
              if (!chartState.contains(MainChartState.lineIndex)) {
                chartState.remove(MainChartState.kLine);
              }
            } else {
              chartState.add(MainChartState.kLine);
              if (chartState.contains(MainChartState.lineIndex)) {
                chartState.remove(MainChartState.lineIndex);
              }
            }
            bloc().add(KChartMainStateEvent(state: chartState));
          },
        ),
        button(
          "MA",
          onPressed: () {
            final chartState = List<MainChartState>.from(state.mainChartState);
            if (chartState.contains(MainChartState.ma)) {
              chartState.remove(MainChartState.ma);
            } else {
              chartState.add(MainChartState.ma);
            }
            bloc().add(KChartMainStateEvent(state: chartState));
          },
        ),
        button(
          "BOLL",
          onPressed: () {
            final chartState = List<MainChartState>.from(state.mainChartState);
            if (chartState.contains(MainChartState.boll)) {
              chartState.remove(MainChartState.boll);
            } else {
              chartState.add(MainChartState.boll);
            }
            bloc().add(KChartMainStateEvent(state: chartState));
          },
        ),
        button(
          "隱藏主圖表",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: []));
          },
        ),
        button(
          "MACD",
          onPressed: () {
            bloc().add(KChartIndicatorChartStateEvent(
                state: IndicatorChartState.macd));
          },
        ),
        button(
          "KDJ",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.kdj));
          },
        ),
        button(
          "RSI",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.rsi));
          },
        ),
        button(
          "WR",
          onPressed: () {
            bloc().add(
                KChartIndicatorChartStateEvent(state: IndicatorChartState.wr));
          },
        ),
        button(
          "隱藏技術線視圖",
          onPressed: () {
            bloc().add(KChartIndicatorChartStateEvent(
                state: IndicatorChartState.none));
          },
        ),
        button(
          "update",
          onPressed: () {
            //更新最後一條數據
            bloc().add(KChartUpdateLastEvent());
          },
        ),
        button(
          "addData",
          onPressed: () {
            //拷貝一個對象，修改數據
            bloc().add(KChartAddDataEvent());
          },
        ),
      ],
    );
  }
}
