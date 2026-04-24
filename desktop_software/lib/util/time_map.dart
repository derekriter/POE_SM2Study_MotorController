import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

///Tracks changing data over time in a memory-efficient manner
class TimeMap<T> {
  final SplayTreeMap<int, T> _internalMap;

  TimeMap() : _internalMap = SplayTreeMap();
  TimeMap._fromSplay(SplayTreeMap<int, T> map) : _internalMap = map;

  void clear() {
    _internalMap.clear();
  }

  bool hasValueAtTime(int time) {
    return _internalMap.isNotEmpty && _internalMap.keys.first <= time;
  }

  bool hasChangeAtTime(int time) {
    return _internalMap.isNotEmpty && _internalMap[time] != null;
  }

  void setValueAtTime(int time, T value) {
    int? prevTime = findTimeOfPreviousEntry(time);
    if (prevTime == null) {
      _internalMap[time] = value;
    } else {
      T? prevVal = _internalMap[prevTime];
      // assert(prevVal != null);

      if (prevVal != value) {
        _internalMap[time] = value;
      }
    }
  }

  T? getValueAtTime(int time) {
    int? prevTime = findTimeOfPreviousEntry(time);
    if (prevTime == null) return null;

    return _internalMap[prevTime];
  }

  Iterable<MapEntry<int, T>> getAllValueChanges() {
    return _internalMap.entries;
  }

  Iterable<T?> getAllValuesInRange(int minT, int maxT) {
    if (_internalMap.isEmpty) {
      return Iterable.empty();
    }
    if (maxT < minT) {
      _logger.w("Attempted to get negative range of values from TimeMap");
      return Iterable.empty();
    }
    if (maxT == minT) {
      int? t = findTimeOfPreviousEntry(minT);
      return t == null
          ? Iterable.empty()
          : List.of([_internalMap[t]], growable: false);
    }

    int? firstTime = findTimeOfPreviousEntry(minT);
    return _internalMap.entries
        .where(
          (e) => e.key <= maxT && (firstTime == null || e.key >= firstTime),
        )
        .map((e) => e.value);
  }

  int getNumberOfChanges() {
    return _internalMap.length;
  }

  bool? isOldestValue(int time) {
    if (_internalMap.isEmpty) return null;

    final entry = findTimeOfPreviousEntry(time);
    if (entry == null) return null;

    return entry == _internalMap.firstKey();
  }

  void removeOldestEntry() {
    if (_internalMap.isEmpty) return;

    _internalMap.remove(_internalMap.keys.first);
  }

  // int? _findIndexOfPreviousEntry(int time) {
  //   if (!hasValueAtTime(time)) return null;

  //   final keys = _internalMap.keys.toList(growable: false);
  //   if (hasChangeAtTime(time)) return keys.indexOf(time);

  //   if (time >= keys[keys.length - 1]) return keys.length - 1;

  //   //binary search for previous time
  //   int zoneStart = 0;
  //   int zoneEnd = _internalMap.length - 1;
  //   while (zoneStart <= zoneEnd) {
  //     int target = ((zoneStart + zoneEnd) / 2).truncate();

  //     int targetTime = keys[target];
  //     int? nextTime = target >= _internalMap.length - 1
  //         ? null
  //         : keys[target + 1];

  //     //don't need to check if the time is equal, because we have a check at the start of the function
  //     if (targetTime < time && (nextTime == null || time < nextTime)) {
  //       return target;
  //     }

  //     if (targetTime < time) {
  //       //before given time, but the next event is not after the time
  //       zoneStart = target + 1;
  //     } else {
  //       //after given time
  //       zoneEnd = target - 1;
  //     }
  //   }

  //   //I don't think this should ever happen, its just for safety
  //   return null;
  // }

  int? findTimeOfPreviousEntry(int time) {
    if (!hasValueAtTime(time)) return null;
    if (hasChangeAtTime(time)) return time;

    return _internalMap.lastKeyBefore(time);

    // int? i = _findIndexOfPreviousEntry(time);
    // return i == null ? null : _internalMap.keys.elementAtOrNull(i);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeMap<T> && mapEquals(other._internalMap, _internalMap);
  }

  TimeMap<T> copy() {
    return TimeMap._fromSplay(SplayTreeMap.from(_internalMap));
  }
}
