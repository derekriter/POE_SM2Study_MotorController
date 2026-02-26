import 'package:desktop_software/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final Map<String, String> data = {
      "isConnected": appState.isConnected.toString(),
      "port": appState.port ?? "null",
      "enabled": appState.enabled.toString(),
      "sourceVoltage": appState.sourceVoltage.toString(),
      "controlMode": appState.controlMode.toString(),
      "controlReference": appState.controlReference.toString(),
      "positionTicks": appState.positionTicks.toString(),
      "positionRotations": appState.positionRotations.toString(),
      "velocityTPS": appState.velocityTPS.toString(),
      "velocityRPM": appState.velocityRPM.toString(),
      "lastTimestamp": appState.lastTimestamp.toString(),
      "commandedOutput": appState.commandedOutput.toString(),
      "lastError": appState.lastError.toString(),
    };

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var point in data.entries)
            Row(
              children: [
                Text(point.key),
                SizedBox(width: 10),
                Text(point.value),
              ],
            ),
        ],
      ),
    );
  }
}
