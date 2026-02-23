import 'dart:io';
import 'dart:isolate';

import 'package:desktop_software/device/device.dart';
import 'package:desktop_software/device/device_state.dart';

void deviceLoop(SendPort send) async {
  DeviceState? prevState;
  while (true) {
    DeviceState state = DeviceState();
    state.isConnected = isConnected();

    if (prevState == null || prevState != state) {
      send.send(state);
    }
    prevState = state.copy();

    if (!state.isConnected) {
      connect();
      if (!isConnected()) sleep(Duration(seconds: 3));
    }
  }
}
