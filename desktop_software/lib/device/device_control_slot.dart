enum KSMode {
  errorBased(0),
  velocityBased(1);

  final int id;

  const KSMode(this.id);

  static KSMode? fromID(int id) {
    if (id == errorBased.id) {
      return errorBased;
    } else if (id == velocityBased.id) {
      return velocityBased;
    }

    return null;
  }
}

class DeviceSlotConfig {
  double kP, kI, kD;
  double kF, kS, kV;
  KSMode kSMode;
  double vMax, aStart, aEnd;

  static final DeviceSlotConfig empty = DeviceSlotConfig(
    kP: 0,
    kI: 0,
    kD: 0,
    kF: 0,
    kS: 0,
    kSMode: KSMode.errorBased,
    kV: 0,
    vMax: 0,
    aStart: 0,
    aEnd: 0,
  );

  DeviceSlotConfig({
    required this.kP,
    required this.kI,
    required this.kD,
    required this.kF,
    required this.kS,
    required this.kSMode,
    required this.kV,
    required this.vMax,
    required this.aStart,
    required this.aEnd,
  });

  DeviceSlotConfig copy() {
    return DeviceSlotConfig(
      kP: kP,
      kI: kI,
      kD: kD,
      kF: kF,
      kS: kS,
      kSMode: kSMode,
      kV: kV,
      vMax: vMax,
      aStart: aStart,
      aEnd: aEnd,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceSlotConfig &&
        other.kP == kP &&
        other.kI == kI &&
        other.kD == kD &&
        other.kF == kF &&
        other.kS == kS &&
        other.kSMode == kSMode &&
        other.kV == kV &&
        other.vMax == vMax &&
        other.aStart == aStart &&
        other.aEnd == aEnd;
  }
}
