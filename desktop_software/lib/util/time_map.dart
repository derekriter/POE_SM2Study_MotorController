import 'dart:collection';

import 'package:flutter/foundation.dart';

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
    return _internalMap.isNotEmpty && _internalMap.containsKey(time);
  }

  void setValueAtTime(int time, T value) {
    int? prevTime = _findTimeOfPreviousEntry(time);
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
    int? prevTime = _findTimeOfPreviousEntry(time);
    if (prevTime == null) return null;

    return _internalMap[prevTime];
  }

  Iterable<MapEntry<int, T>> getAllValueChanges() {
    return _internalMap.entries;
  }

  int getNumberOfChanges() {
    return _internalMap.length;
  }

  bool? isOldestValue(int time) {
    if (_internalMap.isEmpty) return null;

    final entry = _findTimeOfPreviousEntry(time);
    if (entry == null) return null;

    return entry == _internalMap.keys.elementAt(0);
  }

  int? _findTimeOfPreviousEntry(int time) {
    if (!hasValueAtTime(time)) return null;
    if (hasChangeAtTime(time)) return time;

    final keys = _internalMap.keys;

    if (time >= keys.last) return keys.last;

    //binary search for previous time
    int zoneStart = 0;
    int zoneEnd = _internalMap.length - 1;
    while (zoneStart <= zoneEnd) {
      int target = ((zoneStart + zoneEnd) / 2).truncate();

      int targetTime = keys.elementAt(target);
      int? nextTime = target >= _internalMap.length - 1
          ? null
          : keys.elementAt(target + 1);

      //don't need to check if the time is equal, because we have a check at the start of the function
      if (targetTime < time && (nextTime == null || time < nextTime)) {
        return targetTime;
      }

      if (targetTime < time) {
        //before given time, but the next event is not after the time
        zoneStart = target + 1;
      } else {
        //after given time
        zoneEnd = target - 1;
      }
    }

    //I don't think this should ever happen, its just for safety
    return null;
  }

  @override
  bool operator ==(Object other) {
    return other is TimeMap<T> && mapEquals(other._internalMap, _internalMap);
  }

  TimeMap<T> copy() {
    return TimeMap._fromSplay(SplayTreeMap.from(_internalMap));
  }
}
