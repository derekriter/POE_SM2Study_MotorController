import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/device/device_frame.dart';
import 'package:desktop_software/util/time_map.dart';

class DeviceState {
  bool isConnected = false;
  bool isReady = false;
  String? port;
  DeviceDataFrame? lastData;
  List<DeviceSlotConfig?> slots;
  int? updatesPerSec;
  String? deviceName;
  String? firmwareVersion;

  TimeMap<bool?> enabledMap = TimeMap();
  TimeMap<double?> sourceVoltageMap = TimeMap();
  TimeMap<double?> positionMap = TimeMap();
  TimeMap<double?> velocityMap = TimeMap();
  TimeMap<DeviceControlMode?> controlModeMap = TimeMap();
  TimeMap<double?> dutyOutMap = TimeMap();
  TimeMap<double?> voltageOutMap = TimeMap();
  TimeMap<double?> targetMap = TimeMap();
  TimeMap<double?> errorMap = TimeMap();
  TimeMap<double?> pFactorMap = TimeMap();
  TimeMap<double?> iFactorMap = TimeMap();
  TimeMap<double?> dFactorMap = TimeMap();
  TimeMap<double?> sFactorMap = TimeMap();
  TimeMap<int?> slotMap = TimeMap();
  TimeMap<double?> subErrorMap = TimeMap();
  TimeMap<double?> secsToCompletionMap = TimeMap();
  TimeMap<String?> phaseNameMap = TimeMap();

  DeviceState() : slots = List.filled(6, null, growable: false);

  DeviceState copy() {
    return DeviceState()
      ..isConnected = isConnected
      ..isReady = isReady
      ..port = port
      ..lastData = lastData?.copy()
      ..slots = List.from(slots)
      ..updatesPerSec = updatesPerSec
      ..deviceName = deviceName
      ..firmwareVersion = firmwareVersion
      ..enabledMap = enabledMap.copy()
      ..sourceVoltageMap = sourceVoltageMap.copy()
      ..positionMap = positionMap.copy()
      ..velocityMap = velocityMap.copy()
      ..controlModeMap = controlModeMap.copy()
      ..dutyOutMap = dutyOutMap.copy()
      ..voltageOutMap = voltageOutMap.copy()
      ..targetMap = targetMap.copy()
      ..errorMap = errorMap.copy()
      ..pFactorMap = pFactorMap.copy()
      ..iFactorMap = iFactorMap.copy()
      ..dFactorMap = dFactorMap.copy()
      ..sFactorMap = sFactorMap.copy()
      ..slotMap = slotMap.copy()
      ..subErrorMap = subErrorMap.copy()
      ..secsToCompletionMap = secsToCompletionMap.copy()
      ..phaseNameMap = phaseNameMap.copy();
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceState &&
        other.isConnected == isConnected &&
        other.isReady == isReady &&
        other.port == port &&
        other.lastData == lastData &&
        other.slots == slots &&
        other.updatesPerSec == updatesPerSec &&
        other.deviceName == deviceName &&
        other.firmwareVersion == firmwareVersion &&
        other.enabledMap == enabledMap &&
        other.sourceVoltageMap == sourceVoltageMap &&
        other.positionMap == positionMap &&
        other.velocityMap == velocityMap &&
        other.controlModeMap == controlModeMap &&
        other.dutyOutMap == dutyOutMap &&
        other.voltageOutMap == voltageOutMap &&
        other.targetMap == targetMap &&
        other.errorMap == errorMap &&
        other.pFactorMap == pFactorMap &&
        other.iFactorMap == iFactorMap &&
        other.dFactorMap == dFactorMap &&
        other.sFactorMap == sFactorMap &&
        other.slotMap == slotMap &&
        other.subErrorMap == subErrorMap &&
        other.secsToCompletionMap == secsToCompletionMap &&
        other.phaseNameMap == phaseNameMap;
  }
}
