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

class _ControlTabState extends State<ControlTab> {
  DeviceControlMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
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
                      });
                    },
                  ),
                ),
                const Expanded(child: _EnabledButton()),
              ],
            ),
          ),
          OverflowText(_selectedMode?.name ?? "null"),
        ],
      ),
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
