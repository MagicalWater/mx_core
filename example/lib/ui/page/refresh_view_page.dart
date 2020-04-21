import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/refresh_view_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.refreshView)
class RefreshViewPage extends StatefulWidget {
  final RouteOption option;

  RefreshViewPage(this.option) : super();

  @override
  _RefreshViewPageState createState() => _RefreshViewPageState();
}

class _RefreshViewPageState extends State<RefreshViewPage> {
  RefreshViewBloc bloc;
  ScrollController cc;

  double hh = 100;

  @override
  void initState() {
    cc = ScrollController();

    bloc = BlocProvider.of<RefreshViewBloc>(context);
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
      print("打印: ${cc.position.maxScrollExtent}, ${cc.position.minScrollExtent}, ${cc.position.pixels}");
      loopDetect();
    });
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
//            print("觸發 load");
            Future.delayed(Duration(milliseconds: 100)).then((_) {
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
