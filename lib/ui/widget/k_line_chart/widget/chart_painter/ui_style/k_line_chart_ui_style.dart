import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/ui_style/chart_color_setting.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/ui_style/chart_height_ratio_setting/chart_height_ratio_setting.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/chart_painter/ui_style/chart_size_setting.dart';

export 'chart_color_setting.dart';
export 'chart_height_ratio_setting/chart_height_ratio_setting.dart';
export 'chart_size_setting.dart';

class KLineChartUiStyle {
  final ChartSizeSetting sizeSetting;
  final ChartHeightRatioSetting heightRatioSetting;
  final ChartColorSetting colorSetting;

  KLineChartUiStyle({
    required this.sizeSetting,
    required this.heightRatioSetting,
    required this.colorSetting,
  });
}
