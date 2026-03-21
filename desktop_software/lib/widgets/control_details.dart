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

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();
    _textController.text = "0";
  }

  @override
  void dispose() {
    _textController.dispose();
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
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _onTextSubmitted(_textController.text);
            },
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
