import 'package:desktop_software/device/device.dart';
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
          late final String payload;
          if (json["py"] is! String) {
            _logger.w("Invalid msg frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as String;

          return DeviceMessageFrame._(message: payload);
        }
      case "ok":
        {
          return DeviceOKFrame._();
        }
      case "bad":
        {
          late final Map<String, dynamic> payload;
          if (json["py"] is! Map<String, dynamic>) {
            _logger.w("Invalid bad frame, missing or invalid 'py' parameter");
            return null;
          }
          payload = json["py"] as Map<String, dynamic>;

          return DeviceBadFrame._parsePayload(payload);
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
  final ControlMode _controlMode;
  final double _controlReference;
  final int _positionTicks;
  final double _positionRotations;
  final double _velocityTPS;
  final double _velocityRPM;
  final int _timestamp;
  final double _commandedOutput;
  final double _error;

  DeviceDataFrame._({
    required bool enabled,
    required double sourceVoltage,
    required ControlMode controlMode,
    required double controlReference,
    required int positionTicks,
    required double positionRotations,
    required double velocityTPS,
    required double velocityRPM,
    required int timestamp,
    required double commandedOutput,
    required double error,
  }) : _enabled = enabled,
       _sourceVoltage = sourceVoltage,
       _controlMode = controlMode,
       _controlReference = controlReference,
       _positionTicks = positionTicks,
       _positionRotations = positionRotations,
       _velocityTPS = velocityTPS,
       _velocityRPM = velocityRPM,
       _timestamp = timestamp,
       _commandedOutput = commandedOutput,
       _error = error;

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

    late final ControlMode controlMode;
    if (json["cm"] is! int) {
      _logger.w("Invalid data frame, missing or invalid 'cm' parameter");
      return null;
    }
    ControlMode? temp = ControlMode.fromID(json["cm"] as int);
    if (temp == null) {
      _logger.w("Invalid data frame, invalid 'cm' parameter");
      return null;
    }
    controlMode = temp;

    late final double controlReference;
    if (json["cr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'cr' parameter");
      return null;
    }
    controlReference = json["cr"] as double;

    late final int positionTicks;
    if (json["pt"] is! int) {
      _logger.w("Invalid data frame, missing or invalid 'pt' parameter");
      return null;
    }
    positionTicks = json["pt"] as int;

    late final double positionRotations;
    if (json["pr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'pr' parameter");
      return null;
    }
    positionRotations = json["pr"] as double;

    late final double velocityTPS;
    if (json["vt"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'vt' parameter");
      return null;
    }
    velocityTPS = json["vt"] as double;

    late final double velocityRPM;
    if (json["vr"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'vr' parameter");
      return null;
    }
    velocityRPM = json["vr"] as double;

    late final int timestamp;
    if (json["ms"] is! int) {
      _logger.w("Invalid data frame, missing or invalid 'ms' parameter");
      return null;
    }
    timestamp = json["ms"] as int;

    late final double commandedOutput;
    if (json["co"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'co' parameter");
      return null;
    }
    commandedOutput = json["co"] as double;

    late final double error;
    if (json["er"] is! double) {
      _logger.w("Invalid data frame, missing or invalid 'er' parameter");
      return null;
    }
    error = json["er"] as double;

    return DeviceDataFrame._(
      enabled: enabled,
      sourceVoltage: sourceVoltage,
      controlMode: controlMode,
      controlReference: controlReference,
      positionTicks: positionTicks,
      positionRotations: positionRotations,
      velocityTPS: velocityTPS,
      velocityRPM: velocityRPM,
      timestamp: timestamp,
      commandedOutput: commandedOutput,
      error: error,
    );
  }

  bool get enabled => _enabled;
  double get sourceVoltage => _sourceVoltage;
  ControlMode get controlMode => _controlMode;
  double get controlReference => _controlReference;
  int get positionTicks => _positionTicks;
  double get positionRotations => _positionRotations;
  double get velocityTPS => _velocityTPS;
  double get velocityRPM => _velocityRPM;
  int get timestamp => _timestamp;
  double get commandedOutput => _commandedOutput;
  double get error => _error;

  @override
  DeviceDataFrame copy() {
    return DeviceDataFrame._(
      enabled: enabled,
      sourceVoltage: sourceVoltage,
      controlMode: controlMode,
      controlReference: controlReference,
      positionTicks: positionTicks,
      positionRotations: positionRotations,
      velocityTPS: velocityTPS,
      velocityRPM: velocityRPM,
      timestamp: timestamp,
      commandedOutput: commandedOutput,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceDataFrame &&
        other._enabled == _enabled &&
        other._sourceVoltage == _sourceVoltage &&
        other._controlMode == _controlMode &&
        other._controlReference == _controlReference &&
        other._positionTicks == _positionTicks &&
        other._positionRotations == _positionRotations &&
        other._velocityTPS == _velocityTPS &&
        other._velocityRPM == _velocityRPM &&
        other._timestamp == _timestamp &&
        other._commandedOutput == _commandedOutput &&
        other._error == _error;
  }
}

enum DeviceResponseSeverity { ok, warning, error }

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
      case DeviceResponseSeverity.warning:
        return "[Device] WARN: ${_message ?? "no message provided"}";
      case DeviceResponseSeverity.error:
        return "[Device] ERR: ${_message ?? "no message provided"}";
    }
  }
}

class DeviceMessageFrame extends DeviceFrame {
  final String _message;

  DeviceMessageFrame._({required String message}) : _message = message;

  String get message => _message;

  @override
  DeviceMessageFrame copy() {
    return DeviceMessageFrame._(message: message);
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

class DeviceBadFrame extends DeviceFrame {
  final bool _isError;
  final String _message;

  DeviceBadFrame._({required bool isError, required String message})
    : _isError = isError,
      _message = message;

  static DeviceBadFrame? _parsePayload(Map<String, dynamic> json) {
    late final bool isError;
    if (json["sv"] is! int) {
      _logger.w("Invalid bad frame, missing or invalid 'sv' parameter");
      return null;
    }
    final int temp = json["sv"] as int;
    if (temp == 0) {
      isError = false;
    } else if (temp == 1) {
      isError = true;
    } else {
      _logger.w("Invalid bad frame, invalid 'sv' parameter");
      return null;
    }

    late final String message;
    if (json["msg"] is! String) {
      _logger.w("Invalid bad frame, missing or invalid 'msg' parameter");
      return null;
    }
    message = json["msg"] as String;

    return DeviceBadFrame._(isError: isError, message: message);
  }

  bool get isError => _isError;
  String get message => _message;

  DeviceResponse toResponse() {
    return DeviceResponse._(
      message: message,
      severity: isError
          ? DeviceResponseSeverity.error
          : DeviceResponseSeverity.warning,
    );
  }

  @override
  DeviceBadFrame copy() {
    return DeviceBadFrame._(isError: isError, message: message);
  }
}
