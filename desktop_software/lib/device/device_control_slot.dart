enum KSMode { errorBased, velocityBased }

class DeviceControlSlotConfig {
  double kP, kI, kD, kS;
  KSMode kSMode;
  double vMax, aStart, aEnd;

  DeviceControlSlotConfig({
    required this.kP,
    required this.kI,
    required this.kD,
    required this.kS,
    required this.kSMode,
    required this.vMax,
    required this.aStart,
    required this.aEnd,
  });
}
