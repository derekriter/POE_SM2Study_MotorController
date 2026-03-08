import 'package:logger/logger.dart';

final _logger = Logger();

enum DeviceControlMode {
  disabled(255, "disabled"),
  stop(0, "stop"),
  dutyCycle(1, "dutyCycle"),
  voltage(2, "voltage"),
  pidPos(3, "pidPos"),
  pidVel(4, "pidVel");

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
    } else if (id == pidVel.id) {
      return pidVel;
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
  final double? pFactor;
  final double? iFactor;
  final double? dFactor;
  final double? sFactor;

  DeviceControlModeData._({
    required this.mode,
    required this.dutyOut,
    required this.voltageOut,
    required this.target,
    required this.error,
    required this.pFactor,
    required this.iFactor,
    required this.dFactor,
    required this.sFactor,
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

    late final double? pFactor;
    if (json["cp"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cp' parameter");
      return null;
    }
    pFactor = json["cp"] as double?;

    late final double? iFactor;
    if (json["ci"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ci' parameter");
      return null;
    }
    iFactor = json["ci"] as double?;

    late final double? dFactor;
    if (json["cd"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cd' parameter");
      return null;
    }
    dFactor = json["cd"] as double?;

    late final double? sFactor;
    if (json["cs"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cs' parameter");
      return null;
    }
    sFactor = json["cs"] as double?;

    return DeviceControlModeData._(
      mode: mode,
      dutyOut: dutyOut,
      voltageOut: voltageOut,
      target: target,
      error: error,
      pFactor: pFactor,
      iFactor: iFactor,
      dFactor: dFactor,
      sFactor: sFactor,
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
      pFactor: pFactor,
      iFactor: iFactor,
      dFactor: dFactor,
      sFactor: sFactor,
    );
  }
}
