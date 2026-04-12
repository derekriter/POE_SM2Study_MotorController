import 'dart:math';

import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/units.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef MinMaxPair = ({num min, num max});

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  late final _GraphPainter _painter;

  Offset? _mousePos;

  @override
  void initState() {
    super.initState();

    _painter = _GraphPainter(
      themeSupplier: () => Theme.of(context),
      timeSupplier: () =>
          context.read<AppState>().pauseTime ??
          context.read<AppState>().lastTimestamp,
      discreteSupplier: () => context.read<GraphState>().discreteConfigs,
      continuousLeftSupplier: () => context.read<GraphState>().leftAxisConfigs,
      continuousRightSupplier: () =>
          context.read<GraphState>().rightAxisConfigs,
      mousePosSupplier: () => _mousePos,
      updateHoverTime: () {
        Milliseconds<int>? hoverTime;
        if (_painter.lastLayout != null &&
            _mousePos != null &&
            _painter.lastLayout!.insideRect.contains(_mousePos!)) {
          hoverTime = Milliseconds(
            (_painter.toSeconds(_painter.lastLayout!, _mousePos!.dx) * 1000)
                .round(),
          );
        }

        final gs = context.read<GraphState>();
        Future.microtask(() => gs.mouseHoverTime = hoverTime);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStateRead = context.read<AppState>();

    final currentTime = context.select((AppState s) => s.lastTimestamp);
    final pauseTime = context.select((AppState s) => s.pauseTime);
    context.select((GraphState s) => s.discreteConfigs);
    context.select((GraphState s) => s.leftAxisConfigs);
    context.select((GraphState s) => s.rightAxisConfigs);

    final theme = Theme.of(context);

    final pauseButton = TextButton.icon(
      onPressed: () {
        if (currentTime == null) return;

        appStateRead.pause();
      },
      label: const OverflowText("Pause"),
      icon: const Icon(Icons.pause),
    );
    final resumeButton = FilledButton.icon(
      onPressed: () => appStateRead.resume(),
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
          child: MouseRegion(
            onExit: (_) {
              _mousePos = null;
              context.read<GraphState>().mouseHoverTime = null;

              setState(() {});
            },
            onHover: (e) => setState(() {
              _mousePos = e.localPosition;

              setState(() {});
            }),
            child: ClipRect(
              child: CustomPaint(
                foregroundPainter: _painter,
                isComplex: true,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GraphLayout {
  Rect outsideRect, insideRect;
  MinMaxPair minMaxX;
  MinMaxPair? minMaxLeft;
  MinMaxPair? minMaxRight;
  double yOffset;

  _GraphLayout({
    required this.outsideRect,
    required this.insideRect,
    required this.minMaxX,
    required this.minMaxLeft,
    required this.minMaxRight,
    required this.yOffset,
  });

  bool get hasLeftAxis => minMaxLeft != null;
  bool get hasRightAxis => minMaxRight != null;
}

class _GraphPainter extends CustomPainter {
  static final Paint discreteDividerPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  static const double discreteHeight = 16;
  static const double discreteSpacing = 4;
  static const double minPointSpacing = 2;
  static const double yTopPadding = 4;

  final ThemeData Function() themeSupplier;
  final Milliseconds<int>? Function() timeSupplier;
  final Iterable<DiscreteConfig> Function() discreteSupplier;
  final Iterable<ContinuousConfig> Function() continuousLeftSupplier;
  final Iterable<ContinuousConfig> Function() continuousRightSupplier;
  final Offset? Function() mousePosSupplier;
  final void Function() updateHoverTime;

  _GraphLayout? lastLayout;

  _GraphPainter({
    required this.themeSupplier,
    required this.timeSupplier,
    required this.discreteSupplier,
    required this.continuousLeftSupplier,
    required this.continuousRightSupplier,
    required this.mousePosSupplier,
    required this.updateHoverTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = timeSupplier();
    final theme = themeSupplier();

    updateHoverTime();

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

      lastLayout = null;
      return;
    }

    _GraphLayout layout = _drawGraphBase(canvas, size);
    _drawGraphContents(canvas, layout);

    final mouse = mousePosSupplier();
    if (mouse != null && layout.insideRect.contains(mouse)) {
      final mousePaint = Paint()
        ..color = Colors.white60
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      drawDashedLine(
        canvas,
        Offset(mouse.dx, layout.insideRect.top),
        Offset(mouse.dx, layout.insideRect.bottom),
        mousePaint,
        5,
        5,
      );
    }

    lastLayout = layout;
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
      size.width - 60,
      size.height - (12 + 8 * 2 + 4),
    );
    canvas.drawRect(outlineRect, outlinePaint);

    final notchPaint = Paint.from(outlinePaint)..strokeWidth = 2;
    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withAlpha(102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final currentMS = timeSupplier()?.value ?? 0;
    final minMaxXMS = (min: currentMS - 10 * 1000, max: currentMS);
    final minMaxX = (min: minMaxXMS.min / 1000, max: minMaxXMS.max / 1000);

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
      canvas.drawLine(
        Offset(x, outlineRect.bottom),
        Offset(x, outlineRect.top),
        gridPaint,
      );
    }

    final discreteCount = discreteSupplier().fold(0, (current, cfg) {
      return current + (cfg.visible ? 1 : 0);
    });
    final discreteOffset =
        discreteCount * discreteHeight + (discreteCount + 1) * discreteSpacing;

    final left = continuousLeftSupplier();
    final right = continuousRightSupplier();

    bool hasLeft = false;
    for (var e in left) {
      if (e.visible) {
        hasLeft = true;
        break;
      }
    }
    bool hasRight = false;
    for (var e in right) {
      if (e.visible) {
        hasRight = true;
        break;
      }
    }

    MinMaxPair? minMaxLeft;
    if (hasLeft) {
      minMaxLeft = fitAxis(minMaxXMS.min, minMaxXMS.max, left);

      //left y-axis
      const int leftNotchCount = 13;
      for (var i = 0; i < leftNotchCount; i++) {
        double y =
            (outlineRect.top + yTopPadding + 0.5) +
            (outlineRect.height - 1 - discreteOffset - yTopPadding) *
                i /
                (leftNotchCount - 1);
        canvas.drawLine(
          Offset(outlineRect.left - 4, y),
          Offset(outlineRect.left, y),
          notchPaint,
        );

        if (hasLeft) {
          canvas.drawLine(
            Offset(outlineRect.left, y),
            Offset(outlineRect.right, y),
            gridPaint,
          );
        }
      }
    }
    MinMaxPair? minMaxRight;
    if (hasRight) {
      minMaxRight = fitAxis(minMaxXMS.min, minMaxXMS.max, right);

      //right y-axis
      const int rightNotchCount = 21;
      for (var i = 0; i < rightNotchCount; i++) {
        double y =
            (outlineRect.top + yTopPadding + 0.5) +
            (outlineRect.height - 1 - discreteOffset - yTopPadding) *
                i /
                (rightNotchCount - 1);
        canvas.drawLine(
          Offset(outlineRect.right, y),
          Offset(outlineRect.right + 4, y),
          notchPaint,
        );

        if (!hasLeft && hasRight) {
          canvas.drawLine(
            Offset(outlineRect.left, y),
            Offset(outlineRect.right, y),
            gridPaint,
          );
        }
      }
    }

    return _GraphLayout(
      outsideRect: outlineRect,
      insideRect: outlineRect.inflate(-1),
      minMaxX: minMaxX,
      minMaxLeft: minMaxLeft,
      minMaxRight: minMaxRight,
      yOffset: discreteOffset,
    );
  }

  MinMaxPair? fitAxis(int minT, int maxT, Iterable<ContinuousConfig> cfgs) {
    num? axisMin, axisMax;

    for (var i = 0; i < cfgs.length; i++) {
      final scopeChanges = cfgs
          .elementAt(i)
          .source
          .getAllValuesInRange(minT, maxT);

      if (scopeChanges == null || scopeChanges.isEmpty) continue;

      num? cfgMin = scopeChanges.fold(null, (prev, el) {
        if (el == null) return prev;
        if (prev == null) return el.value;
        return min(prev, el.value);
      });
      num? cfgMax = scopeChanges.fold(null, (prev, el) {
        if (el == null) return prev;
        if (prev == null) return el.value;
        return max(prev, el.value);
      });

      if (cfgMin != null && (axisMin == null || axisMin > cfgMin)) {
        axisMin = cfgMin;
      }
      if (cfgMax != null && (axisMax == null || axisMax < cfgMax)) {
        axisMax = cfgMax;
      }
    }

    if (axisMin == null || axisMax == null) return null;
    return (min: axisMin, max: axisMax);
  }

  void _drawGraphContents(Canvas canvas, _GraphLayout layout) {
    final discreteConfigs = discreteSupplier();
    final continuousLeftConfigs = continuousLeftSupplier();
    final continuousRightConfigs = continuousRightSupplier();

    canvas.clipRect(layout.insideRect);

    //draw discrete data
    var realI = 0;
    for (var i = 0; i < discreteConfigs.length; i++) {
      DiscreteConfig cfg = discreteConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawDiscreteConfig(canvas, layout, cfg, realI);
      realI++;
    }

    for (var i = 0; i < continuousLeftConfigs.length; i++) {
      ContinuousConfig cfg = continuousLeftConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawContinousConfig(canvas, layout, cfg, true);
    }

    for (var i = 0; i < continuousRightConfigs.length; i++) {
      ContinuousConfig cfg = continuousRightConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawContinousConfig(canvas, layout, cfg, false);
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
        rightBound = toCanvasX(layout, changes.elementAt(i + 1).key);
      }
      double leftBound = toCanvasX(layout, changes.elementAt(i).key);

      if (leftBound < layout.insideRect.left &&
          rightBound < layout.insideRect.left) {
        //segment (and all following it) are off-graph
        return;
      }
      if (leftBound > layout.insideRect.right &&
          rightBound > layout.insideRect.right) {
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
        final divisionX = toCanvasX(layout, changes.elementAt(i + 1).key) - 1;
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
    bool isLeft,
  ) {
    final changes = cfg.source.getAllValueChanges();
    if (changes == null || changes.isEmpty) return;

    final linePaint = Paint()
      ..color = cfg.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    Offset? lastPoint;
    Path? workingPath;
    for (var i = changes.length - 1; i >= 0; i--) {
      final entry = changes.elementAt(i);
      if (entry.value == null) {
        lastPoint = null;
        continue;
      }

      double value = entry.value!.value.toDouble();

      final leftPoint = Offset(
        toCanvasX(layout, entry.key),
        toCanvasY(layout, value, isLeft),
      );
      if (lastPoint != null &&
          (lastPoint.dx - leftPoint.dx) < minPointSpacing) {
        continue;
      }

      late final Offset nextPoint;
      if (i == changes.length - 1) {
        nextPoint = Offset(
          layout.insideRect.right,
          toCanvasY(layout, value, isLeft),
        );
      } else {
        if (lastPoint != null) {
          nextPoint = lastPoint;
        } else {
          final prev = changes.elementAt(i + 1);
          nextPoint = Offset(
            toCanvasX(layout, prev.key),
            toCanvasY(layout, value, isLeft),
          );
        }
      }

      lastPoint = leftPoint;

      if (leftPoint.dx < layout.insideRect.left &&
          nextPoint.dx < layout.insideRect.left) {
        //segment (and all following it) are off-graph
        break;
      }
      if (leftPoint.dx > layout.insideRect.right &&
          nextPoint.dx > layout.insideRect.right) {
        if (workingPath != null) {
          canvas.drawPath(workingPath, linePaint);
          workingPath = null;
        }
        continue;
      }

      final rightPoint = Offset(nextPoint.dx, leftPoint.dy);

      workingPath ??= Path();

      workingPath.moveTo(leftPoint.dx, leftPoint.dy);
      workingPath.lineTo(rightPoint.dx, rightPoint.dy);

      workingPath.moveTo(rightPoint.dx, rightPoint.dy);
      workingPath.lineTo(nextPoint.dx, nextPoint.dy);
    }

    if (workingPath != null) {
      canvas.drawPath(workingPath, linePaint);
      workingPath = null;
    }
  }

  double toCanvasX(_GraphLayout layout, int millis) {
    final pixelsPerSec =
        layout.insideRect.width / (layout.minMaxX.max - layout.minMaxX.min);

    return layout.insideRect.left +
        (millis / 1000 - layout.minMaxX.min) * pixelsPerSec;
  }

  double toCanvasY(_GraphLayout layout, num value, bool isLeft) {
    if (isLeft &&
            (!layout.hasLeftAxis ||
                layout.minMaxLeft!.min == layout.minMaxLeft!.max) ||
        !isLeft &&
            (!layout.hasRightAxis ||
                layout.minMaxRight!.min == layout.minMaxRight!.max)) {
      return layout.insideRect.center.dy;
    }

    final pixelsPerUnit =
        (layout.insideRect.height - layout.yOffset - yTopPadding) /
        (isLeft
            ? layout.minMaxLeft!.max - layout.minMaxLeft!.min
            : layout.minMaxRight!.max - layout.minMaxRight!.min);

    return layout.insideRect.bottom -
        layout.yOffset -
        (value - (isLeft ? layout.minMaxLeft!.min : layout.minMaxRight!.min)) *
            pixelsPerUnit;
  }

  double toSeconds(_GraphLayout layout, double x) {
    final secsPerPixel =
        (layout.minMaxX.max - layout.minMaxX.min) / layout.insideRect.width;

    return layout.minMaxX.min + (x - layout.insideRect.left) * secsPerPixel;
  }

  void drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    double dashLen,
    double dashSpacing,
  ) {
    final delta = p2 - p1;
    final norm = delta / delta.distance;

    final dashSize = dashLen + dashSpacing;
    final steps = delta.distance / dashSize;
    for (int i = 0; i < steps; i++) {
      final start = p1 + norm * dashSize * i.toDouble();

      final endDist = min(i * dashSize + dashLen, delta.distance);
      final end = p1 + norm * endDist;

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return false;
  }
}
