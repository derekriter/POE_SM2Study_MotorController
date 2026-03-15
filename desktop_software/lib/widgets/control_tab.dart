import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final _logger = Logger();

class ControlTab extends StatefulWidget {
  const ControlTab({super.key});

  @override
  State<ControlTab> createState() => _ControlTabState();
}

class _ControlTabState extends State<ControlTab> {
  static const _defaultMode = DeviceControlMode.stop;

  final TextEditingController _modeController = TextEditingController();

  var _selectedMode = _defaultMode;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isReady) {
      return Center(child: OverflowText("Please connect a device to control"));
    }

    return Column(
      children: [
        DropdownMenu<DeviceControlMode>(
          initialSelection: _defaultMode,
          requestFocusOnTap: true,
          enableSearch: false,
          controller: _modeController,
          onSelected: (selected) {
            setState(() {
              _selectedMode = selected ?? _defaultMode;
            });
            _logger.d(selected);
          },
          dropdownMenuEntries: [
            const DropdownMenuEntry(
              value: DeviceControlMode.stop,
              label: "Stop",
            ),
            const DropdownMenuEntry(
              value: DeviceControlMode.dutyCycle,
              label: "Duty Cycle",
            ),
          ],
        ),
      ],
    );
  }
}
