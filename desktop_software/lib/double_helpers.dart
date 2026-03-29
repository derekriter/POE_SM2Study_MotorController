import 'dart:math';

extension ToStringShort on double {
  String toStringShort() {
    //convert to an int if if possible to remove uneccessary decimals
    return floorToDouble() == this ? floor().toString() : toString();
  }
}

extension RoundToNearest on double {
  double roundToNearest(double multiple) {
    return (this / multiple).roundToDouble() * multiple;
  }

  double floorToNearset(double multiple) {
    return (this / multiple).floorToDouble() * multiple;
  }

  double ceilToNearest(double multiple) {
    return (this / multiple).ceilToDouble() * multiple;
  }

  double roundToPrecision(int precision) {
    return roundToNearest(pow(10, -precision).toDouble());
  }

  double floorToPrecision(int precision) {
    return floorToNearset(pow(10, -precision).toDouble());
  }

  double ceilToPrecision(int precision) {
    return ceilToNearest(pow(10, -precision).toDouble());
  }
}
