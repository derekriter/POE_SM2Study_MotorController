import 'package:desktop_software/device/device_frame.dart';

class DeviceState {
  bool isConnected = false;
  String? port;
  DeviceDataFrame? lastData;

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
