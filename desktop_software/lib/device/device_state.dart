import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_frame.dart';

class DeviceState {
  bool isConnected = false;
  bool isReady = false;
  String? port;
  DeviceDataFrame? lastData;
  List<DeviceSlotConfig?> slots;
  int? updatesPerSec;
  String? deviceName;
  String? firmwareVersion;

  DeviceState() : slots = List.filled(6, null, growable: false);

  DeviceState copy() {
    return DeviceState()
      ..isConnected = isConnected
      ..isReady = isReady
      ..port = port
      ..lastData = lastData?.copy()
      ..slots = List.from(slots)
      ..updatesPerSec = updatesPerSec
      ..deviceName = deviceName
      ..firmwareVersion = firmwareVersion;
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceState &&
        other.isConnected == isConnected &&
        other.isReady == isReady &&
        other.port == port &&
        other.lastData == lastData &&
        other.slots == slots &&
        other.updatesPerSec == updatesPerSec &&
        other.deviceName == deviceName &&
        other.firmwareVersion == firmwareVersion;
  }
}
