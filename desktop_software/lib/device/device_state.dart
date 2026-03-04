import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_frame.dart';

class DeviceState {
  bool isConnected = false;
  String? port;
  DeviceDataFrame? lastData;
  List<DeviceSlotConfig?> slots;

  DeviceState()
    : slots = List.filled(
        6,
        DeviceSlotConfig(
          kP: 0,
          kI: 0,
          kD: 0,
          kS: 0,
          kSMode: KSMode.errorBased,
          vMax: 0,
          aStart: 0,
          aEnd: 0,
        ),
        growable: false,
      );

  DeviceState copy() {
    return DeviceState()
      ..isConnected = isConnected
      ..port = port
      ..lastData = lastData?.copy();
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceState &&
        other.isConnected == isConnected &&
        other.port == port &&
        other.lastData == lastData;
  }
}
