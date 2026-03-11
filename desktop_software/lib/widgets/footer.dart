import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Container(
      color: appState.isConnected
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
                  appState.isConnected
                      ? "Connected - ${appState.port ?? "UNKNOWN"}"
                      : "Disconnected",
                  style: TextStyle(
                    color: appState.isConnected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
                OverflowText(
                  appState.isReady ? "Ready" : "Not ready",
                  style: TextStyle(
                    color: appState.isConnected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          if (appState.isConnected)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: OverflowText(
                  "${appState.deviceName ?? "UNKNOWN DEVICE"} (firmware ${appState.firmwareVersion ?? "UNKNOWN FIRMWARE"})",
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: OverflowText(
                "UPS: ${appState.isConnected ? appState.updatesPerSec ?? "UNKNOWN" : "-"}",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
