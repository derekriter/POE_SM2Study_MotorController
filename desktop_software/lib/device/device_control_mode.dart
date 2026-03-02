import 'package:logger/logger.dart';

final _logger = Logger();

class MotorOutput {
  final double dutyOut;

  MotorOutput({required this.dutyOut});
}

abstract class ControlModeData {
  static ControlModeData? parseJSON(dynamic json) {
    if (json is int) {
      switch (json) {
        case 0:
          {
            return StopControlModeData._();
          }
        case 255:
          {
            return DisabledControlModeData._();
          }
      }

      _logger.w("Invalid control mode, invalid id");
      return null;
    } else if (json is Map<String, dynamic>) {
      late final int id;
      if (json["id"] is! int) {
        _logger.w("Invalid control mode, missing or invalid 'id' parameter");
        return null;
      }
      id = json["id"] as int;

      switch (id) {
        case 1:
          {
            return DutyCycleControlModeData.parseJSON(json);
          }
      }

      _logger.w("Invalid control mode, invalid 'id' parameter");
      return null;
    }

    _logger.w("Invalid control mode, unrecognized data type");
    return null;
  }

  String get name;
  MotorOutput get output;

  ControlModeData copy();
}

class DisabledControlModeData extends ControlModeData {
  DisabledControlModeData._();

  @override
  ControlModeData copy() {
    return DisabledControlModeData._();
  }

  @override
  String get name => "disabled";
  @override
  MotorOutput get output => MotorOutput(dutyOut: 0);

  @override
  bool operator ==(Object other) {
    return other is DisabledControlModeData;
  }
}

class StopControlModeData extends ControlModeData {
  StopControlModeData._();

  @override
  StopControlModeData copy() {
    return StopControlModeData._();
  }

  @override
  String get name => "stop";
  @override
  MotorOutput get output => MotorOutput(dutyOut: 0);

  @override
  bool operator ==(Object other) {
    return other is StopControlModeData;
  }
}

class DutyCycleControlModeData extends ControlModeData {
  final double _duty;

  DutyCycleControlModeData._({required double duty}) : _duty = duty;

  static DutyCycleControlModeData? parseJSON(Map<String, dynamic> json) {
    late final double duty;
    if (json["do"] is! double) {
      _logger.w(
        "Invalid duty cycle control mode, missing or invalid 'do' parameter",
      );
      return null;
    }
    duty = json["do"] as double;

    return DutyCycleControlModeData._(duty: duty);
  }

  @override
  String get name => "dutyCycle";
  @override
  MotorOutput get output => MotorOutput(dutyOut: _duty);
  double get duty => _duty;

  @override
  DutyCycleControlModeData copy() {
    return DutyCycleControlModeData._(duty: _duty);
  }

  @override
  bool operator ==(Object other) {
    return other is DutyCycleControlModeData && other._duty == _duty;
  }
}
