import 'package:mx_core_example/router/router.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';

class RefreshViewPage extends StatefulWidget {
  final RouteOption option;

  RefreshViewPage(this.option) : super();

  @override
  _RefreshViewPageState createState() => _RefreshViewPageState();
}

class _RefreshViewPageState extends State<RefreshViewPage> {
  late RefreshViewBloc bloc;
  late ScrollController cc;

  double hh = 100;

  bool isDisposed = false;

  @override
  void initState() {
    cc = ScrollController();

    bloc = BlocProvider.of<RefreshViewBloc>(context)!;
//    bloc.loadingMore(true);
    bloc.refreshing();
    Future.delayed(Duration(seconds: 1)).then((_) {
      bloc.setRefresh(success: true);
//      bloc.setLoadMore(success: true);
    });
    Future.delayed(Duration(seconds: 2)).then((_) {
      loopDetect();
    });
    super.initState();
  }

  void loopDetect() async {
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (!isDisposed) {
        print('gogo');
        print("打印: ${cc.position.maxScrollExtent}, ${cc.position
            .minScrollExtent}, ${cc.position.pixels}");
        loopDetect();
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
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: "RefreshView",
        child: RefreshView(
          stateStream: bloc.refreshStream,
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
      ),
    );
  }
}
