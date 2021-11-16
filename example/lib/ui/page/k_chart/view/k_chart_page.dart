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
          child: KChart(
            state.datas,
            isLine: state.isLine,
            mainState: state.mainState,
            secondaryState: state.secondaryState,
            volState: VolState.vol,
            fractionDigits: 4,
            longPressY: ChartLongPressY.absolute,
            maLine: [
              MALine.ma5,
              // MALine.ma10,
              // MALine.ma20,
              // MALine.ma30,
            ],
            mainStyle: MainChartStyle.dark(),
            subStyle: SubChartStyle.dark(),
            onLoadMore: (isRight) {
              print('加載更多: $isRight');
            },
            onDataLessOnePage: () {
              print('資料未滿一頁');
            },
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baseAppBar('行情圖表'),
      body: BlocBuilder<KChartBloc, KChartState>(
        builder: (context, state) {
          var stateIsLine = state.isLine;
          print('是線條嗎: ${stateIsLine}');
          return ListView(
            children: <Widget>[
              Stack(children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
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
            bloc().add(KChartToggleLineEvent(isLine: true));
          },
        ),
        button(
          "k線",
          onPressed: () {
            bloc().add(KChartToggleLineEvent(isLine: false));
          },
        ),
        button(
          "MA",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainState.ma));
          },
        ),
        button(
          "BOLL",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainState.boll));
          },
        ),
        button(
          "隱藏",
          onPressed: () {
            bloc().add(KChartMainStateEvent(state: MainState.none));
          },
        ),
        button(
          "MACD",
          onPressed: () {
            bloc().add(KChartSecondaryStateEvent(state: SecondaryState.macd));
          },
        ),
        button(
          "KDJ",
          onPressed: () {
            bloc().add(KChartSecondaryStateEvent(state: SecondaryState.kdj));
          },
        ),
        button(
          "RSI",
          onPressed: () {
            bloc().add(KChartSecondaryStateEvent(state: SecondaryState.rsi));
          },
        ),
        button(
          "WR",
          onPressed: () {
            bloc().add(KChartSecondaryStateEvent(state: SecondaryState.wr));
          },
        ),
        button(
          "隱藏副視圖",
          onPressed: () {
            bloc().add(KChartSecondaryStateEvent(state: SecondaryState.none));
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
