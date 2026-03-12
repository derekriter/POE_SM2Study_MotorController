import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    final Map<String, String?> data = {
      "enabled": appState.enabled?.toString(),
      "sourceVoltage": appState.sourceVoltage?.toString(),
      "position": appState.position?.toString(),
      "velocity": appState.velocity?.toString(),
      "controlMode": appState.controlModeName?.toString(),
      "dutyOut": appState.dutyOut?.toString(),
      "voltageOut": appState.voltageOut?.toString(),
      "target": appState.closedLoopTarget?.toString(),
      "error": appState.closedLoopError?.toString(),
      "pFactor": appState.closedLoopP?.toString(),
      "iFactor": appState.closedLoopI?.toString(),
      "dFactor": appState.closedLoopD?.toString(),
      "sFactor": appState.closedLoopS?.toString(),
      "subError": appState.closedLoopSubError?.toString(),
      "secsToCompletion": appState.secsToCompletion?.toString(),
      "phaseName": appState.closedLoopPhaseName?.toString(),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        itemBuilder: (_, int i) {
          final entry = data.entries.elementAt(i);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OverflowText(
                      entry.key,
                      style: entry.value == null ? invalidStyle : validStyle,
                    ),
                  ),
                ),
                if (entry.value != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: OverflowText(entry.value!),
                    ),
                  ),
              ],
            ),
          );
        },
        separatorBuilder: (_, _) =>
            Divider(indent: 0, endIndent: 0, radius: null, height: 8),
        itemCount: data.length,
      ),
    );
  }
}
