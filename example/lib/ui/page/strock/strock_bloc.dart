import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'strock_event.dart';
part 'strock_state.dart';

class StrockBloc extends Bloc<StrockEvent, StrockState> {
  StrockBloc() : super(StrockInitial()) {
    on<StrockEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
