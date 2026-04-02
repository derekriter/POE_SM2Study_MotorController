import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_frame.dart';
import 'package:desktop_software/device/device_loop.dart';
import 'package:desktop_software/device/device_state.dart';
import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/util/time_map.dart';
import 'package:desktop_software/util/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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

    enabledSrc = DiscreteBooleanSource(
      name: "enabled",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.enabledLive),
      getValueAtTimestamp: (timestamp) =>
          _enabledMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _enabledMap?.getAllValueChanges(),
      asString: (val) => val.toString(),
    );
    sourceVoltageSrc = ContinuousNumSource(
      name: "sourceVoltage",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.sourceVoltageLive),
      getValueAtTimestamp: (timestamp) =>
          _sourceVoltageMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _sourceVoltageMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(2)),
    );
    positionSrc = ContinuousNumSource(
      name: "position",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.positionLive),
      getValueAtTimestamp: (timestamp) =>
          _positionMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _positionMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(4)),
    );
    velocitySrc = ContinuousNumSource(
      name: "velocity",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.velocityLive),
      getValueAtTimestamp: (timestamp) =>
          _velocityMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _velocityMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(4)),
    );
    controlModeSrc = DiscreteControlModeSource(
      name: "controlMode",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.controlModeLive),
      getValueAtTimestamp: (timestamp) =>
          _controlModeMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _controlModeMap?.getAllValueChanges(),
      asString: (val) => val.name,
    );
    dutyOutSrc = ContinuousPercentageSource(
      name: "dutyOut",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.dutyOutLive),
      getValueAtTimestamp: (timestamp) =>
          _dutyOutMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _dutyOutMap?.getAllValueChanges(),
      watchCurrentPercentage: (context) =>
          context.select((AppState state) => state.dutyOutLive?.value),
      asString: (val) => val.value.toStringAsFixed(3),
    );
    voltageOutSrc = ContinuousPercentageSource(
      name: "voltageOut",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.voltageOutLive),
      getValueAtTimestamp: (timestamp) =>
          _voltageOutMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _voltageOutMap?.getAllValueChanges(),
      watchCurrentPercentage: (context) {
        final out = context
            .select((AppState state) => state.voltageOutLive)
            ?.value;
        final source = context
            .select((AppState state) => state.sourceVoltageLive)
            ?.value;

        if (out == null || source == null) return null;
        return source == 0 ? 0 : out / source;
      },
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(3)),
    );
    targetSrc = ContinuousNumSource(
      name: "target",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.targetLive),
      getValueAtTimestamp: (timestamp) => _targetMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _targetMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(4)),
    );
    errorSrc = ContinuousNumSource(
      name: "error",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.errorLive),
      getValueAtTimestamp: (timestamp) => _errorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _errorMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(4)),
    );
    pFactorSrc = ContinuousNumSource(
      name: "pFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.pFactorLive),
      getValueAtTimestamp: (timestamp) =>
          _pFactorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _pFactorMap?.getAllValueChanges(),
      asString: (val) => val.value.toStringAsFixed(3),
    );
    iFactorSrc = ContinuousNumSource(
      name: "iFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.iFactorLive),
      getValueAtTimestamp: (timestamp) =>
          _iFactorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _iFactorMap?.getAllValueChanges(),
      asString: (val) => val.value.toStringAsFixed(3),
    );
    dFactorSrc = ContinuousNumSource(
      name: "dFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.dFactorLive),
      getValueAtTimestamp: (timestamp) =>
          _dFactorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _dFactorMap?.getAllValueChanges(),
      asString: (val) => val.value.toStringAsFixed(3),
    );
    sFactorSrc = ContinuousNumSource(
      name: "sFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.sFactorLive),
      getValueAtTimestamp: (timestamp) =>
          _sFactorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _sFactorMap?.getAllValueChanges(),
      asString: (val) => val.value.toStringAsFixed(3),
    );
    slotSrc = DiscreteIntSource(
      name: "slot",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.slotLive),
      getValueAtTimestamp: (timestamp) => _slotMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _slotMap?.getAllValueChanges(),
      asString: (val) => val.value.toString(),
    );
    subErrorSrc = ContinuousNumSource(
      name: "subError",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.subErrorLive),
      getValueAtTimestamp: (timestamp) =>
          _subErrorMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _subErrorMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(4)),
    );
    secsToCompletionSrc = ContinuousValidatableNumSource(
      name: "secsToCompletion",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.secsToCompletionLive),
      getValueAtTimestamp: (timestamp) =>
          _secsToCompletionMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _secsToCompletionMap?.getAllValueChanges(),
      asString: (val) => val.applySuffix(val.value.toStringAsFixed(3)),
      isValid: (val) => val.value >= 0,
    );
    phaseNameSrc = DiscreteValidatableStringSource(
      name: "phaseName",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.phaseNameLive),
      getValueAtTimestamp: (timestamp) =>
          _phaseNameMap?.getValueAtTime(timestamp),
      getAllValueChanges: () => _phaseNameMap?.getAllValueChanges(),
      isValid: (val) => val != "completed" && val != "unknown",
    );
  }

  //connection data
  bool get isConnected => _deviceState?.isConnected ?? false;
  bool get isReady => _deviceState?.isReady ?? false;
  String? get port => _deviceState?.port;

  //basic device info
  String? get deviceName => _deviceState?.deviceName;
  String? get firmwareVersion => _deviceState?.firmwareVersion;
  int? get updatesPerSec => _deviceState?.updatesPerSec;
  Milliseconds<int>? get lastTimestamp => _deviceState?.lastData?.timestamp;

  //live device data
  bool? get enabledLive => _deviceState?.lastData?.enabled;
  Volts<double>? get sourceVoltageLive => _deviceState?.lastData?.sourceVoltage;
  Rotations<double>? get positionLive => _deviceState?.lastData?.position;
  RPM<double>? get velocityLive => _deviceState?.lastData?.velocity;
  DeviceControlMode? get controlModeLive =>
      _deviceState?.lastData?.controlMode.mode;
  Unitless<double>? get dutyOutLive =>
      _deviceState?.lastData?.controlMode.dutyOut;
  Volts<double>? get voltageOutLive =>
      _deviceState?.lastData?.controlMode.voltageOut;
  Unit<double>? get targetLive => _deviceState?.lastData?.controlMode.target;
  Unit<double>? get errorLive => _deviceState?.lastData?.controlMode.error;
  Unitless<double>? get pFactorLive =>
      _deviceState?.lastData?.controlMode.pFactor;
  Unitless<double>? get iFactorLive =>
      _deviceState?.lastData?.controlMode.iFactor;
  Unitless<double>? get dFactorLive =>
      _deviceState?.lastData?.controlMode.dFactor;
  Unitless<double>? get sFactorLive =>
      _deviceState?.lastData?.controlMode.sFactor;
  Unitless<int>? get slotLive => _deviceState?.lastData?.controlMode.slot;
  Unit<double>? get subErrorLive =>
      _deviceState?.lastData?.controlMode.subError;
  Seconds<double>? get secsToCompletionLive =>
      _deviceState?.lastData?.controlMode.secsToCompletion;
  String? get phaseNameLive =>
      (controlModeLive != null &&
          _deviceState?.lastData?.controlMode.phase != null)
      ? DeviceControlModeData.getPhaseName(
          controlModeLive!,
          _deviceState!.lastData!.controlMode.phase!,
        )
      : null;

  //live device configs
  List<DeviceSlotConfig?>? get slotConfigs => _deviceState?.slots;

  //device data sources
  late final DiscreteBooleanSource enabledSrc;
  late final ContinuousNumSource<Volts<double>> sourceVoltageSrc;
  late final ContinuousNumSource<Rotations<double>> positionSrc;
  late final ContinuousNumSource<RPM<double>> velocitySrc;
  late final DiscreteControlModeSource controlModeSrc;
  late final ContinuousPercentageSource<Unitless<double>> dutyOutSrc;
  late final ContinuousPercentageSource<Volts<double>> voltageOutSrc;
  late final ContinuousNumSource<Unit<double>> targetSrc;
  late final ContinuousNumSource<Unit<double>> errorSrc;
  late final ContinuousNumSource<Unitless<double>> pFactorSrc;
  late final ContinuousNumSource<Unitless<double>> iFactorSrc;
  late final ContinuousNumSource<Unitless<double>> dFactorSrc;
  late final ContinuousNumSource<Unitless<double>> sFactorSrc;
  late final DiscreteIntSource<Unitless<int>> slotSrc;
  late final ContinuousNumSource<Unit<double>> subErrorSrc;
  late final ContinuousValidatableNumSource<Seconds<double>>
  secsToCompletionSrc;
  late final DiscreteValidatableStringSource phaseNameSrc;

  void sendControlRequest(DeviceControlRequest req) {
    _deviceSend?.send(req);
  }

  late final ReceivePort _deviceReceive;
  Isolate? _deviceIsolate;
  SendPort? _deviceSend;
  Completer<void>? _deviceClosed;

  DeviceState? _deviceState;
  TimeMap<bool?>? _enabledMap;
  TimeMap<Volts<double>?>? _sourceVoltageMap;
  TimeMap<Rotations<double>?>? _positionMap;
  TimeMap<RPM<double>?>? _velocityMap;
  TimeMap<DeviceControlMode?>? _controlModeMap;
  TimeMap<Unitless<double>?>? _dutyOutMap;
  TimeMap<Volts<double>?>? _voltageOutMap;
  TimeMap<Unit<double>?>? _targetMap;
  TimeMap<Unit<double>?>? _errorMap;
  TimeMap<Unitless<double>?>? _pFactorMap;
  TimeMap<Unitless<double>?>? _iFactorMap;
  TimeMap<Unitless<double>?>? _dFactorMap;
  TimeMap<Unitless<double>?>? _sFactorMap;
  TimeMap<Unitless<int>?>? _slotMap;
  TimeMap<Unit<double>?>? _subErrorMap;
  TimeMap<Seconds<double>?>? _secsToCompletionMap;
  TimeMap<String?>? _phaseNameMap;

  //expire after 3 minutes, allows a theoretical maximum of 7200 entries per map
  static final Milliseconds<int> _dataExpirationTime = Milliseconds(
    3 * 60 * 1000,
  );

  void _onReceiveFromDevice(dynamic msg) {
    if (msg == null) {
      _deviceClosed?.complete();
    } else if (msg is SendPort) {
      _deviceSend = msg;
    } else if (msg is DeviceState) {
      if (!(_deviceState?.isConnected ?? false) && msg.isConnected) {
        //clear and setup timed data on device connection
        _resetTimedData();
      }

      _deviceState = msg;
      if (msg.lastData != null) {
        _updateTimedData(msg.lastData!);
      }
      notifyListeners();
    } else {
      _logger.w("Unknown message '$msg' received from device isolate");
    }
  }

  void _resetTimedData() {
    _enabledMap?.clear();
    _sourceVoltageMap?.clear();
    _positionMap?.clear();
    _velocityMap?.clear();
    _controlModeMap?.clear();
    _dutyOutMap?.clear();
    _voltageOutMap?.clear();
    _targetMap?.clear();
    _errorMap?.clear();
    _pFactorMap?.clear();
    _iFactorMap?.clear();
    _dFactorMap?.clear();
    _sFactorMap?.clear();
    _slotMap?.clear();
    _subErrorMap?.clear();
    _secsToCompletionMap?.clear();
    _phaseNameMap?.clear();

    _enabledMap ??= TimeMap();
    _sourceVoltageMap ??= TimeMap();
    _positionMap ??= TimeMap();
    _velocityMap ??= TimeMap();
    _controlModeMap ??= TimeMap();
    _dutyOutMap ??= TimeMap();
    _voltageOutMap ??= TimeMap();
    _targetMap ??= TimeMap();
    _errorMap ??= TimeMap();
    _pFactorMap ??= TimeMap();
    _iFactorMap ??= TimeMap();
    _dFactorMap ??= TimeMap();
    _sFactorMap ??= TimeMap();
    _slotMap ??= TimeMap();
    _subErrorMap ??= TimeMap();
    _secsToCompletionMap ??= TimeMap();
    _phaseNameMap ??= TimeMap();
  }

  void _updateTimedData(DeviceDataFrame frame) {
    if (_enabledMap != null) {
      _updateAndTrimTimeMap(_enabledMap!, frame.timestamp, frame.enabled);
    }
    if (_sourceVoltageMap != null) {
      _updateAndTrimTimeMap(
        _sourceVoltageMap!,
        frame.timestamp,
        frame.sourceVoltage,
      );
    }
    if (_positionMap != null) {
      _updateAndTrimTimeMap(_positionMap!, frame.timestamp, frame.position);
    }
    if (_velocityMap != null) {
      _updateAndTrimTimeMap(_velocityMap!, frame.timestamp, frame.velocity);
    }
    if (_controlModeMap != null) {
      _updateAndTrimTimeMap(
        _controlModeMap!,
        frame.timestamp,
        frame.controlMode.mode,
      );
    }
    if (_dutyOutMap != null) {
      _updateAndTrimTimeMap(
        _dutyOutMap!,
        frame.timestamp,
        frame.controlMode.dutyOut,
      );
    }
    if (_voltageOutMap != null) {
      _updateAndTrimTimeMap(
        _voltageOutMap!,
        frame.timestamp,
        frame.controlMode.voltageOut,
      );
    }
    if (_targetMap != null) {
      _updateAndTrimTimeMap(
        _targetMap!,
        frame.timestamp,
        frame.controlMode.target,
      );
    }
    if (_errorMap != null) {
      _updateAndTrimTimeMap(
        _errorMap!,
        frame.timestamp,
        frame.controlMode.error,
      );
    }
    if (_pFactorMap != null) {
      _updateAndTrimTimeMap(
        _pFactorMap!,
        frame.timestamp,
        frame.controlMode.pFactor,
      );
    }
    if (_iFactorMap != null) {
      _updateAndTrimTimeMap(
        _iFactorMap!,
        frame.timestamp,
        frame.controlMode.iFactor,
      );
    }
    if (_dFactorMap != null) {
      _updateAndTrimTimeMap(
        _dFactorMap!,
        frame.timestamp,
        frame.controlMode.dFactor,
      );
    }
    if (_sFactorMap != null) {
      _updateAndTrimTimeMap(
        _sFactorMap!,
        frame.timestamp,
        frame.controlMode.sFactor,
      );
    }
    if (_slotMap != null) {
      _updateAndTrimTimeMap(_slotMap!, frame.timestamp, frame.controlMode.slot);
    }
    if (_subErrorMap != null) {
      _updateAndTrimTimeMap(
        _subErrorMap!,
        frame.timestamp,
        frame.controlMode.subError,
      );
    }
    if (_secsToCompletionMap != null) {
      _updateAndTrimTimeMap(
        _secsToCompletionMap!,
        frame.timestamp,
        frame.controlMode.secsToCompletion,
      );
    }
    if (_phaseNameMap != null) {
      _updateAndTrimTimeMap(
        _phaseNameMap!,
        frame.timestamp,
        frame.controlMode.phase == null
            ? null
            : DeviceControlModeData.getPhaseName(
                frame.controlMode.mode,
                frame.controlMode.phase!,
              ),
      );
    }
  }

  void _updateAndTrimTimeMap<T>(
    TimeMap<T> map,
    Milliseconds<int> timestamp,
    T newVal,
  ) {
    map.setValueAtTime(timestamp.value, newVal);

    //remove any unneeded date older than the expiration time
    while (!(map.isOldestValue(timestamp.value - _dataExpirationTime.value) ??
        true)) {
      map.removeOldestEntry();
    }
  }
}
