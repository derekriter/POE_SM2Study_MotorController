import 'package:desktop_software/util/units.dart';
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
  final Unitless<double> dutyOut;
  final Volts<double> voltageOut;
  final Unit<double>? target;
  final Unit<double>? error;
  final Unitless<double>? pFactor;
  final Unitless<double>? iFactor;
  final Unitless<double>? dFactor;
  final Unitless<double>? fFactor;
  final Unitless<double>? sFactor;
  final Unitless<double>? vFactor;
  final Unitless<int>? slot;
  final Unit<double>? subError;
  final Seconds<double>? secsToCompletion;
  final Unitless<int>? phase;

  DeviceControlModeData._({
    required this.mode,
    required this.dutyOut,
    required this.voltageOut,
    required this.target,
    required this.error,
    required this.pFactor,
    required this.iFactor,
    required this.dFactor,
    required this.fFactor,
    required this.sFactor,
    required this.vFactor,
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

    late final Unitless<double> dutyOut;
    if (json["do"] is! double) {
      _logger.w("Invalid control mode, missing or invalid 'do' parameter");
      return null;
    }
    dutyOut = Unitless(json["do"] as double);

    late final Volts<double> voltageOut;
    if (json["vo"] is! double) {
      _logger.w("Invalid control mode, missing or invalid 'vo' parameter");
      return null;
    }
    voltageOut = Volts(json["vo"] as double);

    late final double? rawTarget;
    if (json["ct"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ct' parameter");
      return null;
    }
    rawTarget = json["ct"] as double?;
    late final Unit<double>? target;
    if (rawTarget == null) {
      target = null;
    } else {
      switch (mode) {
        case DeviceControlMode.pidPos:
        case DeviceControlMode.trapPos:
          {
            target = Rotations(rawTarget);
          }
        case DeviceControlMode.pidVel:
          {
            target = RPM(rawTarget);
          }
        default:
          {
            target = UnknownUnit(rawTarget);
          }
      }
    }

    late final double? rawError;
    if (json["ce"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ce' parameter");
      return null;
    }
    rawError = json["ce"] as double?;
    late final Unit<double>? error;
    if (rawError == null) {
      error = null;
    } else {
      switch (mode) {
        case DeviceControlMode.pidPos:
        case DeviceControlMode.trapPos:
          {
            error = Rotations(rawError);
          }
        case DeviceControlMode.pidVel:
          {
            error = RPM(rawError);
          }
        default:
          {
            error = UnknownUnit(rawError);
          }
      }
    }

    late final Unitless<double>? pFactor;
    if (json["cp"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cp' parameter");
      return null;
    }
    pFactor = Unitless.nullable(json["cp"] as double?);

    late final Unitless<double>? iFactor;
    if (json["ci"] is! double?) {
      _logger.w("Invalid control mode, invalid 'ci' parameter");
      return null;
    }
    iFactor = Unitless.nullable(json["ci"] as double?);

    late final Unitless<double>? dFactor;
    if (json["cd"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cd' parameter");
      return null;
    }
    dFactor = Unitless.nullable(json["cd"] as double?);

    late final Unitless<double>? fFactor;
    if (json["cf"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cf' parameter");
      return null;
    }
    fFactor = Unitless.nullable(json["cf"] as double?);

    late final Unitless<double>? sFactor;
    if (json["cs"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cs' parameter");
      return null;
    }
    sFactor = Unitless.nullable(json["cs"] as double?);

    late final Unitless<double>? vFactor;
    if (json["cv"] is! double?) {
      _logger.w("Invalid control mode, invalid 'cv' parameter");
      return null;
    }
    vFactor = Unitless.nullable(json["cv"] as double?);

    late final Unitless<int>? slot;
    if (json["sl"] is! int?) {
      _logger.w("Invalid control mode, invalid 'sl' parameter");
      return null;
    }
    slot = Unitless.nullable(json["sl"] as int?);

    late final double? rawSubError;
    if (json["se"] is! double?) {
      _logger.w("Invalid control mode, invalid 'se' parameter");
      return null;
    }
    rawSubError = json["se"] as double?;
    late final Unit<double>? subError;
    if (rawSubError == null) {
      subError = null;
    } else {
      switch (mode) {
        case DeviceControlMode.pidPos:
        case DeviceControlMode.trapPos:
          {
            subError = Rotations(rawSubError);
          }
        case DeviceControlMode.pidVel:
          {
            subError = RPM(rawSubError);
          }
        default:
          {
            subError = UnknownUnit(rawSubError);
          }
      }
    }

    late final Seconds<double>? secsToCompletion;
    if (json["tc"] is! double?) {
      _logger.w("Invalid control mode, invalid 'tc' parameter");
      return null;
    }
    secsToCompletion = Seconds.nullable(json["tc"] as double?);

    late final Unitless<int>? phase;
    if (json["ph"] is! int?) {
      _logger.w("Invalid control mode, invalid 'ph' parameter");
      return null;
    }
    phase = Unitless.nullable(json["ph"] as int?);

    return DeviceControlModeData._(
      mode: mode,
      dutyOut: dutyOut,
      voltageOut: voltageOut,
      target: target,
      error: error,
      pFactor: pFactor,
      iFactor: iFactor,
      dFactor: dFactor,
      fFactor: fFactor,
      sFactor: sFactor,
      vFactor: vFactor,
      slot: slot,
      subError: subError,
      secsToCompletion: secsToCompletion,
      phase: phase,
    );
  }

  static String? getPhaseName(DeviceControlMode mode, Unitless<int> phase) {
    switch (mode) {
      case DeviceControlMode.trapPos:
        {
          switch (phase.value) {
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
          return null;
        }
    }
  }

  DeviceControlModeData copy() {
    return DeviceControlModeData._(
      mode: mode,
      dutyOut: dutyOut.copy(),
      voltageOut: voltageOut.copy(),
      target: target?.copy(),
      error: error?.copy(),
      pFactor: pFactor?.copy(),
      iFactor: iFactor?.copy(),
      dFactor: dFactor?.copy(),
      fFactor: fFactor?.copy(),
      sFactor: sFactor?.copy(),
      vFactor: vFactor?.copy(),
      slot: slot?.copy(),
      subError: subError?.copy(),
      secsToCompletion: secsToCompletion?.copy(),
      phase: phase?.copy(),
    );
  }
}
