import 'package:flutter/material.dart';
import 'package:mx_core/bloc/page_bloc.dart';

abstract class BlocBase {
  Future<void> dispose();
}

class BlocProvider<T extends PageBloc> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends PageBloc>(BuildContext context) {
//    BlocProvider<T> provider = context.findAncestorWidgetOfExactType();
    _BlocProviderState<T> providerState = context.findAncestorStateOfType();
    return providerState?._currentBloc;
  }
}

class _BlocProviderState<T extends PageBloc> extends State<BlocProvider<T>> {
  T _currentBloc;

  @override
  void initState() {
    _currentBloc = widget.bloc;
    _currentBloc.mounted = true;
    widget.bloc
        .registerSubPageStream(defaultRoute: widget.bloc.defaultSubPage());
    super.initState();
  }

  @override
  void didUpdateWidget(BlocProvider<PageBloc> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _currentBloc.mounted = false;
    _currentBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
