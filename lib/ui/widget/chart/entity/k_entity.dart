import 'candle_entity.dart';
import 'kdj_entity.dart';
import 'macd_entity.dart';
import 'rsi_entity.dart';
import 'wr_entity.dart';
import 'volume_entity.dart';

abstract class KEntity
    implements
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        MACDEntity {}
