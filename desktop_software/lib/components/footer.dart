import 'package:desktop_software/device/ports.dart';
import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final connInfo = context.select((AppState s) => s.connInfo);
    final deviceName = context.select(
      (AppState appState) => appState.deviceName,
    );
    final firmwareVersion = context.select(
      (AppState appState) => appState.firmwareVersion,
    );

    final theme = Theme.of(context);

    return Container(
      color: connInfo.connected
          ? theme.colorScheme.primaryContainer
          : Colors.grey.shade800,
      width: double.maxFinite,
      padding: EdgeInsets.all(4),
      child: Row(
        spacing: 24,
        children: [
          const _ConnectionControls(),
          if (connInfo.ready)
            Expanded(
              child: Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: OverflowText(
                        "${deviceName ?? "UNKNOWN DEVICE"} (firmware ${firmwareVersion ?? "UNKNOWN FIRMWARE"})",
                      ),
                    ),
                  ),
                  const _UPSText(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ConnectionControls extends StatefulWidget {
  const _ConnectionControls();

  @override
  State<_ConnectionControls> createState() => _ConnectionControlsState();
}

class _ConnectionControlsState extends State<_ConnectionControls> {
  PortInfo? selected;

  @override
  Widget build(BuildContext context) {
    final connInfo = context.select((AppState s) => s.connInfo);
    final ports = context.select((AppState s) => s.ports);

    final theme = Theme.of(context);

    return Row(
      spacing: 6,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            spacing: 6,
            children: [
              FilledButton(
                onPressed: selected == null && !connInfo.connected
                    ? null
                    : () {
                        final appState = context.read<AppState>();
                        if (!connInfo.connected) {
                          if (selected != null) {
                            appState.connect(selected!);
                          }
                        } else {
                          appState.disconnect();
                        }
                      },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                  backgroundColor: connInfo.connected
                      ? Colors.green
                      : theme.colorScheme.primary,
                  fixedSize: Size(120, 32),
                ),
                child: OverflowText(
                  connInfo.connected ? "Disconnect" : "Connect",
                ),
              ),
              DropdownMenu<PortInfo>(
                selectOnly: true,
                onSelected: (val) {
                  selected = val;
                  setState(() {});
                },
                initialSelection: ports.elementAtOrNull(0),
                textStyle: const TextStyle(fontSize: 12),
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: BoxConstraints.tight(const Size.fromHeight(32)),
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(4),
                  // ),
                ),
                trailingIcon: const Icon(Icons.arrow_drop_down, size: 12),
                selectedTrailingIcon: const Icon(Icons.arrow_drop_up, size: 12),
                dropdownMenuEntries: ports
                    .map(
                      (p) => DropdownMenuEntry(
                        value: p,
                        label: p.description ?? p.name,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        connInfo.connected
            ? (connInfo.ready
                  ? const OverflowText("Connected - Ready")
                  : OverflowText(
                      "Connected - Not ready",
                      style: TextStyle(color: Colors.orange.shade800),
                    ))
            : OverflowText(
                "Disconnected",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(191),
                ),
              ),
      ],
    );
  }
}

class _UPSText extends StatelessWidget {
  // ignore: unused_element_parameter
  const _UPSText({super.key});

  @override
  Widget build(BuildContext context) {
    final updatesPerSec = context.select(
      (AppState appState) => appState.updatesPerSec,
    );

    return OverflowText("UPS: ${updatesPerSec ?? "UNKNOWN"}");
  }
}
