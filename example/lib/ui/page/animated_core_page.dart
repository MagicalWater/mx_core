import 'package:mx_core_example/router/router.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/animated_core_bloc.dart';
import 'package:mx_core_example/ui/page/introduction_page.dart';

class AnimatedCorePage extends StatefulWidget {
  final RouteOption option;

  AnimatedCorePage(this.option) : super();

  @override
  _AnimatedCorePageState createState() => _AnimatedCorePageState();
}

class _AnimatedCorePageState extends State<AnimatedCorePage>
    with SingleTickerProviderStateMixin {
  AnimatedCoreBloc bloc;

  /// 動畫控制器
  /// 有著以下作用
  /// 1. 同步多個動畫核心
  /// 2. 動畫狀態控制
  AnimatedSyncTick _syncTick = AnimatedSyncTick.identity(
    type: AnimatedType.repeatReverse,
  );

  var title = "動畫核心";
  var content = """
  動畫核心
  a. 所有的動畫皆基於此之上製作, 包含以下
    1. LoadingAnimation - 讀取動畫
    2. ParticleAnimation - 粒子動畫
    
  b. 動畫有以下幾種行為
    1. AnimatedType.tap - 點擊
    2. AnimatedType.toggle - 開關
    3. AnimatedType.once - 入場時執行一次
    4. AnimatedType.repeat - 不斷重複執行
  """;

  @override
  void initState() {
    bloc = BlocProvider.of<AnimatedCoreBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _syncTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadProvider(
      loadStream: bloc.loadStream,
      child: PageScaffold(
        color: Colors.black,
        haveAppBar: true,
        resizeToAvoidBottomInset: true,
        title: title,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                buildIntroduction(content),
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
      ),
    );
  }
}
