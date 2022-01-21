import 'kdj_entity.dart';
import 'rsi_entity.dart';
import 'wr_entity.dart';

abstract class MACDEntity implements KDJEntity, RSIEntity, WREntity {
  abstract double dea;
  abstract double dif;
  abstract double macd;
  abstract double ema12;
  abstract double ema26;
}
