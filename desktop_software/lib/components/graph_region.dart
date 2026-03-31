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
              type: DataType.continous,
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
              type: DataType.discrete,
              watchSources: (context) =>
                  context.select((GraphState state) => state.discreteSources),
              addSource: (context, src) =>
                  context.read<GraphState>().addDiscreteSource(src),
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
              type: DataType.continous,
              watchSources: (context) =>
                  context.select((GraphState state) => state.rightAxisSources),
              addSource: (context, src) =>
                  context.read<GraphState>().addRightAxisSource(src),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataDropRegion<T extends DataSource<dynamic>> extends StatelessWidget {
  final String header;
  final DataType type;
  final List<T> Function(BuildContext) watchSources;
  final void Function(BuildContext, T) addSource;
  final void Function(BuildContext, T) removeSource;

  const _DataDropRegion({
    required this.header,
    required this.type,
    required this.watchSources,
    required this.addSource,
    required this.removeSource,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sources = watchSources(context);

    final theme = Theme.of(context);

    return DragTarget<DataSource<dynamic>>(
      builder: (context, candidates, rejected) => Container(
        color: candidates.isNotEmpty
            ? Colors.green.withAlpha(64)
            : (rejected.isNotEmpty
                  ? Colors.black.withAlpha(64)
                  : Colors.transparent),
        child: Column(
          children: [
            OverflowText(header, style: theme.textTheme.labelLarge),
            Expanded(
              child: SmoothScroll(
                builder: (_, controller, physics) => ListView(
                  controller: controller,
                  physics: physics,
                  children: sources
                      .map(
                        (src) => src.type == DataType.discrete
                            ? _DiscreteDataSourceEntry(
                                source: src as DiscreteDataSource,
                                removeSource: (context, discrete) =>
                                    removeSource(context, discrete as T),
                              )
                            : _ContinousDataSourceEntry(
                                src as ContinousDataSource,
                              ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillAcceptWithDetails: (details) =>
          details.data.type == type &&
          sources.every((src) => src.name != details.data.name),
      onAcceptWithDetails: (details) {
        assert(details.data is T);

        addSource(context, details.data as T);
      },
      hitTestBehavior: HitTestBehavior.opaque,
    );
  }
}

class _DiscreteDataSourceEntry extends StatelessWidget {
  final DiscreteDataSource source;
  final void Function(BuildContext, DiscreteDataSource) removeSource;

  const _DiscreteDataSourceEntry({
    required this.source,
    required this.removeSource,
  });

  @override
  Widget build(BuildContext context) {
    final value = source.watchCurrentValue(context);

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: OverflowText(
                  source.name,
                  style: value == null
                      ? TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(127),
                          fontStyle: FontStyle.italic,
                        )
                      : null,
                ),
              ),
              Expanded(
                child: value == null
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerRight,
                        child: OverflowText(source.asString(value)),
                      ),
              ),
              const SizedBox(width: 4),
              SizedBox.square(
                dimension: 24,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    removeSource(context, source);
                  },
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
    );
  }
}

class _ContinousDataSourceEntry extends StatelessWidget {
  final ContinousDataSource source;

  const _ContinousDataSourceEntry(this.source);

  @override
  Widget build(BuildContext context) {
    final value = source.watchCurrentValue(context);

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: OverflowText(
                  source.name,
                  style: value == null
                      ? TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(127),
                          fontStyle: FontStyle.italic,
                        )
                      : null,
                ),
              ),
              if (value != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OverflowText(source.asString(value)),
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
    );
  }
}
