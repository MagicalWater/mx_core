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
  BlocProviderState<T> createState() => BlocProviderState<T>();

  static T of<T extends PageBloc>(BuildContext context) {
//    BlocProvider<T> provider = context.findAncestorWidgetOfExactType();
    BlocProviderState<T> providerState = context.findAncestorStateOfType();
    return providerState?._currentBloc;
  }
}

class BlocProviderState<T extends PageBloc> extends State<BlocProvider<T>> {
  T _currentBloc;

  @override
  void initState() {
    _currentBloc = widget.bloc;
    _currentBloc.providerState = this;
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
    _currentBloc.providerState = null;
    _currentBloc?.dispose();
    _currentBloc = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
