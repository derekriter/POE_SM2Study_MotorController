import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/state/control_tab_state.dart';
import 'package:desktop_software/util/double_helpers.dart';
import 'package:desktop_software/widgets/number_field.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/slot_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class ControlDetails extends StatelessWidget {
  const ControlDetails({super.key});

  DeviceControlRequest generateRequest(BuildContext context);
}

class StopDetails extends ControlDetails {
  const StopDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverflowText("No controls available");
  }

  @override
  DeviceStopRequest generateRequest(BuildContext context) {
    return DeviceStopRequest();
  }
}

class DutyCycleDetails extends ControlDetails {
  final VoidCallback onConfirmed;

  const DutyCycleDetails({required this.onConfirmed, super.key});

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
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.duty,
                  ),
                  writeVal: (BuildContext context, double newDuty) {
                    context.read<ControlTabState>().duty = newDuty;
                  },
                  onConfirmed: (_) => onConfirmed(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceDutyCycleRequest generateRequest(BuildContext context) {
    final tabStateRead = context.read<ControlTabState>();

    return DeviceDutyCycleRequest(tabStateRead.duty);
  }
}

class VoltageDetails extends ControlDetails {
  final VoidCallback onConfirmed;

  const VoltageDetails({required this.onConfirmed, super.key});

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
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.voltage,
                  ),
                  writeVal: (BuildContext context, double newVoltage) {
                    context.read<ControlTabState>().voltage = newVoltage;
                  },
                  onConfirmed: (_) => onConfirmed(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceVoltageRequest generateRequest(BuildContext context) {
    final tabStateRead = context.read<ControlTabState>();

    return DeviceVoltageRequest(tabStateRead.voltage);
  }
}

class PIDPosDetails extends ControlDetails {
  final VoidCallback onConfirmed;

  const PIDPosDetails({required this.onConfirmed, super.key});

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
                _OutputDoubleField(
                  precision: 4,
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.pidPosTarget,
                  ),
                  writeVal: (BuildContext context, double newTarget) {
                    context.read<ControlTabState>().pidPosTarget = newTarget;
                  },
                  onConfirmed: (_) => onConfirmed(),
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
                ConsumerSlotSelector(
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.pidPosSlot,
                  ),
                  writeVal: (BuildContext context, int newSlot) {
                    context.read<ControlTabState>().pidPosSlot = newSlot;
                  },
                  onConfirmed: (_) => onConfirmed(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DevicePIDPositionRequest generateRequest(BuildContext context) {
    final tabStateRead = context.read<ControlTabState>();

    return DevicePIDPositionRequest(
      tabStateRead.pidPosTarget,
      tabStateRead.pidPosSlot,
    );
  }
}

class PIDVelDetails extends ControlDetails {
  final VoidCallback onConfirmed;

  const PIDVelDetails({required this.onConfirmed, super.key});

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
                _OutputDoubleField(
                  precision: 4,
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.pidVelTarget,
                  ),
                  writeVal: (BuildContext context, double newTarget) {
                    context.read<ControlTabState>().pidVelTarget = newTarget;
                  },
                  onConfirmed: (_) => onConfirmed(),
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
                ConsumerSlotSelector(
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.pidVelSlot,
                  ),
                  writeVal: (BuildContext context, int newSlot) {
                    context.read<ControlTabState>().pidVelSlot = newSlot;
                  },
                  onConfirmed: (_) => onConfirmed(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DevicePIDVelocityRequest generateRequest(BuildContext context) {
    final tabStateRead = context.read<ControlTabState>();

    return DevicePIDVelocityRequest(
      tabStateRead.pidVelTarget,
      tabStateRead.pidVelSlot,
    );
  }
}

class TrapPosDetails extends ControlDetails {
  final VoidCallback onConfirmed;

  const TrapPosDetails({required this.onConfirmed, super.key});

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
                _OutputDoubleField(
                  precision: 4,
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.trapPosTarget,
                  ),
                  writeVal: (BuildContext context, double newTarget) {
                    context.read<ControlTabState>().trapPosTarget = newTarget;
                  },
                  onConfirmed: (_) => onConfirmed(),
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
                ConsumerSlotSelector(
                  watchVal: (BuildContext context) => context.select(
                    (ControlTabState tabState) => tabState.trapPosSlot,
                  ),
                  writeVal: (BuildContext context, int newSlot) {
                    context.read<ControlTabState>().trapPosSlot = newSlot;
                  },
                  onConfirmed: (_) => onConfirmed(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  DeviceTrapezoidalMotionPositionRequest generateRequest(BuildContext context) {
    final tabStateRead = context.read<ControlTabState>();

    return DeviceTrapezoidalMotionPositionRequest(
      tabStateRead.trapPosTarget,
      tabStateRead.trapPosSlot,
    );
  }
}

class _OutputSlider extends StatelessWidget {
  final double min, max;
  final int precision;
  final double Function(BuildContext) watchVal;
  final void Function(BuildContext, double) writeVal;
  final void Function(double)? onConfirmed;

  const _OutputSlider({
    required this.min,
    required this.max,
    required this.precision,
    required this.watchVal,
    required this.writeVal,
    // ignore: unused_element_parameter
    this.onConfirmed,
    // ignore: unused_element_parameter
    super.key,
  }) : assert(precision >= 1),
       assert(min <= 0),
       assert(max >= 0);

  @override
  Widget build(BuildContext context) {
    final val = watchVal(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Slider(
            value: val,
            min: min,
            max: max,
            // divisions: precision >= 2
            //     ? null
            //     : pow(10, precision).toInt(),
            onChanged: (double? newVal) {
              newVal ??= 0;

              writeVal(context, newVal.roundToPrecision(precision));
            },
            onChangeEnd: onConfirmed,
          ),
        ),
        SizedBox(
          width: 100,
          child: _OutputDoubleField(
            min: min,
            max: max,
            precision: precision,
            watchVal: watchVal,
            writeVal: writeVal,
            onConfirmed: onConfirmed,
          ),
        ),
      ],
    );
  }
}

class _OutputDoubleField extends ConsumerDoubleField {
  const _OutputDoubleField({
    // ignore: unused_element_parameter
    super.min,
    // ignore: unused_element_parameter
    super.max,
    required super.precision,
    required super.watchVal,
    required super.writeVal,
    // ignore: unused_element_parameter
    super.onConfirmed,
  }) : super(defaultVal: 0, decoration: null);
}
