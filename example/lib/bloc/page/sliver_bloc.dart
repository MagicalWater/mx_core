import 'package:mx_core/mx_core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mx_core_example/router/route.dart';

class SliverBloc extends PageBloc {
  SliverBloc(RouteOption option) : super(Pages.sliver, option) {
    _itemSubject.add(20);
    setSliverState(SliverState.standby);
  }

  BehaviorSubject<int> _itemSubject = BehaviorSubject();

  Stream<int> get itemStream => _itemSubject.stream;

  /// 變更 Sliver 的狀態
  void changeState() {
    var index = SliverState.values.indexOf(currentSliverState);
    var nextIndex = index >= SliverState.values.length - 1 ? 0 : ++index;
    var nextState = SliverState.values[nextIndex];
    syncSliverStateShow(nextState);
  }

  /// 同步 sliver 狀態顯示
  void syncSliverStateShow(SliverState state) {
    switch (state) {
      case SliverState.loadingBody:
        _itemSubject?.add(0);
        break;
      case SliverState.errorBody:
        _itemSubject?.add(0);
        break;
      case SliverState.emptyBody:
        _itemSubject?.add(0);
        break;
      case SliverState.loadingMore:
        break;
      case SliverState.standby:
        _itemSubject?.add(20);
        break;
      case SliverState.noMore:
        _itemSubject?.add(20);
        break;
    }
    setSliverState(state);
  }

  @override
  void dispose() {
    _itemSubject.close();
    _itemSubject = null;
    super.dispose();
  }
}
