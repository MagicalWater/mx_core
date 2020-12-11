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

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  TabBarBloc bloc;

  var currentIndex = 0;
  TabController tabController;

  List<String> tabs;
  List<Widget> pages;

  @override
  void initState() {
    bloc = BlocProvider.of<TabBarBloc>(context);
    tabController = TabController(
      initialIndex: currentIndex,
      length: 3,
      vsync: this,
    );

    tabs = List.generate(tabController.length, (index) => '${index + 1}');

    pages = List.generate(
        tabs.length,
        (index) => Container(
              alignment: Alignment.center,
              child: Text(
                '頁面 $index',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 30.scaleA,
                ),
              ),
            ));

    // Future.delayed(Duration(seconds: 2)).then((value) {
    //   var startIndex = tabs.length + 1;
    //   tabs += ['$startIndex', '${startIndex + 1}'];
    //   pages = List.generate(
    //       tabs.length,
    //       (index) => Container(
    //             alignment: Alignment.center,
    //             child: Text(
    //               '頁面 $index',
    //               style: TextStyle(
    //                 color: Colors.black45,
    //                 fontSize: 30.scaleA,
    //               ),
    //             ),
    //           ));
    //   tabController = TabController(
    //     initialIndex: currentIndex,
    //     length: 4,
    //     vsync: this,
    //   );
    //   setState(() {});
    // });
    // TabBar();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: SwipeTabBar.text(
                  currentIndex: currentIndex,
                  // controller: tabController,
                  builder: TextTabBuilder(
                    texts: tabs,
                    // actions: [
                    //   '第一名',
                    //   '第二名',
                    // ],
                    tabDecoration: TabStyle<BoxDecoration>(
                      select: BoxDecoration(color: Colors.transparent),
                      unSelect: BoxDecoration(color: Colors.transparent),
                    ),
                    tabTextStyle: TabStyle<TextStyle>(
                      select: TextStyle(color: Colors.black, fontSize: 12),
                      unSelect: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    actions: ['1'],
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                  gapBuilder: (context, index) {
                    if (index == tabs.length - 1) {
                      return Expanded(child: Container());
                    }
                    return Container(width: 10);
                  },
//            header: Container(width: 30),
//            footer: Container(width: 100),
                  tabWidth: TabWidth.shrinkWrap(),
                  tabHeight: 40,
                  scrollable: false,
                  indicator: TabIndicator(
                    color: Colors.red,
                    height: 2,
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
              Expanded(
                child: TabBarView(
                  children: pages,
                  controller: tabController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
