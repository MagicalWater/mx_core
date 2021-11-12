import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/animated_core/animated_core_cubit.dart';
import 'package:mx_core_example/ui/widget/base_app_bar.dart';
import 'package:mx_core_example/ui/widget/top_desc.dart';

class AnimatedCorePage extends StatefulWidget {
  final RouteOption option;

  AnimatedCorePage(this.option) : super();

  @override
  _AnimatedCorePageState createState() => _AnimatedCorePageState();
}

class _AnimatedCorePageState extends State<AnimatedCorePage>
    with SingleTickerProviderStateMixin {
  /// 動畫控制器
  /// 有著以下作用
  /// 1. 同步多個動畫核心
  /// 2. 動畫狀態控制
  AnimatedSyncTick _syncTick = AnimatedSyncTick.identity(
    type: AnimatedType.repeatReverse,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _syncTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimatedCoreCubit(),
      child: _view(),
    );
  }

  Widget _view() {
    return BlocBuilder<AnimatedCoreCubit, AnimatedCoreState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          appBar: baseAppBar(state.title),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  TopDesc(content: state.content),
                  AnimatedComb.quick(
                    sync: _syncTick,
                    child: Container(
                      color: Colors.red,
                    ),
                    size: Comb.size(
                      begin: Size.square(100),
                      end: Size.square(200),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
