import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/state/control_tab_state.dart';
import 'package:desktop_software/widgets/control_details.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
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
  ControlDetails? _selectedDetails;

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

    _updateSelectedDetails();

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
                        _updateSelectedDetails();
                      });

                      //disable motor for safety reasons
                      if (appStateRead.enabled ?? true) {
                        appStateRead.sendControlRequest(
                          DeviceEnableDisableRequest(false),
                        );
                      }

                      final tabStateRead = context.read<ControlTabState>();
                      tabStateRead.resetOutputs();

                      _sendControlToDevice();
                    },
                  ),
                ),
                Expanded(
                  child: _EnabledButton(
                    onPress: (bool newState) {
                      _sendControlToDevice(); //just in case
                      appStateRead.sendControlRequest(
                        DeviceEnableDisableRequest(newState),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 0, endIndent: 0, radius: null),
          if (_selectedDetails == null)
            const Center(child: OverflowText("Something went wrong"))
          else
            Expanded(
              child: SmoothScroll(
                builder:
                    (
                      BuildContext _,
                      ScrollController controller,
                      ScrollPhysics physics,
                    ) => SingleChildScrollView(
                      controller: controller,
                      physics: physics,
                      child: _selectedDetails,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  void _updateSelectedDetails() {
    switch (_selectedMode) {
      case null:
      case DeviceControlMode.disabled:
      case DeviceControlMode.stop:
        {
          _selectedDetails = const StopDetails();
        }
      case DeviceControlMode.dutyCycle:
        {
          _selectedDetails = DutyCycleDetails(
            onConfirmed: _sendControlToDevice,
          );
        }
      case DeviceControlMode.voltage:
        {
          _selectedDetails = VoltageDetails(onConfirmed: _sendControlToDevice);
        }
      case DeviceControlMode.pidPos:
        {
          _selectedDetails = PIDPosDetails(onConfirmed: _sendControlToDevice);
        }
      case DeviceControlMode.pidVel:
        {
          _selectedDetails = PIDVelDetails(onConfirmed: _sendControlToDevice);
        }
      case DeviceControlMode.trapPos:
        {
          _selectedDetails = TrapPosDetails(onConfirmed: _sendControlToDevice);
        }
    }
  }

  void _sendControlToDevice() {
    final appStateRead = context.read<AppState>();

    appStateRead.sendControlRequest(
      _selectedDetails?.generateRequest(context) ?? const DeviceStopRequest(),
    );
  }
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
  final void Function(bool) onPress;

  // ignore: unused_element_parameter
  const _EnabledButton({required this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    final enabled =
        context.select((AppState appState) => appState.enabled) ?? false;

    final theme = Theme.of(context);

    return FilledButton(
      onPressed: () => onPress(!enabled),
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
