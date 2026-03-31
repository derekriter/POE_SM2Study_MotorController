import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_loop.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:desktop_software/util/time_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

class AppState with ChangeNotifier {
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

  //connection data
  bool get isConnected => _deviceState?.isConnected ?? false;
  bool get isReady => _deviceState?.isReady ?? false;
  String? get port => _deviceState?.port;

  //device data
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
  double? get target => _deviceState?.lastData?.controlMode.target;
  double? get error => _deviceState?.lastData?.controlMode.error;
  double? get pFactor => _deviceState?.lastData?.controlMode.pFactor;
  double? get iFactor => _deviceState?.lastData?.controlMode.iFactor;
  double? get dFactor => _deviceState?.lastData?.controlMode.dFactor;
  double? get sFactor => _deviceState?.lastData?.controlMode.sFactor;
  int? get slot => _deviceState?.lastData?.controlMode.slot;
  double? get subError => _deviceState?.lastData?.controlMode.subError;
  double? get secsToCompletion =>
      _deviceState?.lastData?.controlMode.secsToCompletion;
  int? get phase => _deviceState?.lastData?.controlMode.phase;
  String? get phaseName => _deviceState?.lastData?.controlMode.phaseName;
  int? get updatesPerSec => _deviceState?.updatesPerSec;
  String? get deviceName => _deviceState?.deviceName;
  String? get firmwareVersion => _deviceState?.firmwareVersion;

  //timed device data
  TimeMap<bool?>? get enabledTimeMap => _deviceState?.enabledMap;
  TimeMap<double?>? get sourceVoltageTimeMap => _deviceState?.sourceVoltageMap;
  TimeMap<double?>? get positionTimeMap => _deviceState?.positionMap;
  TimeMap<double?>? get velocityTimeMap => _deviceState?.velocityMap;
  TimeMap<DeviceControlMode?>? get controlModeTimeMap =>
      _deviceState?.controlModeMap;
  TimeMap<double?>? get dutyOutTimeMap => _deviceState?.dutyOutMap;
  TimeMap<double?>? get voltageOutTimeMap => _deviceState?.voltageOutMap;
  TimeMap<double?>? get targetTimeMap => _deviceState?.targetMap;
  TimeMap<double?>? get errorTimeMap => _deviceState?.errorMap;
  TimeMap<double?>? get pFactorTimeMap => _deviceState?.pFactorMap;
  TimeMap<double?>? get iFactorTimeMap => _deviceState?.iFactorMap;
  TimeMap<double?>? get dFactorTimeMap => _deviceState?.dFactorMap;
  TimeMap<double?>? get sFactorTimeMap => _deviceState?.sFactorMap;
  TimeMap<int?>? get slotTimeMap => _deviceState?.slotMap;
  TimeMap<double?>? get subErrorTimeMap => _deviceState?.subErrorMap;
  TimeMap<double?>? get secsToCompletionTimeMap =>
      _deviceState?.secsToCompletionMap;
  TimeMap<String?>? get phaseNameTimeMap => _deviceState?.phaseNameMap;

  void sendControlRequest(DeviceControlRequest req) {
    _deviceSend?.send(req);
  }

  late final ReceivePort _deviceReceive;
  Isolate? _deviceIsolate;
  SendPort? _deviceSend;
  Completer<void>? _deviceClosed;

  DeviceState? _deviceState;

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
