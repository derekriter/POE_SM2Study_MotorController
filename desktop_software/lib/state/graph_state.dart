import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/util/units.dart';
import 'package:flutter/material.dart';

class GraphState with ChangeNotifier {
  final List<ContinuousDataSource<Unit<num>>> _leftAxisSources,
      _rightAxisSources;
  final List<DiscreteDataSource<dynamic>> _discreteSources;

  GraphState()
    : _leftAxisSources = List.empty(growable: true),
      _rightAxisSources = List.empty(growable: true),
      _discreteSources = List.empty(growable: true);

  List<ContinuousDataSource<Unit<num>>> get leftAxisSources => _leftAxisSources;
  List<ContinuousDataSource<Unit<num>>> get rightAxisSources =>
      _rightAxisSources;
  List<DiscreteDataSource<dynamic>> get discreteSources => _discreteSources;

  void addLeftAxisSource(ContinuousDataSource<Unit<num>> source) {
    leftAxisSources.add(source);
    notifyListeners();
  }

  void addRightAxisSource(ContinuousDataSource<Unit<num>> source) {
    rightAxisSources.add(source);
    notifyListeners();
  }

  void addDiscreteSource(DiscreteDataSource<dynamic> source) {
    discreteSources.add(source);
    notifyListeners();
  }

  void removeLeftAxisSource(ContinuousDataSource<Unit<num>> source) {
    leftAxisSources.remove(source);
    notifyListeners();
  }

  void removeRightAxisSource(ContinuousDataSource<Unit<num>> source) {
    rightAxisSources.remove(source);
    notifyListeners();
  }

  void removeDiscreteSource(DiscreteDataSource<dynamic> source) {
    discreteSources.remove(source);
    notifyListeners();
  }
}
