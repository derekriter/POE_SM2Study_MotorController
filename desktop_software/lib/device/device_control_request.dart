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
    return <String>["ref ${_duty.toStringAsFixed(4)}", "dutyCycle"];
  }
}
