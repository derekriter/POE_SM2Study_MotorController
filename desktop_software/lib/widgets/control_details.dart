import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';

abstract class ControlDetails extends StatelessWidget {
  const ControlDetails({super.key});

  DeviceControlRequest generateRequest();
}

class StopDetails extends ControlDetails {
  // ignore: unused_element_parameter
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
  final VoidCallback _onChange;
  double _duty = 0;

  // ignore: unused_element_parameter
  DutyCycleDetails({required VoidCallback onChange, super.key})
    : _onChange = onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText("Duty Out:", style: theme.textTheme.labelLarge),
                _OutputSlider(
                  min: -1,
                  max: 1,
                  onChangeEnd: (double newDutyOut) {
                    _duty = newDutyOut;
                    _onChange();
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

class _OutputSlider extends StatefulWidget {
  final double min, max;
  final void Function(double) onChangeEnd;

  const _OutputSlider({
    required this.min,
    required this.max,
    required this.onChangeEnd,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  State<_OutputSlider> createState() => _OutputSliderState();
}

class _OutputSliderState extends State<_OutputSlider> {
  double _currentVal = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Slider(
            value: _currentVal,
            min: widget.min,
            max: widget.max,
            onChanged: (double? newVal) {
              setState(() {
                _currentVal = newVal ?? 0;
              });
            },
            onChangeEnd: widget.onChangeEnd,
          ),
        ),
        const SizedBox(width: 100, child: TextField()),
      ],
    );
  }
}
