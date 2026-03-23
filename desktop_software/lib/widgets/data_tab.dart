import 'package:desktop_software/app_state.dart';
import 'package:desktop_software/device/device_control_mode.dart';
import 'package:desktop_software/widgets/data_widgets.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  static const Widget _divider = Divider(
    indent: 0,
    endIndent: 0,
    radius: null,
    height: 8,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ListView(
        children: const [
          _EnabledWidget(),
          _divider,
          _SourceVoltageWidget(),
          _divider,
          _PositionWidget(),
          _divider,
          _VelocityWidget(),
          _divider,
          _ControlModeWidget(),
          _divider,
          _DutyOutWidget(),
          _divider,
          _VoltageOutWidget(),
          _divider,
          _TargetWidget(),
          _divider,
          _ErrorWidget(),
          _divider,
          _PFactorWidget(),
          _divider,
          _IFactorWidget(),
          _divider,
          _DFactorWidget(),
          _divider,
          _SFactorWidget(),
          _divider,
          _SlotWidget(),
          _divider,
          _SubErrorWidget(),
          _divider,
          _SecsToCompletionWidget(),
          _divider,
          _PhaseNameWidget(),
          _divider,
        ],
      ),
    );
  }
}

class _EnabledWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _EnabledWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = context.select((AppState appState) => appState.enabled);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "enabled",
                style: enabled == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (enabled != null) Expanded(child: BooleanDataWidget(enabled)),
        ],
      ),
    );
  }
}

class _SourceVoltageWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SourceVoltageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sv = context.select((AppState appState) => appState.sourceVoltage);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "sourceVoltage",
                style: sv == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (sv != null)
            Expanded(child: TextDataWidget("${sv.toStringAsFixed(2)} V")),
        ],
      ),
    );
  }
}

class _PositionWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PositionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = context.select((AppState appState) => appState.position);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "position",
                style: pos == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (pos != null)
            Expanded(child: TextDataWidget("${pos.toStringAsFixed(4)} rots")),
        ],
      ),
    );
  }
}

class _VelocityWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _VelocityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vel = context.select((AppState appState) => appState.velocity);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "velocity",
                style: vel == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (vel != null)
            Expanded(child: TextDataWidget("${vel.toStringAsFixed(4)} rpm")),
        ],
      ),
    );
  }
}

class _ControlModeWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _ControlModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cm = context.select((AppState appState) => appState.controlMode);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "controlMode",
                style: cm == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (cm != null) Expanded(child: ControlModeDataWidget(cm)),
        ],
      ),
    );
  }
}

class _DutyOutWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _DutyOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dutyOut = context.select((AppState appState) => appState.dutyOut);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "dutyOut",
                style: dutyOut == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (dutyOut != null)
            Expanded(child: PercentOutDataWidget(dutyOut, 3, dutyOut)),
        ],
      ),
    );
  }
}

class _VoltageOutWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _VoltageOutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final voltageOut = context.select(
      (AppState appState) => appState.voltageOut,
    );
    final source = context.select(
      (AppState appState) => appState.sourceVoltage,
    );

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "voltageOut",
                style: voltageOut == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (voltageOut != null && source != null)
            Expanded(
              child: PercentOutDataWidget(
                voltageOut,
                3,
                source == 0 ? 0 : voltageOut / source, //prevent divide by zero
                suffix: " V",
              ),
            ),
        ],
      ),
    );
  }
}

class _TargetWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _TargetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final target = context.select(
      (AppState appState) => appState.closedLoopTarget,
    );
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "target",
                style: target == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (target != null)
            Expanded(
              child: TextDataWidget(
                "${target.toStringAsFixed(4)}$closedLoopUnit",
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final error = context.select(
      (AppState appState) => appState.closedLoopError,
    );
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "error",
                style: error == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (error != null)
            Expanded(
              child: TextDataWidget(
                "${error.toStringAsFixed(4)}$closedLoopUnit",
              ),
            ),
        ],
      ),
    );
  }
}

class _PFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pFactor = context.select((AppState appState) => appState.closedLoopP);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "pFactor",
                style: pFactor == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (pFactor != null)
            Expanded(child: PercentOutDataWidget(pFactor, 3, pFactor)),
        ],
      ),
    );
  }
}

class _IFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _IFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final iFactor = context.select((AppState appState) => appState.closedLoopI);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "iFactor",
                style: iFactor == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (iFactor != null)
            Expanded(child: PercentOutDataWidget(iFactor, 3, iFactor)),
        ],
      ),
    );
  }
}

class _DFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _DFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dFactor = context.select((AppState appState) => appState.closedLoopD);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "dFactor",
                style: dFactor == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (dFactor != null)
            Expanded(
              child: PercentOutDataWidget(dFactor, 3, dFactor.clamp(-1, 1)),
            ),
        ],
      ),
    );
  }
}

class _SFactorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SFactorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sFactor = context.select((AppState appState) => appState.closedLoopS);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "sFactor",
                style: sFactor == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (sFactor != null)
            Expanded(
              child: PercentOutDataWidget(sFactor, 3, sFactor.clamp(-1, 1)),
            ),
        ],
      ),
    );
  }
}

class _SlotWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SlotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final slot = context.select((AppState appState) => appState.closedLoopSlot);

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "slot",
                style: slot == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (slot != null) Expanded(child: TextDataWidget(slot.toString())),
        ],
      ),
    );
  }
}

class _SubErrorWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SubErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final subError = context.select(
      (AppState appState) => appState.closedLoopSubError,
    );
    final controlMode = context.select(
      (AppState appState) => appState.controlMode,
    );

    final theme = Theme.of(context);

    late final String closedLoopUnit;
    switch (controlMode) {
      case DeviceControlMode.pidPos:
      case DeviceControlMode.trapPos:
        {
          closedLoopUnit = " rots";
        }
      case DeviceControlMode.pidVel:
        {
          closedLoopUnit = " rpm";
        }
      default:
        {
          closedLoopUnit = "";
        }
    }

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "subError",
                style: subError == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (subError != null)
            Expanded(
              child: TextDataWidget(
                "${subError.toStringAsFixed(4)}$closedLoopUnit",
              ),
            ),
        ],
      ),
    );
  }
}

class _SecsToCompletionWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SecsToCompletionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final secs = context.select(
      (AppState appState) => appState.secsToCompletion,
    );

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "secsToCompletion",
                style: secs == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (secs != null)
            Expanded(child: TextDataWidget("${secs.toStringAsFixed(3)} s")),
        ],
      ),
    );
  }
}

class _PhaseNameWidget extends StatelessWidget {
  // ignore: unused_element_parameter
  const _PhaseNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final phase = context.select(
      (AppState appState) => appState.closedLoopPhaseName,
    );

    final theme = Theme.of(context);

    final validStyle = TextStyle(color: theme.colorScheme.onSurface);
    final invalidStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(127),
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: OverflowText(
                "phaseName",
                style: phase == null ? invalidStyle : validStyle,
              ),
            ),
          ),
          if (phase != null) Expanded(child: TextDataWidget(phase)),
        ],
      ),
    );
  }
}
