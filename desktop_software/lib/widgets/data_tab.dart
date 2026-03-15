import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/widgets/data_widgets.dart';
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

    late final String closedLoopUnit;
    switch (appState.controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      case null:
      default:
        {
          closedLoopUnit = "";
        }
    }

    final Map<String, DataWidget?> data = {
      "enabled": appState.enabled != null
          ? BooleanDataWidget(appState.enabled!)
          : null,
      "sourceVoltage": appState.sourceVoltage != null
          ? TextDataWidget("${appState.sourceVoltage!.toStringAsFixed(2)} V")
          : null,
      "position": appState.position != null
          ? TextDataWidget("${appState.position!.toStringAsFixed(4)} rots")
          : null,
      "velocity": appState.velocity != null
          ? TextDataWidget("${appState.velocity!.toStringAsFixed(4)} rpm")
          : null,
      "controlMode": appState.controlMode != null
          ? ControlModeDataWidget(appState.controlMode!)
          : null,
      "dutyOut": appState.dutyOut != null
          ? PercentOutDataWidget(appState.dutyOut!, 3, appState.dutyOut!)
          : null,
      "voltageOut": appState.voltageOut != null
          ? PercentOutDataWidget(
              appState.voltageOut!,
              3,
              appState.sourceVoltage != null
                  ? (appState.voltageOut! / appState.sourceVoltage!)
                  : 0,
              suffix: " V",
            )
          : null,
      "target": appState.closedLoopTarget != null
          ? TextDataWidget(
              "${appState.closedLoopTarget!.toStringAsFixed(4)}$closedLoopUnit",
            )
          : null,
      "error": appState.closedLoopError != null
          ? TextDataWidget(
              "${appState.closedLoopError!.toStringAsFixed(4)}$closedLoopUnit",
            )
          : null,
      "pFactor": appState.closedLoopP != null
          ? TextDataWidget(
              "${appState.closedLoopP!.toStringAsFixed(3)}$closedLoopUnit",
            )
          : null,
      "iFactor": appState.closedLoopI != null
          ? TextDataWidget(
              "${appState.closedLoopI!.toStringAsFixed(3)}$closedLoopUnit",
            )
          : null,
      "dFactor": appState.closedLoopD != null
          ? TextDataWidget(
              "${appState.closedLoopD!.toStringAsFixed(3)}$closedLoopUnit",
            )
          : null,
      "sFactor": appState.closedLoopS != null
          ? TextDataWidget(
              "${appState.closedLoopS!.toStringAsFixed(3)}$closedLoopUnit",
            )
          : null,
      "subError": appState.closedLoopSubError != null
          ? TextDataWidget(
              "${appState.closedLoopSubError!.toStringAsFixed(3)}$closedLoopUnit",
            )
          : null,
      "secsToCompletion": appState.secsToCompletion != null
          ? TextDataWidget("${appState.secsToCompletion!.toStringAsFixed(3)} s")
          : null,
      "phaseName": appState.closedLoopPhaseName != null
          ? TextDataWidget(appState.closedLoopPhaseName!)
          : null,
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
                if (entry.value != null) Expanded(child: entry.value!),
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
