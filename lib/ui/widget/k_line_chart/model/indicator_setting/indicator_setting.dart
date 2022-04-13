import 'setting/setting.dart';

export 'setting/setting.dart';

/// 技術線設定
class IndicatorSetting {
  final MaSetting maSetting;
  final BollSetting bollSetting;
  final KdjSetting kdjSetting;
  final MacdSetting macdSetting;
  final RsiSetting rsiSetting;
  final WrSetting wrSetting;

  const IndicatorSetting({
    this.maSetting = const MaSetting(),
    this.bollSetting = const BollSetting(),
    this.kdjSetting = const KdjSetting(),
    this.macdSetting = const MacdSetting(),
    this.rsiSetting = const RsiSetting(),
    this.wrSetting = const WrSetting(),
  });
}
