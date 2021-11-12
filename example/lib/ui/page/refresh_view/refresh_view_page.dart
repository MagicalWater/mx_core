import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core_example/router/router.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class RefreshViewPage extends StatefulWidget {
  final RouteOption option;

  RefreshViewPage(this.option) : super();

  @override
  _RefreshViewPageState createState() => _RefreshViewPageState();
}

class _RefreshViewPageState extends State<RefreshViewPage> {
  double hh = 100;

  bool isDisposed = false;

  @override
  void initState() {
    bloc.refreshing();
    Future.delayed(Duration(seconds: 1)).then((_) {
      bloc.setRefresh(success: true);
    });
    Future.delayed(Duration(seconds: 2)).then((_) {
      _loopDetect();
    });
    super.initState();
  }

  void _loopDetect() async {
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (!isDisposed) {
        _loopDetect();
      }
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (BuildContext context) => ,

    );
  }

  Widget _view() {
    return Scaffold(
      appBar: baseAppBar('RefreshView'),
      body: RefreshView(
        stateStream: bloc.stream,
        child: Container(
          width: 100,
          height: hh,
          color: Colors.red,
        ),
        scrollController: cc,
        onRefresh: () {
//            print("觸發 refresh");
          Future.delayed(Duration(milliseconds: 100)).then((_) {
            setState(() {
              hh = 100;
            });
            bloc.setRefresh(success: true);
          });
        },
        placeBuilder: (
            BuildContext context,
            RefreshState state,
            PlaceStyle place,
            ) {
          if (state.type == RefreshType.loadMore && state.empty) {
            return Text('無資料');
          }
          return null;
        },
        onLoadMore: () {
          Future.delayed(Duration(milliseconds: 100)).then((_) {
            if (isDisposed) {
              return;
            }
            setState(() {
              hh += 10;
            });
            bloc.setLoadMore(
              success: true,
              empty: true,
            );
          });
        },
      ),
    );
  }
}
