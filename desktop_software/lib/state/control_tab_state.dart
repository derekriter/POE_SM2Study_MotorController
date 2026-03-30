import 'package:flutter/material.dart';

class ControlTabState with ChangeNotifier {
  double _duty, _voltage, _pidPosTarget, _pidVelTarget, _trapPosTarget;
  int _pidPosSlot, _pidVelSlot, _trapPosSlot;

  ControlTabState()
    : _duty = 0,
      _voltage = 0,
      _pidPosTarget = 0,
      _pidVelTarget = 0,
      _trapPosTarget = 0,
      _pidPosSlot = 0,
      _pidVelSlot = 0,
      _trapPosSlot = 0;

  double get duty => _duty;
  double get voltage => _voltage;
  double get pidPosTarget => _pidPosTarget;
  double get pidVelTarget => _pidVelTarget;
  double get trapPosTarget => _trapPosTarget;
  int get pidPosSlot => _pidPosSlot;
  int get pidVelSlot => _pidVelSlot;
  int get trapPosSlot => _trapPosSlot;

  set duty(double duty) {
    _duty = duty;
    notifyListeners();
  }

  set voltage(double voltage) {
    _voltage = voltage;
    notifyListeners();
  }

  set pidPosTarget(double pidPosTarget) {
    _pidPosTarget = pidPosTarget;
    notifyListeners();
  }

  set pidVelTarget(double pidVelTarget) {
    _pidVelTarget = pidVelTarget;
    notifyListeners();
  }

  set trapPosTarget(double trapPosTarget) {
    _trapPosTarget = trapPosTarget;
    notifyListeners();
  }

  set pidPosSlot(int pidPosSlot) {
    _pidPosSlot = pidPosSlot;
    notifyListeners();
  }

  set pidVelSlot(int pidVelSlot) {
    _pidVelSlot = pidVelSlot;
    notifyListeners();
  }

  set trapPosSlot(int trapPosSlot) {
    _trapPosSlot = trapPosSlot;
    notifyListeners();
  }

  void resetOutputs() {
    _duty = 0;
    _voltage = 0;
    notifyListeners();
  }
}
