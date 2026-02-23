class DeviceState {
  bool isConnected = false;

  DeviceState copy() {
    DeviceState copy = DeviceState();
    copy.isConnected = isConnected;

    return copy;
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceState && other.isConnected == isConnected;
  }
}
