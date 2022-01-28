import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/k_line_chart/k_line_chart.dart';
import 'package:mx_core/ui/widget/k_line_chart/widget/k_line_data_tooltip/ui_style/k_line_data_tooltip_ui_style.dart';
import 'package:mx_core/util/date_util.dart';

import 'model/tooltip_prefix.dart';

/// 長按對應的k線資料彈窗
class KLineDataInfoTooltip extends StatelessWidget {
  final LongPressData longPressData;
  final KLineDataTooltipUiStyle uiStyle;
  final TooltipPrefix tooltipPrefix;
  final String? dateTimeFormat;

  KLineData get data => longPressData.data;

  KLineDataTooltipColorSetting get colors => uiStyle.colorSetting;

  KLineDataTooltipSizeSetting get sizes => uiStyle.sizeSetting;

  const KLineDataInfoTooltip({
    Key? key,
    required this.longPressData,
    this.uiStyle = const KLineDataTooltipUiStyle(),
    this.tooltipPrefix = const TooltipPrefix(),
    this.dateTimeFormat = 'yyyy-MM-dd HH:mm',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: longPressData.isLongPressAtLeft ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: sizes.horizontalMargin,
          right: sizes.horizontalMargin,
          top: sizes.topMargin,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizes.horizontalPadding,
          vertical: sizes.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border, width: sizes.borderWidth),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _date(),
              _open(),
              _close(),
              _high(),
              _low(),
              _changedValue(),
              _changedRate(),
              _volume(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _date() {
    return _item(
      prefix: tooltipPrefix.time,
      value: data.dateTime.getDateStr(
        format: dateTimeFormat ?? 'yyyy-MM-dd HH:mm:ss',
      ),
    );
  }

  Widget _open() {
    return _item(
      prefix: tooltipPrefix.open,
      value: data.open.toStringAsFixed(2),
    );
  }

  Widget _close() {
    return _item(
      prefix: tooltipPrefix.close,
      value: data.close.toStringAsFixed(2),
    );
  }

  Widget _high() {
    return _item(
      prefix: tooltipPrefix.high,
      value: data.high.toStringAsFixed(2),
    );
  }

  Widget _low() {
    return _item(
      prefix: tooltipPrefix.low,
      value: data.low.toStringAsFixed(2),
    );
  }

  Widget _changedValue() {
    final changedValue = data.close - data.open;
    final isUp = changedValue >= 0;
    var valueText = changedValue.toStringAsFixed(2);
    if (isUp) {
      valueText = '+$valueText';
    }

    return _item(
        prefix: tooltipPrefix.changeValue,
        value: valueText,
        valueColor: isUp ? colors.changedValueUp : colors.changedValueDown);
  }

  Widget _changedRate() {
    final changedValue = data.close - data.open;
    final changedRate = changedValue / data.open * 100;

    final isUp = changedValue >= 0;
    var valueText = changedRate.toStringAsFixed(2);
    if (isUp) {
      valueText = '+$valueText';
    }

    return _item(
      prefix: tooltipPrefix.changeRate,
      value: valueText,
      valueColor: isUp ? colors.changedRateUp : colors.changedRateDown,
    );
  }

  Widget _volume() {
    return _item(
      prefix: tooltipPrefix.volume,
      value: data.volume.toStringAsFixed(2),
    );
  }

  Widget _item({
    required String prefix,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              prefix,
              style: TextStyle(
                color: colors.prefixText,
                fontSize: sizes.prefixText,
              ),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.valueText,
            fontSize: sizes.valueText,
          ),
        ),
      ],
    );
  }
}
