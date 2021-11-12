import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/ui/page/introduction/bloc/introduction_cubit.dart';
import 'introduction_list.dart';

/// 功能介紹頁面
class IntroductionPage extends StatefulWidget {
  final RouteOption option;

  IntroductionPage(this.option) : super();

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IntroductionCubit(),
      child: IntroductionList(),
    );
  }
}
