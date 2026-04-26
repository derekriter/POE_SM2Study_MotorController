import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/util/units.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

abstract class DeviceFrame {
  static DeviceFrame? parseFromJson(Map<String, dynamic> json) {
    late final String type;

    if (json["ty"] is! String) {
      _logger.w("Invalid device frame, missing or invalid 'ty' parameter");
      return null;
    }
    type = json["ty"] as String;

    switch (type) {
      case "data":
        {
          late final Map<String, dynamic> payload;
          if (json["py"] is! Map<String, dynamic>) {
            _logger.w("Invalid data frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as Map<String, dynamic>;

          return DeviceDataFrame._parsePayload(payload);
        }
      case "msg":
        {
          late final Map<String, dynamic> payload;
          if (json["py"] is! Map<String, dynamic>) {
            _logger.w("Invalid msg frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as Map<String, dynamic>;

          return DeviceMessageFrame._parsePayload(payload);
        }
      case "ok":
        {
          return DeviceOKFrame._();
        }
      case "slot":
        {
          late final Map<String, dynamic> payload;
          if (json["py"] is! Map<String, dynamic>) {
            _logger.w("Invalid slot frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as Map<String, dynamic>;

          return DeviceSlotFrame._parsePayload(payload);
        }
      case "info":
        {
          late final Map<String, dynamic> payload;
          if (json["py"] is! Map<String, dynamic>) {
            _logger.w("Invalid info frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as Map<String, dynamic>;

          return DeviceInfoFrame._parsePayload(payload);
        }
      default:
        {
          _logger.w("Invalid device frame, invalid 'ty' parameter");
          return null;
        }
    }
  }

  DeviceFrame copy();
}

class DeviceDataFrame extends DeviceFrame {
  final bool enabled;
  final Volts<double> sourceVoltage;
  final DeviceControlModeData controlMode;
  final Rotations<double> position;
  final RPM<double> velocity;
  final Milliseconds<int> timestamp;

  DeviceDataFrame._({
    required this.enabled,
    required this.sourceVoltage,
    required this.controlMode,
    required this.position,
    required this.velocity,
    required this.timestamp,
  });

  static DeviceDataFrame? _parsePayload(Map<String, dynamic> json) {
    late final bool enabled;
    if (json["en"] is! bool) {
      _logger.w("Invalid data frame, missing or invalid 'en' parameter");
      return null;
    }
    enabled = json["en"] as bool;

    late final Volts<double> sourceVoltage;
    if (json["sv"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'sv' parameter");
      return null;
    }
    sourceVoltage = Volts(json["sv"] as double);

    late final DeviceControlModeData controlMode;
    if (json["cm"] is! Map<String, dynamic>) {
      _logger.w("Invalid data frame, missing or invalid 'cm' parameter");
      return null;
    }
    DeviceControlModeData? temp = DeviceControlModeData.parseJSON(
      json["cm"] as Map<String, dynamic>,
    );
    if (temp == null) {
      _logger.w("Invalid data frame, invalid 'cm' parameter");
      return null;
    }
    controlMode = temp;

    late final Rotations<double> position;
    if (json["pr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'pr' parameter");
      return null;
    }
    position = Rotations(json["pr"] as double);

    late final RPM<double> velocity;
    if (json["vr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'vr' parameter");
      return null;
    }
    velocity = RPM(json["vr"] as double);

    late final Milliseconds<int> timestamp;
    if (json["ms"] is! int) {
      _logger.w("Invalid data frame, missing or invalid 'ms' parameter");
      return null;
    }
    timestamp = Milliseconds(json["ms"] as int);

    return DeviceDataFrame._(
      enabled: enabled,
      sourceVoltage: sourceVoltage,
      controlMode: controlMode,
      position: position,
      velocity: velocity,
      timestamp: timestamp,
    );
  }

  @override
  DeviceDataFrame copy() {
    return DeviceDataFrame._(
      enabled: enabled,
      sourceVoltage: sourceVoltage.copy(),
      controlMode: controlMode.copy(),
      position: position.copy(),
      velocity: velocity.copy(),
      timestamp: timestamp.copy(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceDataFrame &&
        other.enabled == enabled &&
        other.sourceVoltage == sourceVoltage &&
        other.controlMode == controlMode &&
        other.position == position &&
        other.velocity == velocity &&
        other.timestamp == timestamp;
  }
}

enum DeviceResponseSeverity {
  ok(null),
  info(0),
  warning(1),
  error(2);

  final int? id;

  const DeviceResponseSeverity(this.id);

  static DeviceResponseSeverity? fromID(int id) {
    if (id == ok.id) {
      return ok;
    } else if (id == info.id) {
      return info;
    } else if (id == warning.id) {
      return warning;
    } else if (id == error.id) {
      return error;
    }

    return null;
  }
}

class DeviceResponse {
  final String? message;
  final DeviceResponseSeverity severity;

  DeviceResponse._({this.message, required this.severity});

  @override
  String toString() {
    switch (severity) {
      case DeviceResponseSeverity.ok:
        return "[Device] OK";
      case DeviceResponseSeverity.info:
        return "[DEVICE] INFO: ${message ?? "no message provided"}";
      case DeviceResponseSeverity.warning:
        return "[Device] WARN: ${message ?? "no message provided"}";
      case DeviceResponseSeverity.error:
        return "[Device] ERR: ${message ?? "no message provided"}";
    }
  }
}

enum DeviceMessageFrameSeverity {
  info(0),
  warning(1),
  error(2);

  final int id;

  const DeviceMessageFrameSeverity(this.id);

  static DeviceMessageFrameSeverity? fromID(int id) {
    if (id == info.id) {
      return info;
    } else if (id == warning.id) {
      return warning;
    } else if (id == error.id) {
      return error;
    }

    return null;
  }
}

class DeviceMessageFrame extends DeviceFrame {
  final DeviceResponseSeverity severity;
  final String? message;

  DeviceMessageFrame._({required this.severity, required this.message});

  static DeviceMessageFrame? _parsePayload(Map<String, dynamic> json) {
    late final DeviceResponseSeverity severity;
    if (json["sv"] is! int) {
      _logger.w("Invalid bad frame, missing or invalid 'sv' parameter");
      return null;
    }
    final DeviceResponseSeverity? sv = DeviceResponseSeverity.fromID(
      json["sv"] as int,
    );
    if (sv == null) {
      _logger.w("Invalid bad frame, invalid 'sv' parameter");
      return null;
    }
    severity = sv;

    late final String? message;
    if (json["msg"] is! String?) {
      _logger.w("Invalid bad frame, invalid 'msg' parameter");
      return null;
    }
    message = json["msg"] as String?;

    return DeviceMessageFrame._(severity: severity, message: message);
  }

  DeviceResponse toResponse() {
    return DeviceResponse._(message: message, severity: severity);
  }

  @override
  DeviceMessageFrame copy() {
    return DeviceMessageFrame._(severity: severity, message: message);
  }
}

class DeviceOKFrame extends DeviceFrame {
  DeviceOKFrame._();

  DeviceResponse toResponse() {
    return DeviceResponse._(severity: DeviceResponseSeverity.ok);
  }

  @override
  DeviceOKFrame copy() {
    return DeviceOKFrame._();
  }
}

class DeviceSlotFrame extends DeviceFrame {
  final int slotNum;
  final double kP, kI, kD;
  final double kF, kS, kV;
  final KSMode kSMode;
  final double vMax, aStart, aEnd;

  DeviceSlotFrame._({
    required this.slotNum,
    required this.kP,
    required this.kI,
    required this.kD,
    required this.kF,
    required this.kS,
    required this.kSMode,
    required this.kV,
    required this.vMax,
    required this.aStart,
    required this.aEnd,
  });

  static DeviceSlotFrame? _parsePayload(Map<String, dynamic> json) {
    late final int slotNum;
    if (json["sn"] is! int) {
      _logger.w("Invalid slot frame, missing or invalid 'sn' parameter");
      return null;
    }
    slotNum = json["sn"] as int;
    if (slotNum < 0 || slotNum > 5) {
      _logger.w("Invalid slot frame, invalid 'sn' parameter");
      return null;
    }

    late final double kP;
    if (json["kp"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'kp' parameter");
      return null;
    }
    kP = json["kp"] as double;

    late final double kI;
    if (json["ki"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'ki' parameter");
      return null;
    }
    kI = json["ki"] as double;

    late final double kD;
    if (json["kd"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'kd' parameter");
      return null;
    }
    kD = json["kd"] as double;

    late final double kF;
    if (json["kf"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'kf' parameter");
      return null;
    }
    kF = json["kf"] as double;

    late final double kS;
    if (json["ks"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'ks' parameter");
      return null;
    }
    kS = json["ks"] as double;

    late final KSMode kSMode;
    if (json["sm"] is! int) {
      _logger.w("Invalid slot frame, missing or invalid 'sm' parameter");
      return null;
    }
    final KSMode? temp = KSMode.fromID(json["sm"] as int);
    if (temp == null) {
      _logger.w("Invalid slot frame, invalid 'sm' parameter");
      return null;
    }
    kSMode = temp;

    late final double kV;
    if (json["kv"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'kv' parameter");
      return null;
    }
    kV = json["kv"] as double;

    late final double vMax;
    if (json["vm"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'vm' parameter");
      return null;
    }
    vMax = json["vm"] as double;

    late final double aStart;
    if (json["as"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'as' parameter");
      return null;
    }
    aStart = json["as"] as double;

    late final double aEnd;
    if (json["ae"] is! double) {
      _logger.w("Invalid slot frame, missing or invalid 'ae' parameter");
      return null;
    }
    aEnd = json["ae"] as double;

    return DeviceSlotFrame._(
      slotNum: slotNum,
      kP: kP,
      kI: kI,
      kD: kD,
      kF: kF,
      kS: kS,
      kSMode: kSMode,
      kV: kV,
      vMax: vMax,
      aStart: aStart,
      aEnd: aEnd,
    );
  }

  DeviceSlotConfig get slotConfig => DeviceSlotConfig(
    kP: kP,
    kI: kI,
    kD: kD,
    kF: kF,
    kS: kS,
    kSMode: kSMode,
    kV: kV,
    vMax: vMax,
    aStart: aStart,
    aEnd: aEnd,
  );

  @override
  DeviceSlotFrame copy() {
    return DeviceSlotFrame._(
      slotNum: slotNum,
      kP: kP,
      kI: kI,
      kD: kD,
      kF: kF,
      kS: kS,
      kSMode: kSMode,
      kV: kV,
      vMax: vMax,
      aStart: aStart,
      aEnd: aEnd,
    );
  }
}

class DeviceInfoFrame extends DeviceFrame {
  final String deviceName;
  final String firmwareVersion;

  DeviceInfoFrame._({required this.deviceName, required this.firmwareVersion});

  static DeviceInfoFrame? _parsePayload(Map<String, dynamic> json) {
    late final String deviceName;
    if (json["nm"] is! String) {
      _logger.w("Invalid info frame, missing or invalid 'nm' parameter");
      return null;
    }
    deviceName = json["nm"] as String;

    late final String firmwareVersion;
    if (json["fv"] is! String) {
      _logger.w("Invalid info frame, missing or invalid 'nm' parameter");
      return null;
    }
    firmwareVersion = json["fv"] as String;

    return DeviceInfoFrame._(
      deviceName: deviceName,
      firmwareVersion: firmwareVersion,
    );
  }

  @override
  DeviceFrame copy() {
    return DeviceInfoFrame._(
      deviceName: deviceName,
      firmwareVersion: firmwareVersion,
    );
  }
}
