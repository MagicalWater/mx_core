import 'package:mx_core/mx_core.dart';

class AppBloc with RouteMixin {
  static final _singleton = AppBloc._internal();

  static AppBloc getInstance() => _singleton;

  factory AppBloc() => _singleton;

  AppBloc._internal();

  @override
  void dispose() {
    super.dispose();
  }
}

