import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/util/units.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DataSource<T> {
  final String name;

  final T? Function(BuildContext) watchCurrentValue;
  final T? Function(int) getValueAtTimestamp;
  final Iterable<MapEntry<int, T?>>? Function() getAllValueChanges;

  //has to accept dynamic due to limitations of runtime type casting
  final String Function(dynamic) asString;

  const DataSource({
    required this.name,
    required this.watchCurrentValue,
    required this.getAllValueChanges,
    required this.getValueAtTimestamp,
    required this.asString,
  });

  @nonVirtual
  Widget asDataEntry<S extends DataSource<T>>() {
    return Builder(
      builder: (context) {
        final value = watchCurrentValue(context);

        final theme = Theme.of(context);

        return Draggable<S>(
          data: this as S,
          feedback: OverflowText(name, style: theme.textTheme.bodyMedium),
          dragAnchorStrategy: (draggable, context, position) =>
              pointerDragAnchorStrategy(draggable, context, position),
          hitTestBehavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 4),
            child: Row(
              children: [
                _generateLabel(context, value, true),
                if (value != null)
                  Expanded(
                    child: _generateFormattedDataTabData(context, value),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @nonVirtual
  List<Widget> asGraphEntryContents(
    BuildContext context,
    T? displayValue,
    bool visible,
  ) {
    return [
      Expanded(child: _generateLabel(context, displayValue, visible)),
      if (displayValue != null && visible)
        _generateFormattedGraphData(context, displayValue),
    ];
  }

  Widget _generateFormattedDataTabData(BuildContext context, T currentValue);
  Widget _generateFormattedGraphData(BuildContext context, T displayValue);

  @nonVirtual
  Widget _generateLabel(BuildContext context, T? displayValue, bool visible) {
    final theme = Theme.of(context);

    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );
    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invisibleStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(64),
    );

    return OverflowText(
      name,
      style: !visible
          ? invisibleStyle
          : (displayValue == null ? invalidStyle : validStyle),
    );
  }
}

abstract class ContinuousDataSource<T extends Unit<num>> extends DataSource<T> {
  const ContinuousDataSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });
}

class ContinuousNumSource<T extends Unit<num>> extends ContinuousDataSource<T> {
  const ContinuousNumSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });

  @override
  Widget _generateFormattedDataTabData(BuildContext context, T currentValue) {
    return OverflowText(asString(currentValue), textAlign: TextAlign.end);
  }

  @override
  Widget _generateFormattedGraphData(BuildContext context, T displayValue) {
    return OverflowText(
      asString(displayValue),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

class ContinuousValidatableNumSource<T extends Unit<num>>
    extends ContinuousDataSource<T> {
  final bool Function(T) isValid;

  const ContinuousValidatableNumSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
    required this.isValid,
  });

  @override
  Widget _generateFormattedDataTabData(BuildContext context, T currentValue) {
    return OverflowText(
      asString(currentValue),
      style: isValid(currentValue)
          ? null
          : TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
            ),
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget _generateFormattedGraphData(BuildContext context, T displayValue) {
    return OverflowText(
      asString(displayValue),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

class ContinuousPercentageSource<T extends Unit<num>>
    extends ContinuousDataSource<T> {
  final double? Function(BuildContext) watchCurrentPercentage;

  const ContinuousPercentageSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required this.watchCurrentPercentage,
    required super.asString,
  });

  @override
  Widget _generateFormattedDataTabData(BuildContext context, T currentValue) {
    final neutralBackCol = Colors.white.withAlpha(63);
    final positiveBackCol = Colors.green.withAlpha(127);
    final negativeBackCol = Colors.red.withAlpha(127);

    final neutralKnobColor = Colors.transparent;
    final positiveKnobColor = Colors.green;
    final negativeKnobColor = Colors.red;

    final textHeight = TextStyle().fontSize ?? 14;

    final sliderWidth = 50.0;
    final actuationDist = sliderWidth / 2 - textHeight / 2;
    final barCenter = sliderWidth / 2 - textHeight / 4;

    final stringRep = asString(currentValue);
    final percent = watchCurrentPercentage(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (percent != null)
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: percent == 0
                      ? neutralBackCol
                      : (percent > 0 ? positiveBackCol : negativeBackCol),
                  borderRadius: BorderRadius.circular(textHeight / 4),
                ),
                child: SizedBox(width: sliderWidth, height: textHeight / 2),
              ),
              Positioned(
                left: barCenter + percent * actuationDist,
                child: Container(
                  decoration: BoxDecoration(
                    color: percent == 0
                        ? neutralKnobColor
                        : (percent > 0 ? positiveKnobColor : negativeKnobColor),
                    borderRadius: BorderRadius.circular(textHeight / 4),
                  ),
                  child: SizedBox.square(dimension: textHeight / 2),
                ),
              ),
            ],
          ),
        const SizedBox(width: 8),
        if (!stringRep.contains("-"))
          OverflowText("-", style: TextStyle(color: Colors.transparent)),
        OverflowText(stringRep),
      ],
    );
  }

  @override
  Widget _generateFormattedGraphData(BuildContext context, T displayValue) {
    return OverflowText(
      asString(displayValue),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

abstract class DiscreteDataSource<T> extends DataSource<T> {
  const DiscreteDataSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });
}

class DiscreteBooleanSource extends DiscreteDataSource<bool> {
  const DiscreteBooleanSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });

  static const _falseDataStyle = TextStyle(color: Colors.red);
  static const _trueDataStyle = TextStyle(color: Colors.green);
  static final _falseGraphStyle = TextStyle(color: Colors.red.withAlpha(127));
  static final _trueGraphStyle = TextStyle(color: Colors.green.withAlpha(127));

  @override
  Widget _generateFormattedDataTabData(
    BuildContext context,
    bool currentValue,
  ) {
    return OverflowText(
      asString(currentValue),
      style: currentValue ? _trueDataStyle : _falseDataStyle,
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget _generateFormattedGraphData(BuildContext context, bool displayValue) {
    return OverflowText(
      asString(displayValue),
      style: displayValue ? _trueGraphStyle : _falseGraphStyle,
      textAlign: TextAlign.end,
    );
  }
}

class DiscreteControlModeSource extends DiscreteDataSource<DeviceControlMode> {
  const DiscreteControlModeSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });

  @override
  Widget _generateFormattedDataTabData(
    BuildContext context,
    DeviceControlMode currentValue,
  ) {
    return OverflowText(
      asString(currentValue),
      style: currentValue == DeviceControlMode.disabled
          ? TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
            )
          : null,
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget _generateFormattedGraphData(
    BuildContext context,
    DeviceControlMode displayValue,
  ) {
    return OverflowText(
      asString(displayValue),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

class DiscreteIntSource<T extends Unit<int>> extends DiscreteDataSource<T> {
  const DiscreteIntSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });

  @override
  Widget _generateFormattedDataTabData(BuildContext context, T currentValue) {
    return OverflowText(asString(currentValue), textAlign: TextAlign.end);
  }

  @override
  Widget _generateFormattedGraphData(BuildContext context, T displayValue) {
    return OverflowText(
      asString(displayValue),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

class DiscreteStringSource extends DiscreteDataSource<String> {
  DiscreteStringSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
  }) : super(asString: (val) => val.toString());

  @override
  Widget _generateFormattedDataTabData(
    BuildContext context,
    String currentValue,
  ) {
    return OverflowText(currentValue, textAlign: TextAlign.end);
  }

  @override
  Widget _generateFormattedGraphData(
    BuildContext context,
    String displayValue,
  ) {
    return OverflowText(
      displayValue,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}

class DiscreteValidatableStringSource extends DiscreteDataSource<String> {
  final bool Function(String) isValid;

  DiscreteValidatableStringSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required this.isValid,
  }) : super(asString: (val) => val.toString());

  @override
  Widget _generateFormattedDataTabData(
    BuildContext context,
    String currentValue,
  ) {
    return OverflowText(
      currentValue,
      style: isValid(currentValue)
          ? null
          : TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
            ),
      textAlign: TextAlign.end,
    );
  }

  @override
  Widget _generateFormattedGraphData(
    BuildContext context,
    String displayValue,
  ) {
    return OverflowText(
      displayValue,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      ),
      textAlign: TextAlign.end,
    );
  }
}
