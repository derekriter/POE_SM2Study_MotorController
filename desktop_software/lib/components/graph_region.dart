import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
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
      startPanel: const Placeholder(),
      endPanel: Row(
        children: [
          Expanded(
            child: _DataDropRegion(
              header: "Left Axis",
              watchSources: (context) =>
                  context.select((GraphState state) => state.leftAxisSources),
              addSource: (context, src) =>
                  context.read<GraphState>().addLeftAxisSource(src),
              removeSource: (context, src) =>
                  context.read<GraphState>().removeLeftAxisSource(src),
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
            child: _DataDropRegion(
              header: "Discrete",
              watchSources: (context) =>
                  context.select((GraphState state) => state.discreteSources),
              addSource: (context, src) =>
                  context.read<GraphState>().addDiscreteSource(src),
              removeSource: (context, src) =>
                  context.read<GraphState>().removeDiscreteSource(src),
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
            child: _DataDropRegion(
              header: "Right Axis",
              watchSources: (context) =>
                  context.select((GraphState state) => state.rightAxisSources),
              addSource: (context, src) =>
                  context.read<GraphState>().addRightAxisSource(src),
              removeSource: (context, src) =>
                  context.read<GraphState>().removeRightAxisSource(src),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataDropRegion<T extends DataSource<dynamic>> extends StatelessWidget {
  final String header;
  final List<T> Function(BuildContext) watchSources;
  final void Function(BuildContext, T) addSource;
  final void Function(BuildContext, T) removeSource;

  const _DataDropRegion({
    required this.header,
    required this.watchSources,
    required this.addSource,
    required this.removeSource,
  });

  @override
  Widget build(BuildContext context) {
    final sources = watchSources(context);

    final theme = Theme.of(context);

    return DragTarget<T>(
      builder: (context, candidates, rejected) => Container(
        color: candidates.isNotEmpty
            ? Colors.green.withAlpha(64)
            : Colors.transparent,
        child: Column(
          children: [
            OverflowText(header, style: theme.textTheme.labelLarge),
            Expanded(
              child: SmoothScroll(
                builder: (_, controller, physics) => ListView(
                  controller: controller,
                  physics: physics,
                  children: sources
                      .map((src) => Placeholder())
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillAcceptWithDetails: (details) =>
          sources.every((src) => src.name != details.data.name),
      onAcceptWithDetails: (details) {
        addSource(context, details.data);
      },
      hitTestBehavior: HitTestBehavior.opaque,
    );
  }
}
