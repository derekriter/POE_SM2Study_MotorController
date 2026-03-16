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
    final isReady = context.select((AppState appState) => appState.isReady);

    if (!isReady) {
      return const Center(
        child: OverflowText("Please connect a device to control"),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Column(
        children: [
          DropdownMenu<DeviceControlMode>(
            initialSelection: _defaultMode,
            enableSearch: false,
            controller: _modeController,
            width: double.maxFinite,
            onSelected: (DeviceControlMode? selected) {
              setState(() {
                _selectedMode = selected ?? _defaultMode;
              });
              _logger.d(selected);
            },
            dropdownMenuEntries: DeviceControlMode.asDropdownEntries(),
          ),
          OverflowText(_selectedMode.name),
        ],
      ),
    );
  }
}
