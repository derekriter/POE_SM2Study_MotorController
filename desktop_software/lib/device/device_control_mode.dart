import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

enum DeviceControlMode {
  disabled(255, "Disabled"),
  stop(0, "Stop"),
  dutyCycle(1, "Duty Cycle"),
  voltage(2, "Voltage"),
  pidPos(3, "PID Position"),
  pidVel(4, "PID Velocity"),
  trapPos(5, "Trapezoidal Position");

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
    } else if (id == trapPos.id) {
      return trapPos;
    }

    return null;
  }

  static List<DropdownMenuEntry<DeviceControlMode>> asDropdownEntries() {
    return <DropdownMenuEntry<DeviceControlMode>>[
      DropdownMenuEntry(value: stop, label: stop.name),
      DropdownMenuEntry(value: dutyCycle, label: dutyCycle.name),
      DropdownMenuEntry(value: voltage, label: voltage.name),
      DropdownMenuEntry(value: pidPos, label: pidPos.name),
      DropdownMenuEntry(value: pidVel, label: pidVel.name),
      DropdownMenuEntry(value: trapPos, label: trapPos.name),
    ];
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
  final int? slot;
  final double? subError;
  final double? secsToCompletion;
  final int? phase;

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
    required this.slot,
    required this.subError,
    required this.secsToCompletion,
    required this.phase,
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

    late final int? slot;
    if (json["sl"] is! int?) {
      _logger.w("Invalid control mode, invalid 'sl' parameter");
      return null;
    }
    slot = json["sl"] as int?;

    late final double? subError;
    if (json["se"] is! double?) {
      _logger.w("Invalid control mode, invalid 'se' parameter");
      return null;
    }
    subError = json["se"] as double?;

    late final double? secsToCompletion;
    if (json["tc"] is! double?) {
      _logger.w("Invalid control mode, invalid 'tc' parameter");
      return null;
    }
    secsToCompletion = json["tc"] as double?;

    late final int? phase;
    if (json["ph"] is! int?) {
      _logger.w("Invalid control mode, invalid 'ph' parameter");
      return null;
    }
    phase = json["ph"] as int?;

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
      slot: slot,
      subError: subError,
      secsToCompletion: secsToCompletion,
      phase: phase,
    );
  }

  int get id => mode.id;
  String get name => mode.name;
  String? get phaseName {
    if (phase == null) return null;

    switch (mode) {
      case DeviceControlMode.trapPos:
        {
          switch (phase) {
            case 0:
              {
                return "accel";
              }
            case 1:
              {
                return "const vel";
              }
            case 2:
              {
                return "deccel";
              }
            case 3:
              {
                return "completed";
              }
            default:
              {
                return "unknown";
              }
          }
        }
      default:
        {
          return "unknown";
        }
    }
  }

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
      slot: slot,
      subError: subError,
      secsToCompletion: secsToCompletion,
      phase: phase,
    );
  }
}
