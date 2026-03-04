import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_loop.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _logger.i("Spawning device isolate...");

    _deviceReceive = ReceivePort();
    _deviceReceive.listen(_onReceiveFromDevice);
    Isolate.spawn(
          deviceLoopInit,
          _deviceReceive.sendPort,
          onExit: _deviceReceive.sendPort,
        )
        .then((val) async {
          _deviceIsolate = val;
          _deviceClosed = Completer();
          _logger.i("Successfully created device isolate");
        })
        .onError((err, stack) {
          _logger.f("Failed to create device isolate\n$err");
          ServicesBinding.instance.exitApplication(AppExitType.cancelable, 1);
        });

    //NOTE: will only trigger on cancelable closes, a force termination will not trigger this function
    AppLifecycleListener(
      onExitRequested: () async {
        if (_deviceSend == null) {
          _deviceIsolate?.kill();
        } else {
          _deviceSend!.send("close");
          await _deviceClosed!.future;
        }
        _deviceIsolate = null;
        _deviceClosed = null;
        _deviceSend = null;
        _deviceState = null;

        return AppExitResponse.exit;
      },
    );
  }

  bool get isConnected => _deviceState?.isConnected ?? false;
  String? get port => _deviceState?.port;
  bool? get enabled => _deviceState?.lastData?.enabled;
  double? get sourceVoltage => _deviceState?.lastData?.sourceVoltage;
  double? get position => _deviceState?.lastData?.position;
  double? get velocity => _deviceState?.lastData?.velocity;
  int? get timestamp => _deviceState?.lastData?.timestamp;
  String? get controlModeName => _deviceState?.lastData?.controlMode.name;
  double? get dutyOut => _deviceState?.lastData?.controlMode.output.dutyOut;
  double? get voltageOut =>
      _deviceState?.lastData?.controlMode.output.voltageOut;
  List<DeviceSlotConfig?>? get slotConfigs => _deviceState?.slots;

  void sendControlRequest(DeviceControlRequest req) {
    _deviceSend?.send(req);
  }

  final _logger = Logger();

  late final ReceivePort _deviceReceive;
  Isolate? _deviceIsolate;
  DeviceState? _deviceState;
  SendPort? _deviceSend;
  Completer<void>? _deviceClosed;

  void _onReceiveFromDevice(dynamic msg) {
    if (msg == null) {
      _deviceClosed?.complete();
    } else if (msg is SendPort) {
      _deviceSend = msg;
    } else if (msg is DeviceState) {
      _deviceState = msg;
      notifyListeners();
    } else {
      _logger.w("Unknown message '$msg' received from device isolate");
    }
  }
}
