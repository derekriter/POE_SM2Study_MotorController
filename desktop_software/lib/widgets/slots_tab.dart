import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/slot_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';

final _logger = Logger();

class SlotsTab extends StatefulWidget {
  const SlotsTab({super.key});

  @override
  State<SlotsTab> createState() => _SlotsTabState();
}

class _SlotsTabState extends State<SlotsTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedSlot = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isReady = context.select((AppState appState) => appState.isReady);

    if (!isReady) {
      return const Center(
        child: OverflowText("Please connect a device to configure"),
      );
    }

    _SlotSettings settings = _SlotSettings(_selectedSlot);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SlotSelector(
              onChangeEnd: (int newSlot) {
                setState(() {
                  _selectedSlot = newSlot;
                });
              },
            ),
          ),
          const Divider(indent: 0, endIndent: 0, radius: null),
          Expanded(child: SingleChildScrollView(child: settings)),
          const Divider(indent: 0, endIndent: 0, radius: null),
          FilledButton(
            onPressed: () {
              final appStateRead = context.read<AppState>();

              appStateRead.sendControlRequest(
                DeviceSlotConfigRequest(
                  _selectedSlot,
                  _SlotSettings.of(context)?.generateConfig() ??
                      DeviceSlotConfig.empty,
                ),
              );
              appStateRead.sendControlRequest(
                DeviceGetSlotRequest(_selectedSlot),
              );
            },
            child: const OverflowText("Update"),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SlotSettings extends StatefulWidget {
  final int slotId;

  // ignore: unused_element_parameter
  const _SlotSettings(this.slotId, {super.key});

  @override
  State<_SlotSettings> createState() => _SlotSettingsState();

  //https://stackoverflow.com/a/49825756
  static _SlotSettingsState? of(BuildContext context) =>
      context.findAncestorStateOfType();
}

class _SlotSettingsState extends State<_SlotSettings> {
  DeviceSlotConfig? _workingConfig;

  @override
  Widget build(BuildContext context) {
    final config = context.select(
      (AppState appState) => appState.slotConfigs?[widget.slotId],
    );

    if (config == null) {
      return const Center(
        child: OverflowText("Missing configuration, please connect a device"),
      );
    }
    _workingConfig = config.copy();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText("kP:", style: theme.textTheme.labelLarge),
                _ConfigNumberField(
                  initialVal: _workingConfig!.kP,
                  onChangeEnd: (double newKP) {
                    setState(() {
                      _workingConfig?.kP = newKP;
                    });
                  },
                ),
                const SizedBox(height: 8),
                OverflowText("kI:", style: theme.textTheme.labelLarge),
                _ConfigNumberField(
                  initialVal: _workingConfig!.kI,
                  onChangeEnd: (double newKI) {
                    setState(() {
                      _workingConfig?.kI = newKI;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DeviceSlotConfig generateConfig() {
    return _workingConfig ?? DeviceSlotConfig.empty;
  }
}

class _ConfigNumberField extends StatefulWidget {
  final double initialVal;
  final void Function(double) onChangeEnd;

  const _ConfigNumberField({
    required this.initialVal,
    required this.onChangeEnd,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  State<_ConfigNumberField> createState() => _ConfigNumberFieldState();
}

class _ConfigNumberFieldState extends State<_ConfigNumberField> {
  final TextEditingController _textController = TextEditingController();
  final _focusNode = FocusNode();

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();

    _currentVal = widget.initialVal;
    _textController.text = (_currentVal.floorToDouble() == _currentVal)
        ? _currentVal.floor().toString()
        : _currentVal.toString();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _onTextSubmitted(_textController.text);
      }

      _textController.text = (_currentVal.floorToDouble() == _currentVal)
          ? _currentVal.floor().toString()
          : _currentVal.toString();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // @override
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
    var val = double.tryParse(text);
    if (val == null) {
      val = 0;
      _textController.text = "0";
    }

    setState(() {
      _currentVal = val!;
    });
    widget.onChangeEnd(val);
  }
}
