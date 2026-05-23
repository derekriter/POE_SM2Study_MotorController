import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/widgets/graph_entry.dart';
import 'package:desktop_software/widgets/graph_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resizable_splitter/resizable_splitter.dart';

class GraphRegion extends StatelessWidget {
  const GraphRegion({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResizableSplitter(
      axis: Axis.vertical,
      initialRatio: 2 / 3.0,
      dividerColor: theme.colorScheme.surfaceContainerHigh,
      dividerHoverColor: theme.colorScheme.surfaceContainerHighest,
      dividerActiveColor: theme.colorScheme.surfaceBright,
      startPanel: const GraphView(),
      endPanel: Row(
        children: [
          Expanded(
            child: DataDropRegion(
              header: "Left Axis",
              watchConfigs: (context) =>
                  context.watch<GraphState>().leftAxisConfigs,
              addSource: (context, src) =>
                  context.read<GraphState>().addLeftAxisSource(src),
              removeConfig: (context, cfg) =>
                  context.read<GraphState>().removeLeftAxisConfig(cfg),
              watchIsLocked: (context) =>
                  context.select((GraphState s) => s.isLeftLocked),
              setIsLocked: (context, locked) =>
                  context.read<GraphState>().setLeftAxisLocked(locked),
            ),
          ),
          const VerticalDivider(
            indent: 0,
            endIndent: 0,
            radius: null,
            width: 1,
            thickness: 1,
          ),
          Expanded(
            child: DataDropRegion(
              header: "Discrete",
              watchConfigs: (context) =>
                  context.watch<GraphState>().discreteConfigs,
              addSource: (context, src) =>
                  context.read<GraphState>().addDiscreteSource(src),
              removeConfig: (context, src) =>
                  context.read<GraphState>().removeDiscreteConfig(src),
            ),
          ),
          const VerticalDivider(
            indent: 0,
            endIndent: 0,
            radius: null,
            width: 1,
            thickness: 1,
          ),
          Expanded(
            child: DataDropRegion(
              header: "Right Axis",
              watchConfigs: (context) =>
                  context.watch<GraphState>().rightAxisConfigs,
              addSource: (context, src) =>
                  context.read<GraphState>().addRightAxisSource(src),
              removeConfig: (context, src) =>
                  context.read<GraphState>().removeRightAxisConfig(src),
              watchIsLocked: (context) =>
                  context.select((GraphState s) => s.isRightLocked),
              setIsLocked: (context, locked) =>
                  context.read<GraphState>().setRightAxisLocked(locked),
            ),
          ),
        ],
      ),
    );
  }
}
