import 'dart:convert';
import 'dart:isolate';

import 'package:desktop_software/device/device.dart';
import 'package:desktop_software/device/device_frame.dart';
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

  if (state.isConnected) {
    final String? raw = await readLine();
    if (raw != null) {
      final DeviceFrame? frame = _parseFrameIfValid(raw);
      _logger.d(frame);
    }
  } else {
    //attempt to connect, and if failed wait 3 seconds before trying again
    if (!connect()) {
      await Future.delayed(Duration(seconds: 3));
    }
  }

  if (_prevState != state) {
    send.send(state);
  }
  _prevState = state.copy();
}

void _onReceiveFromMain(dynamic msg) {
  if (msg == "close") {
    _shouldClose = true;
  } else {
    _logger.w("Unknown message '$msg' received from main isolate");
  }
}

DeviceFrame? _parseFrameIfValid(String raw) {
  late final dynamic parsed;
  try {
    parsed = jsonDecode(raw);
  } catch (err) {
    _logger.w("Exception while parsing frame data: '$err'");
    return null;
  }

  if (parsed is! Map<String, dynamic>) {
    return null;
  }
  return DeviceFrame.parseFromJson(parsed);
}
