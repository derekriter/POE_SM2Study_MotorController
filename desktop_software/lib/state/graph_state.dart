import 'package:desktop_software/util/data_source.dart';
import 'package:flutter/material.dart';

class GraphState with ChangeNotifier {
  final List<ContinousDataSource> _leftAxisSources, _rightAxisSources;
  final List<DiscreteDataSource> _discreteSources;

  GraphState()
    : _leftAxisSources = List.empty(growable: true),
      _rightAxisSources = List.empty(growable: true),
      _discreteSources = List.empty(growable: true);

  List<ContinousDataSource> get leftAxisSources => _leftAxisSources;
  List<ContinousDataSource> get rightAxisSources => _rightAxisSources;
  List<DiscreteDataSource> get discreteSources => _discreteSources;

  void addLeftAxisSource(ContinousDataSource source) {
    leftAxisSources.add(source);
    notifyListeners();
  }

  void addRightAxisSource(ContinousDataSource source) {
    rightAxisSources.add(source);
    notifyListeners();
  }

  void addDiscreteSource(DiscreteDataSource source) {
    discreteSources.add(source);
    notifyListeners();
  }

  void removeLeftAxisSource(ContinousDataSource source) {
    leftAxisSources.remove(source);
    notifyListeners();
  }

  void removeRightAxisSource(ContinousDataSource source) {
    rightAxisSources.remove(source);
    notifyListeners();
  }

  void removeDiscreteSource(DiscreteDataSource source) {
    discreteSources.remove(source);
    notifyListeners();
  }
}
