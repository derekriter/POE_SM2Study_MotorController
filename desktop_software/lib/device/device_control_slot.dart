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
  double kP, kI, kD, kS;
  KSMode kSMode;
  double vMax, aStart, aEnd;

  DeviceSlotConfig({
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
