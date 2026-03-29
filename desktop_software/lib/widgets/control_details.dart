import 'dart:math';

import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/double_helpers.dart';
import 'package:desktop_software/widgets/number_field.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/slot_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/web.dart';

abstract class ControlDetails extends StatelessWidget {
  const ControlDetails({super.key});

  DeviceControlRequest generateRequest();
}

class StopDetails extends ControlDetails {
  const StopDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverflowText("No controls available");
  }

  @override
  DeviceStopRequest generateRequest() {
    return const DeviceStopRequest();
  }
}

class DutyCycleDetails extends ControlDetails {
  final VoidCallback onChange;
  double _duty = 0;

  DutyCycleDetails({required this.onChange, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText("Duty Out:", style: theme.textTheme.labelLarge),
                _OutputSlider(
                  precision: 3,
                  min: -1,
                  max: 1,
                  onChangeEnd: (double newDutyOut) {
                    _duty = newDutyOut;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceDutyCycleRequest generateRequest() {
    return DeviceDutyCycleRequest(_duty);
  }
}

class VoltageDetails extends ControlDetails {
  final VoidCallback onChange;
  double _voltage = 0;

  VoltageDetails({required this.onChange, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText("Voltage Out:", style: theme.textTheme.labelLarge),
                _OutputSlider(
                  precision: 2,
                  min: -9,
                  max: 9,
                  onChangeEnd: (double newVoltage) {
                    _voltage = newVoltage;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceVoltageRequest generateRequest() {
    return DeviceVoltageRequest(_voltage);
  }
}

class PIDPosDetails extends ControlDetails {
  final VoidCallback onChange;
  double _target = 0;
  int _slot = 0;

  PIDPosDetails({required this.onChange, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText(
                  "Target Rotations:",
                  style: theme.textTheme.labelLarge,
                ),
                _OutputTextField(
                  precision: 4,
                  onChangeEnd: (double newTarget) {
                    _target = newTarget;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OverflowText("Slot:", style: theme.textTheme.labelLarge),
                SlotSelector(
                  onChangeEnd: (int newSlot) {
                    _slot = newSlot;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DevicePIDPositionRequest generateRequest() {
    return DevicePIDPositionRequest(_target, _slot);
  }
}

class PIDVelDetails extends ControlDetails {
  final VoidCallback onChange;
  double _target = 0;
  int _slot = 0;

  PIDVelDetails({required this.onChange, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText("Target RPM:", style: theme.textTheme.labelLarge),
                _OutputTextField(
                  precision: 4,
                  onChangeEnd: (double newTarget) {
                    _target = newTarget;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OverflowText("Slot:", style: theme.textTheme.labelLarge),
                SlotSelector(
                  onChangeEnd: (int newSlot) {
                    _slot = newSlot;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DevicePIDVelocityRequest generateRequest() {
    return DevicePIDVelocityRequest(_target, _slot);
  }
}

class TrapPosDetails extends ControlDetails {
  final VoidCallback onChange;
  double _target = 0;
  int _slot = 0;

  TrapPosDetails({required this.onChange, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText(
                  "Target Rotations:",
                  style: theme.textTheme.labelLarge,
                ),
                _OutputTextField(
                  precision: 4,
                  onChangeEnd: (double newTarget) {
                    _target = newTarget;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OverflowText("Slot:", style: theme.textTheme.labelLarge),
                SlotSelector(
                  onChangeEnd: (int newSlot) {
                    _slot = newSlot;
                    onChange();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceTrapezoidalMotionPositionRequest generateRequest() {
    return DeviceTrapezoidalMotionPositionRequest(_target, _slot);
  }
}

final _logger = Logger();

class _OutputSlider extends StatefulWidget {
  final double min, max;
  final int precision;
  final void Function(double) onChangeEnd;

  const _OutputSlider({
    required this.min,
    required this.max,
    required this.precision,
    required this.onChangeEnd,
    // ignore: unused_element_parameter
    super.key,
  }) : assert(precision >= 1),
       assert(min <= 0),
       assert(max >= 0);

  @override
  State<_OutputSlider> createState() => _OutputSliderState();
}

class _OutputSliderState extends State<_OutputSlider> {
  double _currentVal = 0;

  @override
  Widget build(BuildContext context) {
    _logger.d(_currentVal);

    final numField = DoubleField(
      defaultVal: 0,
      min: widget.min,
      max: widget.max,
      precision: widget.precision,
      onChangeEnd: (double newVal) {
        setState(() {
          _currentVal = newVal;
        });
      },
    );
    final slider = Slider(
      value: _currentVal,
      min: widget.min,
      max: widget.max,
      // divisions: widget.precision >= 2
      //     ? null
      //     : pow(10, widget.precision).toInt(),
      onChanged: (double? newVal) {
        setState(() {
          _currentVal = newVal?.roundToPrecision(widget.precision) ?? 0;
          numField.setValue(context, _currentVal, notify: false);
        });
      },
      onChangeEnd: widget.onChangeEnd,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: slider),
        SizedBox(width: 100, child: numField),
      ],
    );
  }
}

class _OutputTextField extends DoubleField {
  const _OutputTextField({
    // ignore: unused_element_parameter
    super.min,
    // ignore: unused_element_parameter
    super.max,
    required super.precision,
    required super.onChangeEnd,
  }) : super(defaultVal: 0, decoration: null);
}
