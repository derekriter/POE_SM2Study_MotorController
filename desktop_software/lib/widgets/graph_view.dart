import 'dart:math';
import 'dart:ui';

import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/units.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late final _GraphPainter _painter;

  @override
  void initState() {
    super.initState();

    _painter = _GraphPainter(
      themeSupplier: () => Theme.of(context),
      timeSupplier: () =>
          context.read<GraphState>().pauseTime ??
          context.read<AppState>().lastTimestamp,
      discreteSupplier: () => context.read<GraphState>().discreteConfigs,
      continuousSupplier: () {
        final gs = context.read<GraphState>();
        return gs.leftAxisConfigs.followedBy(gs.rightAxisConfigs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final graphStateRead = context.read<GraphState>();

    final currentTime = context.select((AppState s) => s.lastTimestamp);
    var pauseTime = context.select((GraphState s) => s.pauseTime);
    context.select((GraphState s) => s.discreteConfigs);
    context.select((GraphState s) => s.leftAxisConfigs);
    context.select((GraphState s) => s.rightAxisConfigs);

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

class _GraphLayout {
  Rect outsideRect, insideRect;
  double xScope, yScope;
  double yOffset;

  _GraphLayout({
    required this.outsideRect,
    required this.insideRect,
    required this.xScope,
    required this.yScope,
    required this.yOffset,
  });
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
  final Iterable<DiscreteConfig> Function() discreteSupplier;
  final Iterable<ContinuousConfig> Function() continuousSupplier;

  _GraphPainter({
    required this.themeSupplier,
    required this.timeSupplier,
    required this.discreteSupplier,
    required this.continuousSupplier,
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

    _GraphLayout layout = _drawGraphBase(canvas, size);
    _drawGraphContents(canvas, layout);
  }

  _GraphLayout _drawGraphBase(Canvas canvas, Size size) {
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
    const int xNotchCount = 11;
    for (var i = 0; i < xNotchCount; i++) {
      double x =
          (outlineRect.left + 0.5) +
          (outlineRect.width - 1) * i / (xNotchCount - 1);
      canvas.drawLine(
        Offset(x, outlineRect.bottom),
        Offset(x, outlineRect.bottom + 4),
        notchPaint,
      );
    }

    //y-axis
    const int yNotchCount = 9;
    final discreteCount = discreteSupplier().fold(0, (current, cfg) {
      return current + (cfg.visible ? 1 : 0);
    });
    final discreteOffset =
        discreteCount * discreteHeight + (discreteCount + 1) * discreteSpacing;

    for (var i = 0; i < yNotchCount; i++) {
      double y =
          (outlineRect.top + 0.5) +
          (outlineRect.height - 1 - discreteOffset) * i / (yNotchCount - 1);
      canvas.drawLine(
        Offset(outlineRect.left - 4, y),
        Offset(outlineRect.left, y),
        notchPaint,
      );
    }

    return _GraphLayout(
      outsideRect: outlineRect,
      insideRect: outlineRect.inflate(-1),
      xScope: 10,
      yScope: 10,
      yOffset: discreteOffset,
    );
  }

  void _drawGraphContents(Canvas canvas, _GraphLayout layout) {
    final discreteConfigs = discreteSupplier();
    final continuousConfigs = continuousSupplier();

    // canvas.clipRect(insideRect);

    //draw discrete data
    var realI = 0;
    for (var i = 0; i < discreteConfigs.length; i++) {
      DiscreteConfig cfg = discreteConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawDiscreteConfig(canvas, layout, cfg, realI);
      realI++;
    }

    for (var i = 0; i < continuousConfigs.length; i++) {
      ContinuousConfig cfg = continuousConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawContinousConfig(canvas, layout, cfg);
    }
  }

  void _drawDiscreteConfig(
    Canvas canvas,
    _GraphLayout layout,
    DiscreteConfig cfg,
    int index,
  ) {
    final changes = cfg.source.getAllValueChanges();
    if (changes == null || changes.isEmpty) return;

    final fillPaint = Paint()
      ..color = cfg.color
      ..style = PaintingStyle.fill;

    final bottomHeight =
        layout.insideRect.bottom -
        discreteSpacing * (index + 1) -
        discreteHeight * index;

    for (var i = changes.length - 1; i >= 0; i--) {
      late double rightBound;
      if (i == changes.length - 1) {
        rightBound = layout.insideRect.right;
      } else {
        rightBound = _toCanvasSpace(layout, changes.elementAt(i + 1).key, 0).dx;
      }
      double leftBound = _toCanvasSpace(layout, changes.elementAt(i).key, 0).dx;

      if (leftBound < layout.insideRect.left &&
              rightBound < layout.insideRect.left ||
          leftBound > layout.insideRect.right &&
              layout.insideRect.right > layout.insideRect.right) {
        //segment is off-graph
        continue;
      }

      rightBound = rightBound.clamp(
        layout.insideRect.left,
        layout.insideRect.right,
      );
      leftBound = leftBound.clamp(
        layout.insideRect.left,
        layout.insideRect.right,
      );

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
        cfg.source.asString(value),
        fillPaint,
      );

      if (i != changes.length - 1 && changes.elementAt(i + 1).value != null) {
        final divisionX =
            _toCanvasSpace(layout, changes.elementAt(i + 1).key, 0).dx - 1;
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

  void _drawContinousConfig(
    Canvas canvas,
    _GraphLayout layout,
    ContinuousConfig cfg,
  ) {
    final changes = cfg.source.getAllValueChanges();
    if (changes == null || changes.isEmpty) return;

    final linePaint = Paint()
      ..color = cfg.color
      ..strokeWidth = 5;

    final curr = changes.last;
    if (curr.value != null) {
      canvas.drawPoints(PointMode.points, [
        _toCanvasSpace(layout, curr.key, curr.value!.value),
      ], linePaint);
    }
  }

  Offset _toCanvasSpace(_GraphLayout layout, int millis, num value) {
    final time = timeSupplier();

    if (time == null) {
      //should never happen
      return Offset.zero;
    }

    return Offset(
      (millis - time.value) / 1000 / layout.xScope * layout.insideRect.width +
          layout.insideRect.right,
      layout.insideRect.bottom -
          layout.yOffset -
          value / layout.yScope * layout.insideRect.height,
    );
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return true; //TODO: shouldRepaint logic?
  }
}
