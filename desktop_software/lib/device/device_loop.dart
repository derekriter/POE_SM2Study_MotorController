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
DateTime? _lastUPSTime;
int? _workingUPS;

void deviceLoopInit(SendPort send) async {
  _receive = ReceivePort();
  _receive.listen(_onReceiveFromMain);
  send.send(_receive.sendPort);

  await Future.doWhile(() async {
    await _deviceLoop(send);
    await Future.delayed(Duration(milliseconds: 1)); //limit rate
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
  state.connInfo = getConnectionInfo();

  final now = DateTime.now();
  if (_lastDataTime != null &&
      now.difference(_lastDataTime!).inMilliseconds >= 500) {
    _logger.i("Connection has timed out, auto-disconnecting...");

    _workingUPS = null;
    _lastUPSTime = null;

    disconnect();
    state.connInfo = (connected: false, ready: false, portInfo: null);
    state.lastData = null;
    state.updatesPerSec = null;
    state.deviceName = null;
    state.firmwareVersion = null;
  }

  if (state.connInfo.ready) {
    final String? raw = await readLine();
    if (raw != null) {
      final DeviceFrame? frame = _parseFrameIfValid(raw);

      if (frame is DeviceDataFrame) {
        state.lastData = frame;

        _lastDataTime = now;
        _workingUPS = (_workingUPS ?? 0) + 1;
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
      } else if (frame is DeviceInfoFrame) {
        state.deviceName = frame.deviceName;
        state.firmwareVersion = frame.firmwareVersion;
      }
    }

    if (_lastUPSTime != null && now.difference(_lastUPSTime!).inSeconds >= 1) {
      state.updatesPerSec = _workingUPS;
      _lastUPSTime = _lastUPSTime!.add(Duration(seconds: 1));
      _workingUPS = 0;
    }
  } else if (!state.connInfo.connected && _lastReconnectTime == null ||
      now.difference(_lastReconnectTime!).inSeconds >= 3) {
    connect("COM6");
    state.connInfo =
        getConnectionInfo(); //refresh info after attempting connect

    if (!state.connInfo.connected) {
      _lastDataTime = null;
      _lastReconnectTime = now;
      _lastUPSTime = null;
      _workingUPS = null;
    } else {
      _lastDataTime = null;
      _lastReconnectTime = null;

      //update local copy of all slots
      Future.doWhile(() async {
        if (!isReady()) return true;

        _lastDataTime = DateTime.now();
        _workingUPS = 0;
        _lastUPSTime = DateTime.now();
        flushBuffers(); //prevent unprocessed bad data from causing problems

        await sendControlRequest(DeviceGetInfoRequest());
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
