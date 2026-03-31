import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class DataSource<T> {
  final String name;

  final T? Function(BuildContext) watchCurrentValue;
  final T? Function(int) getValueAtTimestamp;
  final Iterable<MapEntry<int, T?>>? Function() getAllValueChanges;

  final String Function(T) asString;

  const DataSource({
    required this.name,
    required this.watchCurrentValue,
    required this.getAllValueChanges,
    required this.getValueAtTimestamp,
    required this.asString,
  });

  Widget asDataEntry(BuildContext context, T? displayValue);
  Widget asGraphEntry(BuildContext context, T? displayValue);

  @nonVirtual
  TextStyle validLabelStyle(BuildContext context) {
    return TextStyle(color: Theme.of(context).colorScheme.onSurface);
  }

  @nonVirtual
  TextStyle invalidLabelStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );
  }

  @nonVirtual
  Draggable<E> generateDraggable<E extends DataSource<T>>({
    required BuildContext context,
    required E data,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Draggable<E>(
      data: data,
      feedback: OverflowText(data.name, style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

abstract class ContinousDataSource<T extends num> extends DataSource<T> {
  const ContinousDataSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });
}

class ContinousIntSource extends ContinousDataSource<int> {
  ContinousIntSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
    required super.asString,
  });

  @override
  Widget asDataEntry(BuildContext context, int? displayValue) {
    final val = watchCurrentValue(context);

    return generateDraggable(
      context: context,
      data: this,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            OverflowText(
              name,
              style: val == null
                  ? invalidLabelStyle(context)
                  : validLabelStyle(context),
            ),
            if (val != null) Expanded(child: OverflowText(asString(val))),
          ],
        ),
      ),
    );
  }
}

class DiscreteDataSource<T> extends DataSource<T> {
  DiscreteDataSource({
    required super.name,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.getAllValueChanges,
  }) : super(asString: (val) => val);
}

class DiscreteBooleanSource extends DiscreteDataSource {
  DiscreteBooleanSource({
    required super.name,
    required bool? Function(BuildContext) watchCurrentValue,
    required bool? Function(int) getValueAtTimestamp,
    required Iterable<MapEntry<int, bool?>>? Function() getAllValueChanges,
  }) : super(
         watchCurrentValue: watchCurrentValue,
         getValueAtTimestamp: getValueAtTimestamp,
         getAllValueChanges: getAllValueChanges,
       );
}
