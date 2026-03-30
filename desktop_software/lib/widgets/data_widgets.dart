import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';

abstract class DataWidget extends StatelessWidget {
  const DataWidget({super.key});
}

class BooleanDataWidget<T> extends DataWidget {
  final bool val;

  const BooleanDataWidget(this.val, {super.key});

  static const _falseStyle = TextStyle(color: Colors.red);
  static const _trueStyle = TextStyle(color: Colors.green);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: OverflowText(
        val.toString(),
        style: val ? _trueStyle : _falseStyle,
      ),
    );
  }
}

class TextDataWidget<T> extends DataWidget {
  final String val;

  const TextDataWidget(this.val, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerRight, child: OverflowText(val));
  }
}

class ControlModeDataWidget<T> extends DataWidget {
  final DeviceControlMode val;

  const ControlModeDataWidget(this.val, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: OverflowText(
        val.name,
        style: val == DeviceControlMode.disabled ? disabledStyle : null,
      ),
    );
  }
}

class PercentOutDataWidget<T> extends DataWidget {
  final double val;
  final double percent;
  final int precision;
  final String? suffix;

  const PercentOutDataWidget(
    this.val,
    this.precision,
    double _perc, {
    this.suffix,
    super.key,
  }) : percent = _perc > 1 ? 1 : (_perc < -1 ? -1 : _perc);

  static const _positiveCol = Colors.green;
  static const _negativeCol = Colors.red;
  static const double _sliderWidth = 50;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final neutralBackCol = theme.colorScheme.surfaceContainer;
    final positiveBackCol = Color.alphaBlend(
      _positiveCol.withAlpha(127),
      theme.colorScheme.surface,
    );
    final negativeBackCol = Color.alphaBlend(
      _negativeCol.withAlpha(127),
      theme.colorScheme.surface,
    );

    final textHeight = TextStyle().fontSize ?? 14;
    final actuationDist = _sliderWidth / 2 - textHeight / 4;
    final barCenter = _sliderWidth / 2 - textHeight / 4;

    var text = suffix == null
        ? val.toStringAsFixed(precision)
        : "${val.toStringAsFixed(precision)}$suffix";
    if (!text.contains("-")) {
      //TODO: monospace font?
      text = " $text"; //not perfect but its pretty close
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: percent == 0
                    ? neutralBackCol
                    : (percent > 0 ? positiveBackCol : negativeBackCol),
                borderRadius: BorderRadius.circular(textHeight / 4),
              ),
              child: SizedBox(width: _sliderWidth, height: textHeight / 2),
            ),
            Positioned(
              left: barCenter + percent * actuationDist,
              child: Container(
                decoration: BoxDecoration(
                  color: percent == 0
                      ? Colors.transparent
                      : (percent > 0 ? _positiveCol : _negativeCol),
                  borderRadius: BorderRadius.circular(textHeight / 4),
                ),
                child: SizedBox.square(dimension: textHeight / 2),
              ),
            ),
          ],
        ),
        OverflowText(text),
      ],
    );
  }
}
