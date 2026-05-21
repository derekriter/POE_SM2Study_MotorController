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
          : Colors.grey.shade700,
      width: double.maxFinite,
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          const Expanded(child: _ConnectionControls()),
          if (connInfo.connected)
            Expanded(
              child: Center(
                child: OverflowText(
                  "${deviceName ?? "UNKNOWN DEVICE"} (firmware ${firmwareVersion ?? "UNKNOWN FIRMWARE"})",
                ),
              ),
            ),
          if (connInfo.connected)
            const Expanded(
              child: Align(alignment: Alignment.centerRight, child: _UPSText()),
            ),
        ],
      ),
    );
  }
}

class _ConnectionControls extends StatelessWidget {
  const _ConnectionControls();

  @override
  Widget build(BuildContext context) {
    final connInfo = context.select((AppState s) => s.connInfo);

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
            children: [
              FilledButton(
                onPressed: () {
                  //TODO: implement button
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                  backgroundColor: connInfo.connected
                      ? Colors.green
                      : Colors.red,
                  foregroundColor: connInfo.connected
                      ? null
                      : theme.colorScheme.onError,
                ),
                child: OverflowText(
                  connInfo.connected ? "Disconnect" : "Connect",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: OverflowText("placeholder"),
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
