import 'dart:math';

extension ToStringShort on double {
  String toMinimizedString({int? maxPrecision}) {
    late bool isInt;
    if (maxPrecision == null) {
      isInt = (truncateToDouble() - this).abs() < pow(10, -20);
    } else {
      isInt = (truncateToDouble() - this).abs() < pow(10, -maxPrecision);
    }

    //convert to an int if if possible to remove uneccessary decimals
    if (isInt) {
      return truncate().toString();
    }

    if (maxPrecision == null) {
      return toString();
    }

    return toStringAsFixed(maxPrecision);
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
