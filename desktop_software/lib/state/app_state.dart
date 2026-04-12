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
      getValueAtTimestamp: (t) => _enabledMap?.getValueAtTime(t),
      getAllValueChanges: () => _enabledMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _enabledMap?.getAllValuesInRange(minT, maxT),
      asString: (val) => val.toString(),
    );
    sourceVoltageSrc = ContinuousNumSource(
      name: "sourceVoltage",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.sourceVoltageLive),
      getValueAtTimestamp: (t) => _sourceVoltageMap?.getValueAtTime(t),
      getAllValueChanges: () => _sourceVoltageMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _sourceVoltageMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Volts<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(2));
      },
    );
    positionSrc = ContinuousNumSource(
      name: "position",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.positionLive),
      getValueAtTimestamp: (t) => _positionMap?.getValueAtTime(t),
      getAllValueChanges: () => _positionMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _positionMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Rotations<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(4));
      },
    );
    velocitySrc = ContinuousNumSource(
      name: "velocity",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.velocityLive),
      getValueAtTimestamp: (t) => _velocityMap?.getValueAtTime(t),
      getAllValueChanges: () => _velocityMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _velocityMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! RPM<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(4));
      },
    );
    controlModeSrc = DiscreteControlModeSource(
      name: "controlMode",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.controlModeLive),
      getValueAtTimestamp: (t) => _controlModeMap?.getValueAtTime(t),
      getAllValueChanges: () => _controlModeMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _controlModeMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! DeviceControlMode) return val.toString();

        return val.name;
      },
    );
    dutyOutSrc = ContinuousPercentageSource(
      name: "dutyOut",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.dutyOutLive),
      getValueAtTimestamp: (t) => _dutyOutMap?.getValueAtTime(t),
      getAllValueChanges: () => _dutyOutMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _dutyOutMap?.getAllValuesInRange(minT, maxT),
      watchCurrentPercentage: (context) =>
          context.select((AppState state) => state.dutyOutLive?.value),
      asString: (val) {
        if (val is! Unitless<double>) return val.toString();

        return val.value.toStringAsFixed(3);
      },
    );
    voltageOutSrc = ContinuousPercentageSource(
      name: "voltageOut",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.voltageOutLive),
      getValueAtTimestamp: (t) => _voltageOutMap?.getValueAtTime(t),
      getAllValueChanges: () => _voltageOutMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _voltageOutMap?.getAllValuesInRange(minT, maxT),
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
      asString: (val) {
        if (val is! Volts<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(3));
      },
    );
    targetSrc = ContinuousNumSource(
      name: "target",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.targetLive),
      getValueAtTimestamp: (t) => _targetMap?.getValueAtTime(t),
      getAllValueChanges: () => _targetMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _targetMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unit<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(4));
      },
    );
    errorSrc = ContinuousNumSource(
      name: "error",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.errorLive),
      getValueAtTimestamp: (t) => _errorMap?.getValueAtTime(t),
      getAllValueChanges: () => _errorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _errorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unit<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(4));
      },
    );
    pFactorSrc = ContinuousNumSource(
      name: "pFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.pFactorLive),
      getValueAtTimestamp: (t) => _pFactorMap?.getValueAtTime(t),
      getAllValueChanges: () => _pFactorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _pFactorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unitless<double>) return val.toString();

        return val.value.toStringAsFixed(3);
      },
    );
    iFactorSrc = ContinuousNumSource(
      name: "iFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.iFactorLive),
      getValueAtTimestamp: (t) => _iFactorMap?.getValueAtTime(t),
      getAllValueChanges: () => _iFactorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _iFactorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unitless<double>) return val.toString();

        return val.value.toStringAsFixed(3);
      },
    );
    dFactorSrc = ContinuousNumSource(
      name: "dFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.dFactorLive),
      getValueAtTimestamp: (t) => _dFactorMap?.getValueAtTime(t),
      getAllValueChanges: () => _dFactorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _dFactorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unitless<double>) return val.toString();

        return val.value.toStringAsFixed(3);
      },
    );
    sFactorSrc = ContinuousNumSource(
      name: "sFactor",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.sFactorLive),
      getValueAtTimestamp: (t) => _sFactorMap?.getValueAtTime(t),
      getAllValueChanges: () => _sFactorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _sFactorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unitless<double>) return val.toString();

        return val.value.toStringAsFixed(3);
      },
    );
    slotSrc = DiscreteIntSource(
      name: "slot",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.slotLive),
      getValueAtTimestamp: (t) => _slotMap?.getValueAtTime(t),
      getAllValueChanges: () => _slotMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _slotMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unitless<int>) return val.toString();

        return val.value.toString();
      },
    );
    subErrorSrc = ContinuousNumSource(
      name: "subError",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.subErrorLive),
      getValueAtTimestamp: (t) => _subErrorMap?.getValueAtTime(t),
      getAllValueChanges: () => _subErrorMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _subErrorMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Unit<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(4));
      },
    );
    secsToCompletionSrc = ContinuousValidatableNumSource(
      name: "secsToCompletion",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.secsToCompletionLive),
      getValueAtTimestamp: (t) => _secsToCompletionMap?.getValueAtTime(t),
      getAllValueChanges: () => _secsToCompletionMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _secsToCompletionMap?.getAllValuesInRange(minT, maxT),
      asString: (val) {
        if (val is! Seconds<double>) return val.toString();

        return val.applySuffix(val.value.toStringAsFixed(3));
      },
      isValid: (val) => val.value >= 0,
    );
    phaseNameSrc = DiscreteValidatableStringSource(
      name: "phaseName",
      watchCurrentValue: (context) =>
          context.select((AppState state) => state.phaseNameLive),
      getValueAtTimestamp: (t) => _phaseNameMap?.getValueAtTime(t),
      getAllValueChanges: () => _phaseNameMap?.getAllValueChanges(),
      getAllValuesInRange: (minT, maxT) =>
          _phaseNameMap?.getAllValuesInRange(minT, maxT),
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

  Milliseconds<int>? _pauseTime;
  Milliseconds<int>? get pauseTime => _pauseTime;
  void pause() {
    _pauseTime = _deviceState?.lastData?.timestamp;
    notifyListeners();
  }

  void resume() {
    _pauseTime = null;
    notifyListeners();
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

  //expire after 30 seconds, allows a theoretical maximum of 1200 entries per map
  static final Milliseconds<int> _dataExpirationTime = Milliseconds(30 * 1000);

  void _onReceiveFromDevice(dynamic msg) {
    if (msg == null) {
      _deviceClosed?.complete();
    } else if (msg is SendPort) {
      _deviceSend = msg;
    } else if (msg is DeviceState) {
      if (!(_deviceState?.isConnected ?? false) && msg.isConnected) {
        //clear and setup timed data on device connection
        _resetTimedData();
        _pauseTime = null;
      }
      if ((_deviceState?.isConnected ?? false) && !msg.isConnected) {
        _pauseTime ??= _deviceState?.lastData?.timestamp;
      }

      _deviceState = msg;
      if (msg.lastData != null) {
        _updateTimedData(msg.lastData!, _pauseTime != null);
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

  void _updateTimedData(DeviceDataFrame frame, bool paused) {
    if (_enabledMap != null) {
      _updateTimeMap(
        _enabledMap!,
        frame.timestamp,
        paused ? null : frame.enabled,
        !paused,
      );
    }
    if (_sourceVoltageMap != null) {
      _updateTimeMap(
        _sourceVoltageMap!,
        frame.timestamp,
        paused ? null : frame.sourceVoltage,
        !paused,
      );
    }
    if (_positionMap != null) {
      _updateTimeMap(
        _positionMap!,
        frame.timestamp,
        paused ? null : frame.position,
        !paused,
      );
    }
    if (_velocityMap != null) {
      _updateTimeMap(
        _velocityMap!,
        frame.timestamp,
        paused ? null : frame.velocity,
        !paused,
      );
    }
    if (_controlModeMap != null) {
      _updateTimeMap(
        _controlModeMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.mode,
        !paused,
      );
    }
    if (_dutyOutMap != null) {
      _updateTimeMap(
        _dutyOutMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.dutyOut,
        !paused,
      );
    }
    if (_voltageOutMap != null) {
      _updateTimeMap(
        _voltageOutMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.voltageOut,
        !paused,
      );
    }
    if (_targetMap != null) {
      _updateTimeMap(
        _targetMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.target,
        !paused,
      );
    }
    if (_errorMap != null) {
      _updateTimeMap(
        _errorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.error,
        !paused,
      );
    }
    if (_pFactorMap != null) {
      _updateTimeMap(
        _pFactorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.pFactor,
        !paused,
      );
    }
    if (_iFactorMap != null) {
      _updateTimeMap(
        _iFactorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.iFactor,
        !paused,
      );
    }
    if (_dFactorMap != null) {
      _updateTimeMap(
        _dFactorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.dFactor,
        !paused,
      );
    }
    if (_sFactorMap != null) {
      _updateTimeMap(
        _sFactorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.sFactor,
        !paused,
      );
    }
    if (_slotMap != null) {
      _updateTimeMap(
        _slotMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.slot,
        !paused,
      );
    }
    if (_subErrorMap != null) {
      _updateTimeMap(
        _subErrorMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.subError,
        !paused,
      );
    }
    if (_secsToCompletionMap != null) {
      _updateTimeMap(
        _secsToCompletionMap!,
        frame.timestamp,
        paused ? null : frame.controlMode.secsToCompletion,
        !paused,
      );
    }
    if (_phaseNameMap != null) {
      _updateTimeMap(
        _phaseNameMap!,
        frame.timestamp,
        paused
            ? null
            : (frame.controlMode.phase == null
                  ? null
                  : DeviceControlModeData.getPhaseName(
                      frame.controlMode.mode,
                      frame.controlMode.phase!,
                    )),
        !paused,
      );
    }
  }

  void _updateTimeMap<T>(
    TimeMap<T> map,
    Milliseconds<int> timestamp,
    T newVal,
    bool trim,
  ) {
    map.setValueAtTime(timestamp.value, newVal);

    //remove any unneeded data older than the expiration time
    while (trim &&
        !(map.isOldestValue(timestamp.value - _dataExpirationTime.value) ??
            true)) {
      map.removeOldestEntry();
    }
  }
}
