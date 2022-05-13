import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/introduction/bloc/introduction_cubit.dart';

class IntroductionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntroductionCubit, IntroductionState>(
      builder: (context, state) {
        return PageScaffold(
          title: "展示列表",
          color: Colors.black,
          child: Container(
            child: SingleChildScrollView(
              child: Wrap(
                children: state.pageRoutes
                    .map((e) => _pageButton(context, e))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pageButton(
    BuildContext context,
    PageInfo pageInfo,
  ) {
    return AnimatedComb(
      child: Container(
        width: (Screen.width - 48) / 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff2b9eda),
              Color(0xff68c3fb),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
        padding: EdgeInsets.all(12),
        child: Text(
          pageInfo.desc,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      type: AnimatedType.tap,
      duration: 1000,
      curve: Curves.elasticOut,
      animatedList: [
        Comb.scale(end: Size.square(0.8)),
      ],
      onTap: () {
        var i = 0;
        assert(i == 0);
        _handleIntroductionTap(context, pageInfo.page);
      },
    );
  }

  void _handleIntroductionTap(BuildContext context, String page) {
    print('點跳跳: $page');
    // appRouter.pushPage(page);
    // return;
    appRouter.pushPage(
      page,
      builder: (
        Widget child,
        String name,
      ) {
        return CubeRoutePart1(child: child);
      },
    );
  }
}
