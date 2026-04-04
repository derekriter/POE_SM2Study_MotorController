import 'dart:math';

import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/util/units.dart';
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
  State<_GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<_GraphView> {
  late final _GraphPainter _painter;

  @override
  void initState() {
    super.initState();

    _painter = _GraphPainter(
      themeSupplier: () => Theme.of(context),
      timeSupplier: () =>
          context.read<GraphState>().pauseTime ??
          context.read<AppState>().lastTimestamp,
      discreteSupplier: () => context.read<GraphState>().discreteSources,
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphStateRead = context.read<GraphState>();

    final currentTime = context.select((AppState s) => s.lastTimestamp);
    var pauseTime = context.select((GraphState s) => s.pauseTime);
    context.select((GraphState s) => s.discreteSources);

    //reset pause time on reconnect
    if (currentTime != null &&
        pauseTime != null &&
        currentTime.value < pauseTime.value) {
      //hacky but it works (mostly)
      pauseTime = currentTime;
      Future.microtask(() => graphStateRead.pause(currentTime));
    }

    final theme = Theme.of(context);

    final pauseButton = TextButton.icon(
      onPressed: () {
        if (currentTime == null) return;

        graphStateRead.pause(currentTime);
      },
      label: const OverflowText("Pause"),
      icon: const Icon(Icons.pause),
    );
    final resumeButton = FilledButton.icon(
      onPressed: () => graphStateRead.resume(),
      label: const OverflowText("Resume"),
      icon: const Icon(Icons.play_arrow),
    );

    final liveText = OverflowText(
      "Live",
      style: theme.textTheme.labelLarge?.copyWith(color: Colors.green),
    );

    Seconds timeDiff = Seconds(
      ((currentTime?.value ?? 0) - (pauseTime?.value ?? 0)) / 1000,
    );
    final haltedText = OverflowText(
      currentTime == null
          ? "Paused"
          : "Paused - ${timeDiff.applySuffix(timeDiff.value.floor().toString())}",
      style: theme.textTheme.labelLarge?.copyWith(color: Colors.orange),
    );

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              spacing: 16,
              children: [
                pauseTime == null ? pauseButton : resumeButton,
                pauseTime == null ? liveText : haltedText,
              ],
            ),
          ),
        ),
        const Divider(
          indent: 0,
          endIndent: 0,
          radius: null,
          thickness: 1,
          height: 1,
        ),
        Expanded(
          child: ClipRect(
            child: CustomPaint(
              foregroundPainter: _painter,
              willChange: true,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  static final Paint discreteDividerPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  static final double discreteHeight = 16;
  static final double discreteSpacing = 4;

  final ThemeData Function() themeSupplier;
  final Milliseconds<int>? Function() timeSupplier;
  final List<DiscreteDataSource<dynamic>> Function() discreteSupplier;

  _GraphPainter({
    required this.themeSupplier,
    required this.timeSupplier,
    required this.discreteSupplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = timeSupplier();
    final theme = themeSupplier();

    if (time == null) {
      final text = TextSpan(
        text: "No data",
        style: theme.textTheme.displaySmall,
      );
      final painter = TextPainter(text: text, textDirection: TextDirection.ltr);
      painter.layout(maxWidth: size.width);

      painter.paint(
        canvas,
        Offset(
          (size.width - painter.width) / 2,
          (size.height - painter.height) / 2,
        ),
      );

      return;
    }

    Rect insideRect = _drawGraphBase(canvas, size);
    _drawGraphContents(canvas, insideRect);
  }

  Rect _drawGraphBase(Canvas canvas, Size size) {
    final theme = themeSupplier();

    final outlinePaint = Paint()
      ..color = theme.colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    //outline
    final outlineRect = Rect.fromLTRB(
      60,
      10,
      size.width - 16,
      size.height - (12 + 8 * 2 + 4),
    );
    canvas.drawRect(outlineRect, outlinePaint);

    final notchPaint = Paint.from(outlinePaint)..strokeWidth = 2;

    //x-axis
    const int notchCount = 11;
    for (var i = 0; i < notchCount; i++) {
      double x =
          (outlineRect.left + 0.5) +
          (outlineRect.width - 1) * i / (notchCount - 1);
      canvas.drawLine(
        Offset(x, outlineRect.bottom),
        Offset(x, outlineRect.bottom + 4),
        notchPaint,
      );
    }

    return outlineRect.inflate(-1);
  }

  void _drawGraphContents(Canvas canvas, Rect insideRect) {
    final discreteSources = discreteSupplier();

    // canvas.clipRect(insideRect);

    //draw discrete data
    for (var i = 0; i < discreteSources.length; i++) {
      _drawDiscreteSource(canvas, insideRect, discreteSources[i], i);
    }
  }

  void _drawDiscreteSource(
    Canvas canvas,
    Rect insideRect,
    DiscreteDataSource<dynamic> src,
    int index,
  ) {
    final changes = src.getAllValueChanges();
    if (changes == null || changes.isEmpty) return;

    final fillPaint = Paint()
      ..color = HSVColor.fromColor(
        Colors.red.shade700,
      ).withSaturation(0.75).toColor()
      ..style = PaintingStyle.fill;

    final bottomHeight =
        insideRect.bottom -
        discreteSpacing * (index + 1) -
        discreteHeight * index;

    for (var i = changes.length - 1; i >= 0; i--) {
      late double rightBound;
      if (i == changes.length - 1) {
        rightBound = insideRect.right;
      } else {
        rightBound = _toCanvasSpace(
          insideRect,
          changes.elementAt(i + 1).key,
          0,
        ).dx;
      }
      double leftBound = _toCanvasSpace(
        insideRect,
        changes.elementAt(i).key,
        0,
      ).dx;

      if (leftBound < insideRect.left && rightBound < insideRect.left ||
          leftBound > insideRect.right && insideRect.right > insideRect.right) {
        //segment is off-graph
        continue;
      }

      rightBound = rightBound.clamp(insideRect.left, insideRect.right);
      leftBound = leftBound.clamp(insideRect.left, insideRect.right);

      final value = changes.elementAt(i).value;
      if (value == null) {
        continue;
      }

      _drawDiscreteSegment(
        canvas,
        Rect.fromLTRB(
          leftBound,
          bottomHeight - discreteHeight,
          rightBound,
          bottomHeight,
        ),
        src.asString(value),
        fillPaint,
      );

      if (i != changes.length - 1 && changes.elementAt(i + 1).value != null) {
        final divisionX =
            _toCanvasSpace(insideRect, changes.elementAt(i + 1).key, 0).dx - 1;
        canvas.drawLine(
          Offset(divisionX, bottomHeight - discreteHeight),
          Offset(divisionX, bottomHeight),
          discreteDividerPaint,
        );
      }
    }
  }

  void _drawDiscreteSegment(
    Canvas canvas,
    Rect bounds,
    String label,
    Paint paint,
  ) {
    final theme = themeSupplier();

    canvas.drawRect(bounds, paint);

    final span = TextSpan(
      text: label,
      style: TextStyle(color: theme.colorScheme.surface, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      ellipsis: "...",
      maxLines: 1,
    );
    textPainter.layout(maxWidth: max(bounds.width - 4, 0));
    textPainter.paint(canvas, bounds.topLeft + const Offset(2, 0));
  }

  Offset _toCanvasSpace(Rect insideRect, int millis, num value) {
    final time = timeSupplier();

    if (time == null) {
      //should never happen
      return const Offset(0, 0);
    }

    return Offset(
      (millis - time.value) / 1000 / 10 * insideRect.width + insideRect.right,
      value / 100 * insideRect.height + insideRect.top,
    );
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return true; //TODO: shouldRepaint logic?
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
