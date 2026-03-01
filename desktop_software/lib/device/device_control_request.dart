import 'dart:ui';

abstract class DeviceControlRequest {
  List<String> toSerialCommands();
}

class DeviceEnableDisableRequest extends DeviceControlRequest {
  final bool _enable;

  DeviceEnableDisableRequest(bool enable) : _enable = enable;

  bool get enable => _enable;

  @override
  List<String> toSerialCommands() {
    return <String>[_enable ? "enable" : "disable"];
  }
}

class DeviceStopRequest extends DeviceControlRequest {
  @override
  List<String> toSerialCommands() {
    return <String>["stop"];
  }
}

class DeviceDutyCycleRequest extends DeviceControlRequest {
  final double _duty;

  DeviceDutyCycleRequest(double duty) : _duty = clampDouble(duty, -1, 1);

  double get duty => _duty;

  @override
  List<String> toSerialCommands() {
    return <String>["dutyCycle ${_duty.toStringAsFixed(4)}"];
  }
}

class DeviceVoltageRequest extends DeviceControlRequest {
  final double _voltage;

  DeviceVoltageRequest(double voltage) : _voltage = voltage;

  double get voltage => _voltage;

  @override
  List<String> toSerialCommands() {
    return <String>["voltage ${_voltage.toStringAsFixed(4)}"];
  }
}

class DevicePIDPositionRequest extends DeviceControlRequest {
  final int _slot;
  final int _ticks;

  DevicePIDPositionRequest(int ticks, int slot) : _ticks = ticks, _slot = slot;

  int get slot => _slot;
  int get ticks => _ticks;

  @override
  List<String> toSerialCommands() {
    return <String>["pidPos $_ticks $_slot"];
  }
}

class DevicePIDVelocityRequest extends DeviceControlRequest {
  final int _slot;
  final double _tps;

  DevicePIDVelocityRequest(double tps, int slot) : _tps = tps, _slot = slot;

  int get slot => _slot;
  double get tps => _tps;

  @override
  List<String> toSerialCommands() {
    return <String>["pidVel ${_tps.toStringAsFixed(4)} $_slot"];
  }
}

class DeviceTrapezoidalMotionPositionRequest extends DeviceControlRequest {
  final int _slot;
  final int _ticks;

  DeviceTrapezoidalMotionPositionRequest(int ticks, int slot)
    : _ticks = ticks,
      _slot = slot;

  int get slot => _slot;
  int get ticks => _ticks;

  @override
  List<String> toSerialCommands() {
    return <String>["trapPos $_ticks $_slot"];
  }
}
