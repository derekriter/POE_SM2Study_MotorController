import 'dart:isolate';

import 'package:desktop_software/device/device.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:logger/logger.dart';

final _logger = Logger();
late final ReceivePort _receive;
bool _shouldClose = false;
DeviceState? _prevState;

void deviceLoopInit(SendPort send) async {
  _receive = ReceivePort();
  _receive.listen(_onReceiveFromMain);
  send.send(_receive.sendPort);

  await Future.doWhile(() async {
    await _deviceLoop(send);
    await Future.delayed(Duration(milliseconds: 10)); //limit rate
    return !_shouldClose;
  });

  if (isConnected()) {
    disconnect();
  }

  _logger.i("Ended device loop");
  Isolate.exit();
}

Future<void> _deviceLoop(SendPort send) async {
  DeviceState state = DeviceState();
  state.isConnected = isConnected();

  if (_prevState != state) {
    send.send(state);
  }

  if (!state.isConnected) {
    connect();
    if (!isConnected()) await Future.delayed(Duration(seconds: 3));
  }

  _prevState = state.copy();
}

void _onReceiveFromMain(dynamic msg) {
  if (msg == "close") {
    _shouldClose = true;
  }
}
