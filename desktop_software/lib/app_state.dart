import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_loop.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

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
  bool get isReady => _deviceState?.isReady ?? false;
  String? get port => _deviceState?.port;
  bool? get enabled => _deviceState?.lastData?.enabled;
  double? get sourceVoltage => _deviceState?.lastData?.sourceVoltage;
  double? get position => _deviceState?.lastData?.position;
  double? get velocity => _deviceState?.lastData?.velocity;
  int? get timestamp => _deviceState?.lastData?.timestamp;
  int? get controlModeID => _deviceState?.lastData?.controlMode.id;
  String? get controlModeName => _deviceState?.lastData?.controlMode.name;
  DeviceControlMode? get controlMode =>
      _deviceState?.lastData?.controlMode.mode;
  double? get dutyOut => _deviceState?.lastData?.controlMode.dutyOut;
  double? get voltageOut => _deviceState?.lastData?.controlMode.voltageOut;
  List<DeviceSlotConfig?>? get slotConfigs => _deviceState?.slots;
  double? get closedLoopTarget => _deviceState?.lastData?.controlMode.target;
  double? get closedLoopError => _deviceState?.lastData?.controlMode.error;
  double? get closedLoopP => _deviceState?.lastData?.controlMode.pFactor;
  double? get closedLoopI => _deviceState?.lastData?.controlMode.iFactor;
  double? get closedLoopD => _deviceState?.lastData?.controlMode.dFactor;
  double? get closedLoopS => _deviceState?.lastData?.controlMode.sFactor;
  double? get closedLoopSubError =>
      _deviceState?.lastData?.controlMode.subError;
  double? get secsToCompletion =>
      _deviceState?.lastData?.controlMode.secsToCompletion;
  int? get closedLoopPhase => _deviceState?.lastData?.controlMode.phase;
  String? get closedLoopPhaseName =>
      _deviceState?.lastData?.controlMode.phaseName;
  int? get updatesPerSec => _deviceState?.updatesPerSec;
  String? get deviceName => _deviceState?.deviceName;
  String? get firmwareVersion => _deviceState?.firmwareVersion;

  void sendControlRequest(DeviceControlRequest req) {
    _deviceSend?.send(req);
  }

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
