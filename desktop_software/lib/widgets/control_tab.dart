import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlTab extends StatefulWidget {
  const ControlTab({super.key});

  @override
  State<ControlTab> createState() => _ControlTabState();
}

//https://hemant-aws-devops.medium.com/day-28-how-to-preserve-tab-state-when-switching-tabs-in-flutter-with-our-noted-app-15906841a957
class _ControlTabState extends State<ControlTab>
    with AutomaticKeepAliveClientMixin {
  DeviceControlMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    super.build(context); //required by AutomaticKeepAliveClientMixin

    final appStateRead = context.read<AppState>();
    final isReady = context.select((AppState appState) => appState.isReady);

    _selectedMode ??= appStateRead.controlMode;
    if (_selectedMode == DeviceControlMode.disabled) {
      _selectedMode = DeviceControlMode.stop;
    }

    if (!isReady) {
      return const Center(
        child: OverflowText("Please connect a device to control"),
      );
    }

    late final Widget details;
    switch (_selectedMode) {
      case null:
      case DeviceControlMode.disabled:
      case DeviceControlMode.stop:
        {
          details = const _StopDetails();
        }
      case DeviceControlMode.dutyCycle:
        {
          details = const _DutyCycleDetails();
        }
      default:
        {
          details = const Placeholder(child: OverflowText("WIP"));
        }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ModeDropdown(
                    initialVal: _selectedMode,
                    onSelected: (DeviceControlMode? newVal) {
                      setState(() {
                        _selectedMode = newVal;

                        //disable motor for safety reasons
                        if (appStateRead.enabled ?? true) {
                          appStateRead.sendControlRequest(
                            DeviceEnableDisableRequest(false),
                          );
                        }
                        if (_selectedMode == DeviceControlMode.stop) {
                          appStateRead.sendControlRequest(DeviceStopRequest());
                        }
                      });
                    },
                  ),
                ),
                const Expanded(child: _EnabledButton()),
              ],
            ),
          ),
          const Divider(indent: 0, endIndent: 0, radius: null),
          details,
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ModeDropdown extends StatelessWidget {
  final Function(DeviceControlMode? newVal) onSelected;
  final DeviceControlMode? initialVal;

  const _ModeDropdown({
    required this.onSelected,
    required this.initialVal,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<DeviceControlMode>(
      initialSelection: initialVal,
      selectOnly: true,
      onSelected: onSelected,
      expandedInsets: EdgeInsets.zero, //force menu to fill space available
      dropdownMenuEntries: DeviceControlMode.asDropdownEntries(),
    );
  }
}

class _EnabledButton extends StatelessWidget {
  // ignore: unused_element_parameter
  const _EnabledButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();
    final enabled =
        context.select((AppState appState) => appState.enabled) ?? false;

    final theme = Theme.of(context);

    return FilledButton(
      onPressed: () {
        appStateRead.sendControlRequest(DeviceEnableDisableRequest(!enabled));
      },
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(4),
        ),
        backgroundColor: enabled ? Colors.green : Colors.red,
        foregroundColor: enabled ? null : theme.colorScheme.onError,
      ),
      child: OverflowText(enabled ? "Enabled" : "Disabled"),
    );
  }
}

class _StopDetails extends StatelessWidget {
  // ignore: unused_element_parameter
  const _StopDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverflowText("No controls available");
  }
}

class _DutyCycleDetails extends StatefulWidget {
  // ignore: unused_element_parameter
  const _DutyCycleDetails({super.key});

  @override
  State<_DutyCycleDetails> createState() => _DutyCycleDetailsState();
}

class _DutyCycleDetailsState extends State<_DutyCycleDetails> {
  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();

    return Column(
      children: [
        _OutputSlider(
          min: -1,
          max: 1,
          onChangeEnd: (double newDutyOut) {
            appStateRead.sendControlRequest(DeviceDutyCycleRequest(newDutyOut));
          },
        ),
      ],
    );
  }
}

class _OutputSlider extends StatefulWidget {
  final double min, max;
  final void Function(double) onChangeEnd;

  // ignore: unused_element_parameter
  const _OutputSlider({
    required this.min,
    required this.max,
    required this.onChangeEnd,
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
