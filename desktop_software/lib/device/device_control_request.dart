import 'package:desktop_software/device/device_control_slot.dart';

abstract class DeviceControlRequest {
  List<String> toSerialCommands();
}

class DeviceEnableDisableRequest extends DeviceControlRequest {
  final bool enable;

  DeviceEnableDisableRequest(this.enable);

  @override
  List<String> toSerialCommands() {
    return <String>[enable ? "enable" : "disable"];
  }
}

class DeviceStopRequest extends DeviceControlRequest {
  @override
  List<String> toSerialCommands() {
    return <String>["stop"];
  }
}

class DeviceDutyCycleRequest extends DeviceControlRequest {
  final double duty;

  DeviceDutyCycleRequest(this.duty);

  @override
  List<String> toSerialCommands() {
    return <String>["dutyCycle ${duty.toStringAsFixed(4)}"];
  }
}

class DeviceVoltageRequest extends DeviceControlRequest {
  final double voltage;

  DeviceVoltageRequest(this.voltage);

  @override
  List<String> toSerialCommands() {
    return <String>["voltage ${voltage.toStringAsFixed(4)}"];
  }
}

class DevicePIDPositionRequest extends DeviceControlRequest {
  final double rots;
  final int slot;

  DevicePIDPositionRequest(this.rots, this.slot);

  @override
  List<String> toSerialCommands() {
    return <String>["pidPos ${rots.toStringAsFixed(4)} $slot"];
  }
}

class DevicePIDVelocityRequest extends DeviceControlRequest {
  final int slot;
  final double rpm;

  DevicePIDVelocityRequest(this.rpm, this.slot);

  @override
  List<String> toSerialCommands() {
    return <String>["pidVel ${rpm.toStringAsFixed(4)} $slot"];
  }
}

class DeviceTrapezoidalMotionPositionRequest extends DeviceControlRequest {
  final double rots;
  final int slot;

  DeviceTrapezoidalMotionPositionRequest(this.rots, this.slot);

  @override
  List<String> toSerialCommands() {
    return <String>["trapPos ${rots.toStringAsFixed(4)} $slot"];
  }
}

class DeviceSlotConfigRequest extends DeviceControlRequest {
  final DeviceSlotConfig config;
  final int slotNum;

  DeviceSlotConfigRequest(this.slotNum, this.config);

  @override
  List<String> toSerialCommands() {
    return <String>[
      "setSlot $slotNum ${config.kP.toStringAsFixed(8)} ${config.kI.toStringAsFixed(8)} ${config.kD.toStringAsFixed(8)} ${config.kS.toStringAsFixed(8)} ${config.kSMode.id} ${config.vMax.toStringAsFixed(2)} ${config.aStart.toStringAsFixed(2)} ${config.aEnd.toStringAsFixed(2)}",
    ];
  }
}

class DeviceGetSlotRequest extends DeviceControlRequest {
  final int slotNum;

  DeviceGetSlotRequest(this.slotNum);

  @override
  List<String> toSerialCommands() {
    return <String>["getSlot $slotNum"];
  }
}

class DeviceGetInfoRequest extends DeviceControlRequest {
  @override
  List<String> toSerialCommands() {
    return <String>["getInfo"];
  }
}
