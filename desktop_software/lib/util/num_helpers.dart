import 'dart:math';

import 'package:flutter/material.dart';

extension ToStringShort on num {
  ///NOTE: 0 <= maxPrecision <= 20 will be enforced
  String toMinimalString({int maxPrecision = 8}) {
    maxPrecision = maxPrecision.clamp(0, 20);

    if (this is int) {
      return toString();
    }

    late bool isInt = (truncate() - this).abs() < pow(10, -maxPrecision);
    //convert to an int if if possible to remove unneccessary decimals
    if (isInt) {
      return truncate().toString();
    }

    String trimmed = toStringAsFixed(maxPrecision);
    while (true) {
      final c = trimmed.characters.lastOrNull;
      if (c == null) {
        trimmed = "0";
        break;
      }

      if (c == ".") {
        trimmed = trimmed.substring(0, trimmed.length - 1);
        break;
      } else if (c == "0") {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      } else {
        break;
      }
    }
    return trimmed;
  }
}

extension RoundToNearest on num {
  num roundToNearest(num multiple) {
    return (this / multiple).round() * multiple;
  }

  num floorToNearset(num multiple) {
    return (this / multiple).floor() * multiple;
  }

  num ceilToNearest(num multiple) {
    return (this / multiple).ceil() * multiple;
  }

  num roundToPrecision(int precision) {
    return roundToNearest(pow(10, -precision));
  }

  num floorToPrecision(int precision) {
    return floorToNearset(pow(10, -precision));
  }

  num ceilToPrecision(int precision) {
    return ceilToNearest(pow(10, -precision));
  }
}
