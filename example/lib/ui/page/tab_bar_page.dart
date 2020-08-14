import 'package:annotation_route/route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/tab_bar_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.tabBar)
class TabBarPage extends StatefulWidget {
  final RouteOption option;

  TabBarPage(this.option) : super();

  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  TabBarBloc bloc;

  var currentIndex = 0;

  @override
  void initState() {
    bloc = BlocProvider.of<TabBarBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        haveAppBar: true,
        title: "TabBar",
        child: Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: SwipeTabBar.text(
            currentIndex: currentIndex,
            builder: TextTabBuilder(
              texts: [
                '第一名',
                '第二名',
              ],
              actions: [
                '第一名',
                '第二名',
              ],
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
//            gapBuilder: (context, index) {
//              return Container(width: 10);
//            },
//            header: Container(width: 30),
//            footer: Container(width: 100),
            height: 100,
            scrollable: true,
            indicator: TabIndicator(
              color: Colors.red,
              height: 10,
            ),
            onTabTap: (index) {
              currentIndex = index;
              setState(() {});
            },
            onActionTap: (index) {
              BotToast.showText(text: '$index');
            },
          ),
        ),
      ),
    );
  }
}
