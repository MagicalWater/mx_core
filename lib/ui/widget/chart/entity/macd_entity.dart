import 'kdj_entity.dart';
import 'rsi_entity.dart';
import 'rw_entity.dart';

mixin MACDEntity on KDJEntity, RSIEntity, WREntity {
  late double dea;
  late double dif;
  late double macd;
  late double ema12;
  late double ema26;
}
