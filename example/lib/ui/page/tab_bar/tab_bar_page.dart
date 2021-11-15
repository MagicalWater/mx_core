import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';

class TabBarPage extends StatefulWidget {
  final RouteOption option;

  TabBarPage(this.option) : super();

  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  var currentIndex = 15;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: currentIndex,
      length: 20,
      vsync: this,
    );
    super.initState();
  }

  List<String> _tabsTitle() {
    return List.generate(tabController.length, (index) {
      var showIndex = index + 1;
      var text = '$showIndex';
      var randomIndex = Random().nextInt(9) + 1;
      for (var i = 0; i < randomIndex; i++) {
        text += '$showIndex';
      }
      if (index == 1) {
        return '更多';
      }
      return text;
    });
  }

  List<Widget> _pages() {
    return List.generate(
        tabController.length,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar("TabBar"),
      backgroundColor: Colors.black87,
      body: Container(
        color: Colors.black,
        width: double.infinity,
        child: test(),
      ),
    );
  }

  Widget test() {
    return SwipeTabBar.text(
      controller: tabController,
      tabBuilder: TextTabBuilder(
        texts: _tabsTitle(),
        textAnimationDuration: Duration(milliseconds: 700),
        tabDecoration: (index, selected) {
          if (selected) {
            return BoxDecoration(
              color: Colors.transparent,
              // border: Border.all(color: Colors.yellow),
              borderRadius: BorderRadius.circular(6.scaleA),
            );
          } else {
            return BoxDecoration(
              color: Colors.transparent,
              // border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(6.scaleA),
            );
          }
        },
        tabTextStyle: (index, selected) {
          if (selected) {
            return TextStyle(
              color: Colors.yellow,
              fontSize: 14.scaleA,
            );
          } else {
            return TextStyle(
              color: Colors.grey,
              fontSize: 10.scaleA,
            );
          }
        },
        padding: EdgeInsets.symmetric(horizontal: 20.scaleA),
      ),
      indicator: TabIndicator(
          color: Colors.yellow, placeColor: Colors.grey, height: 3),
      tabWidth: TabWidth.shrinkWrap(),
      scrollable: true,
      tabHeight: 40.scaleA,
      gapBuilder: (context, index) => Container(width: 10.scaleW),
      header: Container(
        width: 20.scaleW,
      ),
      footer: Container(
        width: 20.scaleW,
      ),
    );
  }

  Widget textTab() {
    return SwipeTabBar.text(
      currentIndex: currentIndex,
      controller: tabController,
      tabBuilder: TextTabBuilder(
        texts: _tabsTitle(),
        tabDecoration: (index, selected) {
          if (selected) {
            return BoxDecoration(color: Colors.black.withAlpha(100));
          } else {
            return BoxDecoration(color: Colors.green.withAlpha(100));
          }
        },
        tabTextStyle: (index, selected) {
          if (selected) {
            return TextStyle(color: Colors.black, fontSize: 12);
          } else {
            return TextStyle(color: Colors.grey, fontSize: 12);
          }
        },
        // actions: ['1'],
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(left: 10, right: 10),
      ),
      gapBuilder: (context, index) {
        if (index == tabController.length - 1) {
          return Expanded(child: Container());
        }
        return Container(width: 10);
      },
      tabWidth: TabWidth.shrinkWrap(),
      tabHeight: 40,
      scrollable: false,
      header: Container(
        width: 50,
      ),
      footer: Container(
        width: 50,
      ),
      indicator: TabIndicator(
        color: Colors.red,
        height: 2,
      ),
      onTabTap: (preIndex, index) {
        if (preIndex == index) {
          return;
        }
        currentIndex = index;

        setState(() {});
      },
      onActionTap: (index) {
        BotToast.showText(text: '$index');
      },
    );
  }

  Widget widgetTab() {
    return SwipeTabBar(
      currentIndex: currentIndex,
      // controller: tabController,
      tabBuilder: WidgetTabBuilder(
        tabBuilder: (context, index, isSelect, foreground) {
          Widget cc;
          if (index == 2) {
            cc = Row(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _tabsTitle()[index],
                  style: TextStyle(
                    color: isSelect ? Colors.black : Colors.grey,
                  ),
                ),
                Icon(
                  Icons.arrow_back,
                  size: 20,
                ),
              ],
            );
          } else {
            cc = Text(
              _tabsTitle()[index],
              style: TextStyle(
                color: isSelect ? Colors.black : Colors.grey,
              ),
            );
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Container(
              key: ValueKey('$index$isSelect'),
              // padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: cc,
            ),
          );
        },
        actionBuilder: (context, index) {
          return Text(
            '1',
            style: TextStyle(
              color: Colors.black,
            ),
          );
        },
        tabCount: tabController.length,
        // actionCount: 1,
        tabDecoration: (index, selected) {
          if (selected) {
            return BoxDecoration(color: Colors.black.withAlpha(100));
          } else {
            return BoxDecoration(color: Colors.green.withAlpha(100));
          }
        },
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      gapBuilder: (context, index) {
        if (index == tabController.length - 1) {
          return Expanded(child: Container());
        }
        return Container(width: 10);
      },
      tabWidth: TabWidth.shrinkWrap(),
      tabHeight: 40,
      scrollable: false,
      indicator: TabIndicator(
        color: Colors.red,
        height: 2,
      ),
      onTabTap: (preIndex, index) {
        if (preIndex == index) {
          return;
        }
        currentIndex = index;

        setState(() {});
      },
      onActionTap: (index) {
        BotToast.showText(text: '$index');
      },
    );
  }
}
