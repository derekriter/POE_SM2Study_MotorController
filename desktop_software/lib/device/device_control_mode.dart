import 'package:logger/logger.dart';

final _logger = Logger();

enum DeviceControlMode {
  disabled(255, "disabled"),
  stop(0, "stop"),
  dutyCycle(1, "dutyCycle"),
  voltage(2, "voltage"),
  pidPos(3, "pidPos");

  final int id;
  final String name;

  const DeviceControlMode(this.id, this.name);

  static DeviceControlMode? fromID(int id) {
    if (id == disabled.id) {
      return disabled;
    } else if (id == stop.id) {
      return stop;
    } else if (id == dutyCycle.id) {
      return dutyCycle;
    } else if (id == voltage.id) {
      return voltage;
    } else if (id == pidPos.id) {
      return pidPos;
    }

    return null;
  }
}

class DeviceControlModeData {
  final DeviceControlMode mode;
  final double dutyOut;
  final double voltageOut;
  final double? target;
  final double? error;

  DeviceControlModeData._({
    required this.mode,
    required this.dutyOut,
    required this.voltageOut,
    required this.target,
    required this.error,
  });

  static DeviceControlModeData? parseJSON(Map<String, dynamic> json) {
    late final DeviceControlMode mode;
    if (json["id"] is! int) {
      _logger.w("Invalid control mode, missing or invalid 'id' parameter");
      return null;
    }
    DeviceControlMode? tempMode = DeviceControlMode.fromID(json["id"] as int);
    if (tempMode == null) {
      _logger.w("Invalid control mode, invalid 'id' parameter");
      return null;
    }
    mode = tempMode;

    late final double dutyOut;
    if (json["do"] is! double) {
      _logger.w("Invalid control mode, missing or invalid 'do' parameter");
      return null;
    }
    dutyOut = json["do"] as double;

    late final double voltageOut;
    if (json["vo"] is! double) {
      _logger.w("Invalid control mode, missing or invalid 'vo' parameter");
      return null;
    }
    voltageOut = json["vo"] as double;

    late final double? target;
    if (json["ct"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ct' parameter");
      return null;
    }
    target = json["ct"] as double?;

    late final double? error;
    if (json["ce"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ce' parameter");
      return null;
    }
    error = json["ce"] as double?;

    return DeviceControlModeData._(
      mode: mode,
      dutyOut: dutyOut,
      voltageOut: voltageOut,
      target: target,
      error: error,
    );
  }

  int get id => mode.id;
  String get name => mode.name;

  DeviceControlModeData copy() {
    return DeviceControlModeData._(
      mode: mode,
      dutyOut: dutyOut,
      voltageOut: voltageOut,
      target: target,
      error: error,
    );
  }
}
