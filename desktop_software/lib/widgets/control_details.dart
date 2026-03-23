import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                _SlotSelector(
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
                _SlotSelector(
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
                _SlotSelector(
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
  final TextEditingController _textController = TextEditingController();
  FocusNode? _focusNode;

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();
    _textController.text = "0";

    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      if (!_focusNode!.hasFocus) {
        _onTextSubmitted(_textController.text);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

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
                _currentVal = ((newVal ?? 0) * 1000).roundToDouble() / 1000;
                _textController.text = _currentVal.toString();
              });
            },
            onChangeEnd: widget.onChangeEnd,
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            controller: _textController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
            ],
            onSubmitted: _onTextSubmitted,
            focusNode: _focusNode,
          ),
        ),
      ],
    );
  }

  void _onTextSubmitted(String text) {
    setState(() {
      var val = double.tryParse(text);
      if (val == null) {
        val = 0;
        _textController.text = "0";
      }
      if (val < widget.min || val > widget.max) {
        val = val.clamp(widget.min, widget.max);

        //convert val to an int if possible to remove unneccessary decimals
        _textController.text = (val.floorToDouble() == val)
            ? val.floor().toString()
            : val.toString();
      }

      _currentVal = val;
      widget.onChangeEnd(_currentVal);
    });
  }
}

class _OutputTextField extends StatefulWidget {
  final void Function(double) onChangeEnd;

  // ignore: unused_element_parameter
  const _OutputTextField({required this.onChangeEnd, super.key});

  @override
  State<_OutputTextField> createState() => _OutputTextFieldState();
}

class _OutputTextFieldState extends State<_OutputTextField> {
  final TextEditingController _textController = TextEditingController();
  FocusNode? _focusNode;

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();
    _textController.text = "0";

    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      if (!_focusNode!.hasFocus) {
        _onTextSubmitted(_textController.text);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      controller: _textController,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]"))],
      onSubmitted: _onTextSubmitted,
      focusNode: _focusNode,
    );
  }

  void _onTextSubmitted(String text) {
    setState(() {
      var val = double.tryParse(text);
      if (val == null) {
        val = 0;
        _textController.text = "0";
      }

      _currentVal = val;
      widget.onChangeEnd(_currentVal);
    });
  }
}

class _SlotSelector extends StatefulWidget {
  final void Function(int) onChangeEnd;

  const _SlotSelector({
    required this.onChangeEnd,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  State<_SlotSelector> createState() => _SlotSelectorState();
}

class _SlotSelectorState extends State<_SlotSelector> {
  int _selectedSlot = 0;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: OverflowText("0")),
        ButtonSegment(value: 1, label: OverflowText("1")),
        ButtonSegment(value: 2, label: OverflowText("2")),
        ButtonSegment(value: 3, label: OverflowText("3")),
        ButtonSegment(value: 4, label: OverflowText("4")),
        ButtonSegment(value: 5, label: OverflowText("5")),
      ],
      selected: {_selectedSlot},
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      onSelectionChanged: (Set<int> newSlot) {
        assert(newSlot.length == 1);

        setState(() {
          _selectedSlot = newSlot.elementAt(0);
        });
        widget.onChangeEnd(_selectedSlot);
      },
    );
  }
}
