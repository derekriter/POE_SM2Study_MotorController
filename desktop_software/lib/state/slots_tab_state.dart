import 'package:desktop_software/device/device_control_slot.dart';
import 'package:flutter/material.dart';

class SlotsTabState with ChangeNotifier {
  List<DeviceSlotConfig?>? _workingConfigs;

  SlotsTabState({required List<DeviceSlotConfig?>? workingConfigs})
    : _workingConfigs = workingConfigs == null
          ? null
          : List.generate(
              6,
              (int i) => workingConfigs[i]?.copy(),
              growable: false,
            );

  DeviceSlotConfig? getWorkingConfig(int slot) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null) return null;
    return _workingConfigs![slot];
  }

  double? getWorkingKP(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.kP;
  }

  double? getWorkingKI(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.kI;
  }

  double? getWorkingKD(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.kD;
  }

  double? getWorkingKS(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.kS;
  }

  KSMode? getWorkingKSMode(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.kSMode;
  }

  double? getWorkingVMax(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.vMax;
  }

  double? getWorkingAStart(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.aStart;
  }

  double? getWorkingAEnd(int slot) {
    assert(slot >= 0 && slot < 6);

    return _workingConfigs?.elementAt(slot)?.aEnd;
  }

  void _setWorkingConfigAdv(int slot, DeviceSlotConfig? config, bool notify) {
    assert(slot >= 0);

    _workingConfigs ??= List.generate(6, (_) => null, growable: false);
    _workingConfigs![slot] = config;

    if (notify) notifyListeners();
  }

  void setWorkingConfig(int slot, DeviceSlotConfig? config) {
    _setWorkingConfigAdv(slot, config, true);
  }

  void setWorkingKP(int slot, double kP) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.kP = kP;

    notifyListeners();
  }

  void setWorkingKI(int slot, double kI) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.kI = kI;

    notifyListeners();
  }

  void setWorkingKD(int slot, double kD) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.kD = kD;

    notifyListeners();
  }

  void setWorkingKS(int slot, double kS) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.kS = kS;

    notifyListeners();
  }

  void setWorkingKSMode(int slot, KSMode kSMode) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.kSMode = kSMode;

    notifyListeners();
  }

  void setWorkingVMax(int slot, double vMax) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.vMax = vMax;

    notifyListeners();
  }

  void setWorkingAStart(int slot, double aStart) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.aStart = aStart;

    notifyListeners();
  }

  void setWorkingAEnd(int slot, double aEnd) {
    assert(slot >= 0 && slot < 6);

    if (_workingConfigs == null || _workingConfigs![slot] == null) {
      _setWorkingConfigAdv(slot, DeviceSlotConfig.empty.copy(), false);
    }
    _workingConfigs![slot]!.aEnd = aEnd;

    notifyListeners();
  }
}
