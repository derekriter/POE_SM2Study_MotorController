import 'package:desktop_software/device/device_control_mode.dart';
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
  final bool _enabled;
  final double _sourceVoltage;
  final ControlModeData _controlMode;
  final double _position;
  final double _velocity;

  DeviceDataFrame._({
    required bool enabled,
    required double sourceVoltage,
    required ControlModeData controlMode,
    required double position,
    required double velocity,
  }) : _enabled = enabled,
       _sourceVoltage = sourceVoltage,
       _controlMode = controlMode,
       _position = position,
       _velocity = velocity;

  static DeviceDataFrame? _parsePayload(Map<String, dynamic> json) {
    late final bool enabled;
    if (json["en"] is! bool) {
      _logger.w("Invalid data frame, missing or invalid 'en' parameter");
      return null;
    }
    enabled = json["en"] as bool;

    late final double sourceVoltage;
    if (json["sv"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'sv' parameter");
      return null;
    }
    sourceVoltage = json["sv"] as double;

    late final ControlModeData controlMode;
    if (json["cm"] == null) {
      _logger.w("Invalid data frame, missing 'cm' parameter");
      return null;
    }
    ControlModeData? temp = ControlModeData.parseJSON(json["cm"] as dynamic);
    if (temp == null) {
      _logger.w("Invalid data frame, invalid 'cm' parameter");
      return null;
    }
    controlMode = temp;

    late final double position;
    if (json["pr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'pr' parameter");
      return null;
    }
    position = json["pr"] as double;

    late final double velocity;
    if (json["vr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'vr' parameter");
      return null;
    }
    velocity = json["vr"] as double;

    return DeviceDataFrame._(
      enabled: enabled,
      sourceVoltage: sourceVoltage,
      controlMode: controlMode,
      position: position,
      velocity: velocity,
    );
  }

  bool get enabled => _enabled;
  double get sourceVoltage => _sourceVoltage;
  ControlModeData get controlMode => _controlMode;
  double get position => _position;
  double get velocity => _velocity;

  @override
  DeviceDataFrame copy() {
    return DeviceDataFrame._(
      enabled: _enabled,
      sourceVoltage: _sourceVoltage,
      controlMode: _controlMode.copy(),
      position: _position,
      velocity: _velocity,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceDataFrame &&
        other._enabled == _enabled &&
        other._sourceVoltage == _sourceVoltage &&
        other._controlMode == _controlMode &&
        other._position == _position &&
        other._velocity == _velocity;
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
  final String? _message;
  final DeviceResponseSeverity _severity;

  DeviceResponse._({String? message, required DeviceResponseSeverity severity})
    : _message = message,
      _severity = severity;

  String? get message => _message;
  DeviceResponseSeverity get severity => _severity;

  @override
  String toString() {
    switch (_severity) {
      case DeviceResponseSeverity.ok:
        return "[Device] OK";
      case DeviceResponseSeverity.info:
        return "[DEVICE] INFO: ${_message ?? "no message provided"}";
      case DeviceResponseSeverity.warning:
        return "[Device] WARN: ${_message ?? "no message provided"}";
      case DeviceResponseSeverity.error:
        return "[Device] ERR: ${_message ?? "no message provided"}";
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
  final DeviceResponseSeverity _severity;
  final String? _message;

  DeviceMessageFrame._({
    required DeviceResponseSeverity severity,
    required String? message,
  }) : _severity = severity,
       _message = message;

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

  DeviceResponseSeverity get severity => _severity;
  String? get message => _message;

  DeviceResponse toResponse() {
    return DeviceResponse._(message: message, severity: _severity);
  }

  @override
  DeviceMessageFrame copy() {
    return DeviceMessageFrame._(severity: _severity, message: message);
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
