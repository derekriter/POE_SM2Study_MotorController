import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/widgets/boolean_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      width: double.maxFinite,
      padding: EdgeInsets.all(4),
      child: Row(
        spacing: 12,
        children: [
          BooleanIndicator(
            appState.isConnected,
            Text(
              appState.isConnected
                  ? "Connected - ${appState.port ?? "UNKNOWN"}"
                  : "Disconnected",
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
          BooleanIndicator(
            appState.isReady,
            Text(
              appState.isReady ? "Ready" : "Not ready",
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
