import 'package:flutter/material.dart';
import 'package:mx_core/bloc/page_bloc.dart';

abstract class BlocBase {
  void initState();

  Future<void> dispose();
}

typedef T BlocBuilder<T extends PageBloc>();

class BlocProvider<T extends PageBloc> extends StatefulWidget {
  BlocProvider({
    Key? key,
    required this.childBuilder,
    required this.blocBuilder,
  }) : super(key: key);

  final BlocBuilder<T> blocBuilder;
  final WidgetBuilder childBuilder;

  @override
  BlocProviderState<T> createState() => BlocProviderState<T>();

  static T? of<T extends PageBloc>(BuildContext context) {
    var providerState = context.findAncestorStateOfType() as BlocProviderState<T>;
    return providerState._currentBloc;
  }
}

class BlocProviderState<T extends PageBloc> extends State<BlocProvider<T>> {
  late T _currentBloc;

  @override
  void initState() {
    _currentBloc = widget.blocBuilder();
    _currentBloc.providerState = this;
    _currentBloc.registerSubPageStream(
      defaultRoute: _currentBloc.defaultSubPage(),
    );
    _currentBloc.initState();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void notifyUpdate() {
    print('頁面通知刷新');
    setState(() {});
  }

  @override
  void dispose() {
    _currentBloc.providerState = null;
    _currentBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context);
  }
}
