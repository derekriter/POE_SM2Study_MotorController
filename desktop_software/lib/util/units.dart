import 'package:flutter/foundation.dart';

abstract class Unit<T> {
  T value;

  Unit(this.value);

  String applySuffix(String str);
  Unit<T> copy();

  @override
  @nonVirtual
  bool operator ==(Object other) {
    return other is Unit<T> && other.value == value;
  }
}

class Volts<T extends num> extends Unit<T> {
  Volts(super.value);

  //unfortunately, dart has no way of enforcing this with inheritance or generics, so it has to be manually implemented for each unit
  static Volts<T>? nullable<T extends num>(T? value) {
    return value == null ? null : Volts(value);
  }

  @override
  String applySuffix(String str) {
    return "$str V";
  }

  @override
  Volts<T> copy() {
    return Volts(value);
  }
}

class Rotations<T extends num> extends Unit<T> {
  Rotations(super.value);

  static Rotations<T>? nullable<T extends num>(T? value) {
    return value == null ? null : Rotations(value);
  }

  @override
  String applySuffix(String str) {
    return "$str rots";
  }

  @override
  Rotations<T> copy() {
    return Rotations(value);
  }
}

class RPM<T extends num> extends Unit<T> {
  RPM(super.value);

  static RPM<T>? nullable<T extends num>(T? value) {
    return value == null ? null : RPM(value);
  }

  @override
  String applySuffix(String str) {
    return "$str rpm";
  }

  @override
  RPM<T> copy() {
    return RPM(value);
  }
}

class Seconds<T extends num> extends Unit<T> {
  Seconds(super.value);

  static Seconds<T>? nullable<T extends num>(T? value) {
    return value == null ? null : Seconds(value);
  }

  @override
  String applySuffix(String str) {
    return "$str s";
  }

  @override
  Seconds<T> copy() {
    return Seconds(value);
  }
}

class Milliseconds<T extends num> extends Unit<T> {
  Milliseconds(super.value);

  static Milliseconds<T>? nullable<T extends num>(T? value) {
    return value == null ? null : Milliseconds(value);
  }

  @override
  String applySuffix(String str) {
    return "$str ms";
  }

  @override
  Milliseconds<T> copy() {
    return Milliseconds(value);
  }
}

class UnknownUnit<T> extends Unit<T> {
  UnknownUnit(super.value);

  static UnknownUnit<T>? nullable<T extends num>(T? value) {
    return value == null ? null : UnknownUnit(value);
  }

  @override
  String applySuffix(String str) {
    return "$str uk";
  }

  @override
  UnknownUnit<T> copy() {
    return UnknownUnit(value);
  }
}

class Unitless<T> extends Unit<T> {
  Unitless(super.value);

  static Unitless<T>? nullable<T extends num>(T? value) {
    return value == null ? null : Unitless(value);
  }

  @override
  String applySuffix(String str) {
    return "$str ul";
  }

  @override
  Unitless<T> copy() {
    return Unitless(value);
  }
}
