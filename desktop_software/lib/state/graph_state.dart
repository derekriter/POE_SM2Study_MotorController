import 'dart:math';

import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/util/units.dart';
import 'package:flutter/material.dart';

typedef ContinuousSource = ContinuousDataSource<Unit<num>>;
typedef DiscreteSource = DiscreteDataSource<dynamic>;
typedef ContinuousConfig = SourceConfig<ContinuousSource, Unit<num>>;
typedef DiscreteConfig = SourceConfig<DiscreteSource, dynamic>;

class SourceConfig<T extends DataSource<S>, S> {
  T source;
  Color color;
  bool visible;

  static const usableColors = <String, Color>{
    "Blue": Color.fromRGBO(114, 166, 218, 1),
    "Gold": Color.fromRGBO(237, 201, 94, 1),
    "Red": Color.fromRGBO(225, 107, 123, 1),
    "Purple": Color.fromRGBO(175, 145, 186, 1),
    "Orange": Color.fromRGBO(234, 166, 97, 1),
    "Tan": Color.fromRGBO(193, 181, 138, 1),
    "Grey": Color.fromRGBO(166, 166, 166, 1),
    "Green": Color.fromRGBO(131, 201, 159, 1),
    "Pink": Color.fromRGBO(217, 146, 169, 1),
    "Brown": Color.fromRGBO(202, 168, 129, 1),
  };

  SourceConfig({
    required this.source,
    required this.color,
    required this.visible,
  });
}

class GraphState with ChangeNotifier {
  final List<ContinuousConfig> _leftAxisConfigs, _rightAxisConfigs;
  final List<DiscreteConfig> _discreteConfigs;

  Milliseconds<int>? _pauseTime;

  GraphState()
    : _leftAxisConfigs = List.empty(growable: true),
      _rightAxisConfigs = List.empty(growable: true),
      _discreteConfigs = List.empty(growable: true);

  List<ContinuousConfig> get leftAxisConfigs => _leftAxisConfigs;
  List<ContinuousConfig> get rightAxisConfigs => _rightAxisConfigs;
  List<DiscreteConfig> get discreteConfigs => _discreteConfigs;

  void addLeftAxisSource(ContinuousSource source) {
    _leftAxisConfigs.add(
      SourceConfig(source: source, color: _selectUsableColor(), visible: true),
    );
    notifyListeners();
  }

  void addRightAxisSource(ContinuousSource source) {
    _rightAxisConfigs.add(
      SourceConfig(source: source, color: _selectUsableColor(), visible: true),
    );
    notifyListeners();
  }

  void addDiscreteSource(DiscreteSource source) {
    _discreteConfigs.add(
      SourceConfig(source: source, color: _selectUsableColor(), visible: true),
    );
    notifyListeners();
  }

  void removeLeftAxisConfig(ContinuousConfig cfg) {
    _leftAxisConfigs.remove(cfg);
    notifyListeners();
  }

  void removeRightAxisConfig(ContinuousConfig cfg) {
    _rightAxisConfigs.remove(cfg);
    notifyListeners();
  }

  void removeDiscreteConfig(DiscreteConfig cfg) {
    _discreteConfigs.remove(cfg);
    notifyListeners();
  }

  void modifyConfig<T extends DataSource<S>, S>(
    SourceConfig<T, S> cfg,
    void Function(SourceConfig<T, S>) exec,
  ) {
    exec(cfg);
    notifyListeners();
  }

  Milliseconds<int>? get pauseTime => _pauseTime;
  void pause(Milliseconds<int> currentTime) {
    _pauseTime = currentTime.copy();
    notifyListeners();
  }

  void resume() {
    _pauseTime = null;
    notifyListeners();
  }

  Color _selectUsableColor() {
    List<Color> workingColors = List.from(SourceConfig.usableColors.values);
    final usedColors = _leftAxisConfigs
        .map((e) => e.color)
        .followedBy(_rightAxisConfigs.map((e) => e.color))
        .followedBy(_discreteConfigs.map((e) => e.color));

    for (var c in usedColors) {
      if (workingColors.isEmpty) break;

      workingColors.remove(c); //doesn't fail if the object isn't in the list
    }

    if (workingColors.isEmpty) {
      //all colors have already been used, just pick a random one
      return SourceConfig.usableColors.values.elementAt(
        Random().nextInt(usedColors.length - 1),
      );
    } else if (workingColors.length == 1) {
      return workingColors[0];
    } else {
      //return random color from the unused ones
      return workingColors[Random().nextInt(workingColors.length - 1)];
    }
  }
}
