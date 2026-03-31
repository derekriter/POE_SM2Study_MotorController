import 'package:flutter/material.dart';

abstract class DataSource<T> {
  final DataType type;
  final T? Function(BuildContext) watchCurrentValue;
  final T? Function(int) getValueAtTimestamp;
  final Iterable<MapEntry<int, T?>>? Function() getAllValueChanges;
  final String name;
  final String Function(T) stringRepresentation;

  const DataSource({
    required this.name,
    required this.type,
    required this.getValueAtTimestamp,
    required this.getAllValueChanges,
    required this.watchCurrentValue,
    required this.stringRepresentation,
  });
}

enum DataType { continous, discrete }

class ContinousDataSource extends DataSource<num> {
  const ContinousDataSource({
    required super.name,
    required super.getAllValueChanges,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
    required super.stringRepresentation,
  }) : super(type: DataType.continous);
}

class DiscreteDataSource extends DataSource<String> {
  DiscreteDataSource({
    required super.name,
    required super.getAllValueChanges,
    required super.watchCurrentValue,
    required super.getValueAtTimestamp,
  }) : super(type: DataType.discrete, stringRepresentation: (val) => val);
}
