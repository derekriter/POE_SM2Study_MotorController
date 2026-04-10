import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:provider/provider.dart';

class DataDropRegion<T extends DataSource<S>, S> extends StatelessWidget {
  final String header;
  final List<SourceConfig<T, S>> Function(BuildContext) watchConfigs;
  final void Function(BuildContext, T) addSource;
  final void Function(BuildContext, SourceConfig<T, S>) removeConfig;

  const DataDropRegion({
    super.key,
    required this.header,
    required this.watchConfigs,
    required this.addSource,
    required this.removeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final configs = watchConfigs(context);

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
                  itemCount: configs.length,
                  itemBuilder: (context, i) => _GraphEntry(
                    config: configs[i],
                    removeConfig: removeConfig,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillAcceptWithDetails: (details) =>
          configs.every((cfg) => cfg.source.name != details.data.name),
      onAcceptWithDetails: (details) {
        addSource(context, details.data);
      },
      hitTestBehavior: HitTestBehavior.opaque,
    );
  }
}

class _GraphEntry<T extends DataSource<S>, S> extends StatelessWidget {
  final SourceConfig<T, S> config;
  final void Function(BuildContext, SourceConfig<T, S>) removeConfig;

  const _GraphEntry({required this.config, required this.removeConfig});

  @override
  Widget build(BuildContext context) {
    final pauseTime = context.select((AppState s) => s.pauseTime);
    final hoverTime = context.select((GraphState s) => s.mouseHoverTime);

    late final S? val;
    if (hoverTime != null) {
      val = config.source.getValueAtTimestamp(hoverTime.value);
    } else if (pauseTime != null) {
      val = config.source.getValueAtTimestamp(pauseTime.value);
    } else {
      val = config.source.watchCurrentValue(context);
    }

    final theme = Theme.of(context);

    return Draggable<T>(
      data: config.source,
      feedback: OverflowText(
        config.source.name,
        style: theme.textTheme.bodyMedium,
      ),
      dragAnchorStrategy: (draggable, context, position) =>
          pointerDragAnchorStrategy(draggable, context, position),
      hitTestBehavior: HitTestBehavior.opaque,
      onDragCompleted: () => removeConfig(context, config),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _ColorSelector(config: config),
                const SizedBox(width: 4),
                ...config.source.asGraphEntryContents(
                  context,
                  val,
                  config.visible,
                ),
                const SizedBox(width: 4),
                SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    onPressed: () {
                      context.read<GraphState>().modifyConfig(config, (cfg) {
                        cfg.visible = !cfg.visible;
                      });
                    },
                    icon: config.visible
                        ? const Icon(Icons.visibility, color: Colors.white)
                        : Icon(
                            Icons.visibility_off,
                            color: Colors.white.withAlpha(64),
                          ),
                    iconSize: 12,
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    onPressed: () => removeConfig(context, config),
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

class _ColorSelector<T extends DataSource<S>, S> extends StatefulWidget {
  final SourceConfig<T, S> config;

  const _ColorSelector({required this.config});

  @override
  State<_ColorSelector<T, S>> createState() => _ColorSelectorState();
}

class _ColorSelectorState<T extends DataSource<S>, S>
    extends State<_ColorSelector<T, S>> {
  Offset? _mousePos;
  final _colorSelectMenu = ContextMenu<Color>(
    borderRadius: BorderRadius.circular(2),
    entries: SourceConfig.usableColors.entries.map((e) {
      return MenuItem(
        constraints: const BoxConstraints(maxHeight: 24),
        value: e.value,
        icon: Center(
          child: SizedBox.square(
            dimension: 18,
            child: Container(
              decoration: BoxDecoration(borderRadius: null, color: e.value),
            ),
          ),
        ),
        label: OverflowText(e.key, style: TextStyle(fontSize: 12)),
      );
    }).toList(),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() {
        _mousePos = null;
      }),
      onHover: (e) => setState(() {
        _mousePos = e.position;
      }),
      child: SizedBox.square(
        dimension: 24,
        child: IconButton(
          onPressed: () async {
            final gs = context.read<GraphState>();

            if (_mousePos != null) {
              _colorSelectMenu.position = _mousePos!.translate(8, 8);
            }
            final newCol = await _colorSelectMenu.show(context);

            if (newCol == null) return;
            gs.modifyConfig(widget.config, (cfg) {
              cfg.color = newCol;
            });
          },
          icon: Icon(
            Icons.color_lens,
            color: widget.config.visible
                ? widget.config.color
                : widget.config.color.withAlpha(64),
          ),
          iconSize: 18,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
