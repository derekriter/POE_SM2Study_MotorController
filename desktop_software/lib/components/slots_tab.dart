import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/device/device_control_request.dart';
import 'package:desktop_software/device/device_control_slot.dart';
import 'package:desktop_software/state/slots_tab_state.dart';
import 'package:desktop_software/widgets/number_field.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/slot_selector.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlotsTab extends StatefulWidget {
  const SlotsTab({super.key});

  @override
  State<SlotsTab> createState() => _SlotsTabState();
}

class _SlotsTabState extends State<SlotsTab>
    with AutomaticKeepAliveClientMixin {
  late final List<_SlotSettings> _settingsPages;

  int _selectedSlot = 0;

  @override
  void initState() {
    super.initState();

    _settingsPages = List.generate(
      6,
      (int i) => _SlotSettings(i),
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    assert(_selectedSlot >= 0 && _selectedSlot < 6);

    final isReady = context.select((AppState appState) => appState.isReady);

    if (!isReady) {
      return const Column(
        children: [
          _SlotChangeListener(0),
          _SlotChangeListener(1),
          _SlotChangeListener(2),
          _SlotChangeListener(3),
          _SlotChangeListener(4),
          _SlotChangeListener(5),
          Center(child: OverflowText("Please connect a device to configure")),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SlotChangeListener(0),
          const _SlotChangeListener(1),
          const _SlotChangeListener(2),
          const _SlotChangeListener(3),
          const _SlotChangeListener(4),
          const _SlotChangeListener(5),
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
                    child: _settingsPages[_selectedSlot],
                  ),
            ),
          ),
          const Divider(indent: 0, endIndent: 0, radius: null),
          FilledButton(
            onPressed: () {
              final appStateRead = context.read<AppState>();
              final tabStateRead = context.read<SlotsTabState>();

              appStateRead.sendControlRequest(
                DeviceSlotConfigRequest(
                  _selectedSlot,
                  tabStateRead.getWorkingConfig(_selectedSlot) ??
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

class _SlotChangeListener extends StatelessWidget {
  final int slotID;

  // ignore: unused_element_parameter
  const _SlotChangeListener(this.slotID, {super.key})
    : assert(slotID >= 0 && slotID < 6);

  @override
  Widget build(BuildContext context) {
    final deviceConfig = context.select(
      (AppState appState) => appState.slotConfigs?[slotID],
    );
    final tabStateRead = context.read<SlotsTabState>();

    Future.delayed(Duration(milliseconds: 1), () {
      tabStateRead.setWorkingConfig(slotID, deviceConfig?.copy());
    });

    return SizedBox.shrink();
  }
}

class _SlotSettings extends StatelessWidget {
  final int slotID;

  // ignore: unused_element_parameter
  const _SlotSettings(this.slotID, {super.key})
    : assert(slotID >= 0 && slotID < 6);

  @override
  Widget build(BuildContext context) {
    final config = context.select(
      (SlotsTabState tabState) => tabState.getWorkingConfig(slotID),
    );

    if (config == null) {
      return const Center(
        child: OverflowText("Missing configuration, please connect a device"),
      );
    }

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
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.kP,
                  precision: 8,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingKP(slotID) ??
                        DeviceSlotConfig.empty.kP,
                  ),
                  writeVal: (BuildContext context, double newKP) {
                    context.read<SlotsTabState>().setWorkingKP(slotID, newKP);
                  },
                ),
                const SizedBox(height: 8),
                OverflowText("kI:", style: theme.textTheme.labelLarge),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.kI,
                  precision: 8,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingKI(slotID) ??
                        DeviceSlotConfig.empty.kI,
                  ),
                  writeVal: (BuildContext context, double newKI) {
                    context.read<SlotsTabState>().setWorkingKI(slotID, newKI);
                  },
                ),
                const SizedBox(height: 8),
                OverflowText("kD:", style: theme.textTheme.labelLarge),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.kD,
                  precision: 8,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingKD(slotID) ??
                        DeviceSlotConfig.empty.kD,
                  ),
                  writeVal: (BuildContext context, double newKD) {
                    context.read<SlotsTabState>().setWorkingKD(slotID, newKD);
                  },
                ),
                const SizedBox(height: 8),
                OverflowText("kS:", style: theme.textTheme.labelLarge),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.kS,
                  precision: 8,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingKS(slotID) ??
                        DeviceSlotConfig.empty.kS,
                  ),
                  writeVal: (BuildContext context, double newKS) {
                    context.read<SlotsTabState>().setWorkingKS(slotID, newKS);
                  },
                ),
                const SizedBox(height: 8),
                OverflowText("kS Mode:", style: theme.textTheme.labelLarge),
                Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: DropdownMenu<KSMode>(
                        initialSelection: context
                            .read<SlotsTabState>()
                            .getWorkingKSMode(slotID),
                        expandedInsets: EdgeInsets.zero,
                        selectOnly: true,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: KSMode.errorBased,
                            label: "Error-based",
                          ),
                          DropdownMenuEntry(
                            value: KSMode.velocityBased,
                            label: "Velocity-based",
                          ),
                        ],
                        onSelected: (KSMode? newMode) {
                          context.read<SlotsTabState>().setWorkingKSMode(
                            slotID,
                            newMode ?? KSMode.errorBased,
                          );
                        },
                      ),
                    ),
                    _KSModeHelp(slotID),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowText(
                  "Cruise Velocity (rpm):",
                  style: theme.textTheme.labelLarge,
                ),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.vMax,
                  precision: 2,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingVMax(slotID) ??
                        DeviceSlotConfig.empty.vMax,
                  ),
                  writeVal: (BuildContext context, double newVMax) {
                    context.read<SlotsTabState>().setWorkingVMax(
                      slotID,
                      newVMax,
                    );
                  },
                ),
                const SizedBox(height: 8),
                OverflowText(
                  "Starting Acceleration (rpm^2):",
                  style: theme.textTheme.labelLarge,
                ),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.aStart,
                  precision: 2,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingAStart(slotID) ??
                        DeviceSlotConfig.empty.aStart,
                  ),
                  writeVal: (BuildContext context, double newAStart) {
                    context.read<SlotsTabState>().setWorkingAStart(
                      slotID,
                      newAStart,
                    );
                  },
                ),
                const SizedBox(height: 8),
                OverflowText(
                  "Ending Acceleration (rpm^2):",
                  style: theme.textTheme.labelLarge,
                ),
                ConsumerDoubleField(
                  defaultVal: DeviceSlotConfig.empty.aEnd,
                  precision: 2,
                  watchVal: (BuildContext context) => context.select(
                    (SlotsTabState tabState) =>
                        tabState.getWorkingAEnd(slotID) ??
                        DeviceSlotConfig.empty.aEnd,
                  ),
                  writeVal: (BuildContext context, double newAEnd) {
                    context.read<SlotsTabState>().setWorkingAEnd(
                      slotID,
                      newAEnd,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KSModeHelp extends StatefulWidget {
  final int slotID;

  // ignore: unused_element_parameter
  const _KSModeHelp(this.slotID, {super.key});

  @override
  State<_KSModeHelp> createState() => _KSModeHelpState();
}

class _KSModeHelpState extends State<_KSModeHelp> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final kSMode = context.select(
      (SlotsTabState tabState) => tabState.getWorkingKSMode(widget.slotID),
    );

    final theme = Theme.of(context);

    late final String message;
    switch (kSMode) {
      case KSMode.errorBased:
        {
          message =
              "kS will be applied in the direction of the current error. This works best for position control.";
        }
      case KSMode.velocityBased:
        {
          message =
              "kS will be applied in the direction of the current velocity. This works best for velocity control.";
        }
      default:
        {
          message = "";
        }
    }

    return Tooltip(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
      ),
      message: message,
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) => setState(() {
          _hovering = true;
        }),
        onExit: (_) => setState(() {
          _hovering = false;
        }),
        child: Icon(
          Icons.help_outline,
          color: _hovering
              ? theme.colorScheme.onSurface.withAlpha(192)
              : theme.colorScheme.onSurface.withAlpha(128),
        ),
      ),
    );
  }
}
