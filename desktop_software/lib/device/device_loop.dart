import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:desktop_software/device/device.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_frame.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:logger/logger.dart';

final _logger = Logger();
late final ReceivePort _receive;
bool _shouldClose = false;
DeviceState? _prevState;
DateTime? _lastDataTime;
DateTime? _lastReconnectTime;

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
    await sendControlRequest(DeviceEnableDisableRequest(false));
    disconnect();
  }

  _logger.i("Shut down device loop");
  Isolate.exit();
}

Future<void> _deviceLoop(SendPort send) async {
  DeviceState state = _prevState?.copy() ?? DeviceState();
  state.isConnected = isConnected();
  state.isReady = isReady();
  state.port = getConnectedPort();

  final now = DateTime.now();
  if (_lastDataTime != null &&
      now.difference(_lastDataTime!).inMilliseconds >= 500) {
    //connection has timed out, auto-disconnect
    _logger.i("Connection has timed out, auto-disconnecting...");

    disconnect();
    state.isConnected = false;
    state.isReady = false;
  }

  if (state.isReady) {
    final String? raw = await readLine();
    if (raw != null) {
      final DeviceFrame? frame = _parseFrameIfValid(raw);

      if (frame is DeviceDataFrame) {
        state.lastData = frame;
        _lastDataTime = DateTime.now();
      } else if (frame is DeviceMessageFrame) {
        final resp = frame.toResponse().toString();

        switch (frame.severity) {
          case DeviceResponseSeverity.ok:
          case DeviceResponseSeverity.info:
            {
              _logger.i(resp);
            }
          case DeviceResponseSeverity.warning:
            {
              _logger.w(resp);
            }
          case DeviceResponseSeverity.error:
            {
              _logger.e(resp);
            }
        }
      } else if (frame is DeviceOKFrame) {
        _logger.i(frame.toResponse().toString());
      } else if (frame is DeviceSlotFrame) {
        state.slots[frame.slotNum] = frame.slotConfig;
      }
    }
  } else if (!state.isConnected && _lastReconnectTime == null ||
      now.difference(_lastReconnectTime!).inSeconds >= 3) {
    state.isConnected = connect();

    if (!state.isConnected) {
      _lastDataTime = null;
      _lastReconnectTime = DateTime.now();
    } else {
      _lastDataTime = null;
      _lastReconnectTime = null;

      //update local copy of all slots
      Future.doWhile(() async {
        if (!isReady()) return true;

        _lastDataTime = DateTime.now();
        flushBuffers(); //prevent unprocessed bad data from causing problems
        for (int i = 0; i < state.slots.length; i++) {
          await sendControlRequest(DeviceGetSlotRequest(i));
        }
        return false;
      });
    }
  }

  if (_prevState != state) {
    send.send(state);
  }

  _prevState = state;
}

void _onReceiveFromMain(dynamic msg) async {
  if (msg == "close") {
    _shouldClose = true;
  } else if (msg is DeviceControlRequest) {
    sendControlRequest(msg); //do not await
  } else {
    _logger.w("Unknown message '$msg' received from main isolate");
  }
}

DeviceFrame? _parseFrameIfValid(String raw) {
  late final dynamic parsed;
  try {
    parsed = jsonDecode(raw);
  } catch (err) {
    _logger.w("Exception while parsing frame data: $err");
    return null;
  }

  if (parsed is! Map<String, dynamic>) {
    return null;
  }
  return DeviceFrame.parseFromJson(parsed);
}
