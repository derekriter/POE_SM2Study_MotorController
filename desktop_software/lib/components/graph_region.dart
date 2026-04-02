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
      startPanel: const _GraphView(),
      endPanel: Row(
        children: [
          Expanded(
            child: _DataDropRegion(
              header: "Left Axis",
              watchSources: (context) =>
                  context.watch<GraphState>().leftAxisSources,
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
                  context.watch<GraphState>().discreteSources,
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
                  context.watch<GraphState>().rightAxisSources,
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

class _GraphView extends StatefulWidget {
  const _GraphView();

  @override
  State<StatefulWidget> createState() => _GraphViewState();
}

class _GraphViewState extends State<_GraphView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _DataDropRegion<T extends DataSource<S>, S> extends StatelessWidget {
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
                builder: (_, controller, physics) => ListView.builder(
                  controller: controller,
                  physics: physics,
                  itemCount: sources.length,
                  itemBuilder: (context, i) => _GraphEntry(
                    source: sources[i],
                    removeSource: removeSource,
                  ),
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

class _GraphEntry<T extends DataSource<S>, S> extends StatelessWidget {
  final T source;
  final void Function(BuildContext, T) removeSource;

  const _GraphEntry({required this.source, required this.removeSource});

  @override
  Widget build(BuildContext context) {
    final liveVal = source.watchCurrentValue(context);

    final theme = Theme.of(context);

    return Draggable<T>(
      data: source,
      feedback: OverflowText(source.name, style: theme.textTheme.bodyMedium),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      onDragCompleted: () => removeSource(context, source),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                ...source.asGraphEntryContents(context, liveVal),
                const SizedBox(width: 4),
                SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    onPressed: () => removeSource(context, source),
                    icon: const Icon(Icons.close),
                    iconSize: 12,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 0,
            endIndent: 0,
            radius: null,
            height: 0.5,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}
