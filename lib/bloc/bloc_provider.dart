import 'package:flutter/material.dart';
import 'package:mx_core/bloc/page_bloc.dart';

abstract class BlocBase {
  Future<void> dispose();
}

typedef T BlocBuilder<T extends PageBloc>();

class BlocProvider<T extends PageBloc> extends StatefulWidget {
  BlocProvider({
    Key key,
    @required this.child,
    @required this.blocBuilder,
  }) : super(key: key);

  final BlocBuilder<T> blocBuilder;
  final Widget child;

  @override
  BlocProviderState<T> createState() => BlocProviderState<T>();

  static T of<T extends PageBloc>(BuildContext context) {
    BlocProviderState<T> providerState = context.findAncestorStateOfType();
    return providerState?._currentBloc;
  }
}

class BlocProviderState<T extends PageBloc> extends State<BlocProvider<T>> {
  T _currentBloc;

  @override
  void initState() {
    _currentBloc = widget.blocBuilder();
    _currentBloc.providerState = this;
    _currentBloc.registerSubPageStream(
        defaultRoute: _currentBloc.defaultSubPage());
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
