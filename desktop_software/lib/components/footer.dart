import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select(
      (AppState appState) => appState.isConnected,
    );
    final isReady = context.select((AppState appState) => appState.isReady);
    final port = context.select((AppState appState) => appState.port);
    final deviceName = context.select(
      (AppState appState) => appState.deviceName,
    );
    final firmwareVersion = context.select(
      (AppState appState) => appState.firmwareVersion,
    );

    final theme = Theme.of(context);

    return Container(
      color: isConnected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.errorContainer,
      width: double.maxFinite,
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 36,
              children: [
                OverflowText(
                  isConnected
                      ? "Connected - ${port ?? "UNKNOWN"}"
                      : "Disconnected",
                  style: TextStyle(
                    color: isConnected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
                OverflowText(
                  isReady ? "Ready" : "Not ready",
                  style: TextStyle(
                    color: isConnected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            Expanded(
              child: Center(
                child: OverflowText(
                  "${deviceName ?? "UNKNOWN DEVICE"} (firmware ${firmwareVersion ?? "UNKNOWN FIRMWARE"})",
                ),
              ),
            ),
          const Expanded(
            child: Align(alignment: Alignment.centerRight, child: _UPSText()),
          ),
        ],
      ),
    );
  }
}

class _UPSText extends StatelessWidget {
  // ignore: unused_element_parameter
  const _UPSText({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select(
      (AppState appState) => appState.isConnected,
    );
    final updatesPerSec = context.select(
      (AppState appState) => appState.updatesPerSec,
    );

    return OverflowText(
      "UPS: ${isConnected ? updatesPerSec ?? "UNKNOWN" : "-"}",
    );
  }
}
