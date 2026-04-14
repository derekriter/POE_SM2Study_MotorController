import 'dart:math';

import 'package:desktop_software/state/app_state.dart';
import 'package:desktop_software/state/graph_state.dart';
import 'package:desktop_software/util/num_helpers.dart';
import 'package:desktop_software/util/range.dart';
import 'package:desktop_software/util/units.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef AxisDynamics = ({num firstVal, num valInc});

class GraphView extends StatefulWidget {
  const GraphView({super.key});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  _GraphPainter? _painter;

  Offset? _mousePos;

  @override
  Widget build(BuildContext context) {
    _painter ??= _GraphPainter(
      theme: Theme.of(context),
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
        if (_painter!.lastLayout != null &&
            _mousePos != null &&
            _painter!.lastLayout!.insideRect.contains(_mousePos!)) {
          hoverTime = Milliseconds(
            (_painter!.toSeconds(_painter!.lastLayout!, _mousePos!.dx) * 1000)
                .round(),
          );
        }

        final gs = context.read<GraphState>();
        Future.microtask(() => gs.mouseHoverTime = hoverTime);
      },
    );

    final appStateRead = context.read<AppState>();

    final currentTime = context.select((AppState s) => s.lastTimestamp);
    final pauseTime = context.select((AppState s) => s.pauseTime);
    context.select((GraphState s) => s.discreteConfigs);
    context.select((GraphState s) => s.leftAxisConfigs);
    context.select((GraphState s) => s.rightAxisConfigs);

    final theme = Theme.of(context);

    final pauseButton = TextButton.icon(
      onPressed: () {
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
  Range xRange;
  Range? leftRange;
  Range? rightRange;
  double yOffset;

  _GraphLayout({
    required this.outsideRect,
    required this.insideRect,
    required this.xRange,
    required this.leftRange,
    required this.rightRange,
    required this.yOffset,
  });

  bool get hasLeftAxis => leftRange != null;
  bool get hasRightAxis => rightRange != null;
}

class _GraphPainter extends CustomPainter {
  static const double epsilon = 1e-6;
  static const double discreteHeight = 16;
  static const double discreteSpacing = 4;
  static const double minPointSpacing = 2;
  static const double yTopPadding = 4;
  static const double idealXTickSpacing = 80;
  static const double idealYTickSpacing = 65;
  static const double verticalPadding = 64;

  final ThemeData theme;
  final Milliseconds<int>? Function() timeSupplier;
  final Iterable<DiscreteConfig> Function() discreteSupplier;
  final Iterable<ContinuousConfig> Function() continuousLeftSupplier;
  final Iterable<ContinuousConfig> Function() continuousRightSupplier;
  final Offset? Function() mousePosSupplier;
  final void Function() updateHoverTime;

  final TextSpan noDataSpan;
  late final TextPainter noDataPainter;
  final Paint outlinePaint, tickPaint, gridPaint;
  final Paint hoverPaint;
  final Paint discreteDividerPaint;
  late final TextStyle tickLabelStyle;

  _GraphPainter({
    required this.theme,
    required this.timeSupplier,
    required this.discreteSupplier,
    required this.continuousLeftSupplier,
    required this.continuousRightSupplier,
    required this.mousePosSupplier,
    required this.updateHoverTime,
  }) : noDataSpan = .new(text: "No data", style: theme.textTheme.displaySmall),
       outlinePaint = .new()
         ..color = theme.colorScheme.outline
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1,
       tickPaint = .new()
         ..color = theme.colorScheme.outline
         ..strokeWidth = 2,
       gridPaint = .new()
         ..color = theme.colorScheme.outline.withAlpha(102)
         ..strokeWidth = 1,
       hoverPaint = .new()
         ..color = Colors.white60
         ..strokeWidth = 1,
       discreteDividerPaint = .new()
         ..color = Colors.black
         ..strokeWidth = 1 {
    noDataPainter = .new(text: noDataSpan, textDirection: TextDirection.ltr);
    tickLabelStyle = theme.textTheme.labelSmall!.copyWith(
      fontWeight: FontWeight.normal,
      color: tickPaint.color,
    );
  }

  _GraphLayout? lastLayout;

  @override
  void paint(Canvas canvas, Size size) {
    final time = timeSupplier();

    updateHoverTime();

    if (time == null) {
      noDataPainter.layout(maxWidth: size.width);
      noDataPainter.paint(
        canvas,
        Offset(
          (size.width - noDataPainter.width) / 2,
          (size.height - noDataPainter.height) / 2,
        ),
      );

      lastLayout = null;
      return;
    }

    _GraphLayout layout = _drawGraphBase(canvas, size);
    _drawGraphContents(canvas, layout);

    final mouse = mousePosSupplier();
    if (mouse != null && layout.insideRect.contains(mouse)) {
      drawDashedLine(
        canvas,
        Offset(mouse.dx, layout.insideRect.top),
        Offset(mouse.dx, layout.insideRect.bottom),
        hoverPaint,
        5,
        5,
      );
    }

    lastLayout = layout;
  }

  _GraphLayout _drawGraphBase(Canvas canvas, Size size) {
    //outline
    final outlineRect = Rect.fromLTRB(
      verticalPadding,
      10,
      size.width - verticalPadding,
      size.height - 32,
    );
    canvas.drawRect(outlineRect, outlinePaint);

    final currentMS = timeSupplier()?.value ?? 0;
    final msRange = Range(min: max(currentMS - 10 * 1000, 0), max: currentMS);

    final discreteCount = discreteSupplier().fold(0, (current, cfg) {
      return current + (cfg.visible ? 1 : 0);
    });
    var workingLayout = _GraphLayout(
      outsideRect: outlineRect,
      insideRect: outlineRect.inflate(-1),
      xRange: Range(min: msRange.min / 1000, max: msRange.max / 1000),
      leftRange: null,
      rightRange: null,
      yOffset:
          discreteCount * discreteHeight +
          (discreteCount + 1) * discreteSpacing,
    );

    //x-axis
    drawXAxis(canvas, outlineRect, workingLayout);

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

    if (hasLeft) {
      workingLayout.leftRange = fitAxis(
        msRange.min.toInt(),
        msRange.max.toInt(),
        left,
      );

      drawVerticalAxis(canvas, outlineRect, workingLayout, true, true);
    }
    if (hasRight) {
      workingLayout.rightRange = fitAxis(
        msRange.min.toInt(),
        msRange.max.toInt(),
        right,
      );

      drawVerticalAxis(canvas, outlineRect, workingLayout, false, !hasLeft);
    }

    return workingLayout;
  }

  Range? fitAxis(int minT, int maxT, Iterable<ContinuousConfig> cfgs) {
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

    if (axisMin == axisMax) {
      axisMin -= 1;
      axisMax += 1;
    }

    return Range(min: axisMin, max: axisMax);
  }

  AxisDynamics? determineAxisDynamics(
    double pixelSpan,
    Range valRange,
    double idealSpacing,
  ) {
    if (valRange.span == 0 || pixelSpan == 0) {
      return null;
    }

    num idealCount = pixelSpan / idealSpacing;

    num idealValInc = valRange.span / idealCount;
    num roundBase = pow(10, (log(idealValInc) / ln10).floor());
    final multipliers = [0, 1, 2, 2, 5, 5, 5, 5, 5];
    num valInc =
        roundBase *
        (multipliers.elementAtOrNull((idealValInc / roundBase).round()) ?? 10);

    num firstVal = valRange.min.toDouble().ceilToNearest(valInc.toDouble());
    return (firstVal: firstVal, valInc: valInc);
  }

  void drawXAxis(Canvas canvas, Rect outlineRect, _GraphLayout layout) {
    final dynamics = determineAxisDynamics(
      layout.insideRect.width,
      layout.xRange,
      idealXTickSpacing,
    );
    if (dynamics == null) return;

    final offset =
        layout.xRange.getPercent(dynamics.firstVal) * layout.insideRect.width;
    final spacing =
        dynamics.valInc / layout.xRange.span * layout.insideRect.width;
    for (var i = 0; true; i++) {
      double x = layout.insideRect.left + offset + i * spacing;

      if (x > layout.insideRect.right + epsilon) break;

      canvas.drawLine(
        Offset(x, outlineRect.bottom),
        Offset(x, outlineRect.bottom + 4),
        tickPaint,
      );
      canvas.drawLine(
        Offset(x, outlineRect.bottom),
        Offset(x, outlineRect.top),
        gridPaint,
      );

      num val = dynamics.firstVal + i * dynamics.valInc;
      final span = TextSpan(
        text: "${val.toDouble().toMinimalString(maxPrecision: 3)}s",
        style: tickLabelStyle,
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      painter.layout(maxWidth: spacing);
      painter.paint(
        canvas,
        Offset(x - painter.width / 2, outlineRect.bottom + 4 + 2),
      );
    }
  }

  void drawVerticalAxis(
    Canvas canvas,
    Rect outlineRect,
    _GraphLayout layout,
    bool isLeft,
    bool drawGuides,
  ) {
    final range = isLeft ? layout.leftRange : layout.rightRange;
    if (range == null) return;

    final availableHeight =
        layout.insideRect.height - layout.yOffset - yTopPadding;

    final dynamics = determineAxisDynamics(
      availableHeight,
      range,
      idealYTickSpacing,
    );
    if (dynamics == null) return;

    final offset = range.getPercent(dynamics.firstVal) * availableHeight;
    final spacing = dynamics.valInc / range.span * availableHeight;
    for (var i = 0; true; i++) {
      double y =
          layout.insideRect.bottom - layout.yOffset - offset - i * spacing;

      if (y < layout.insideRect.top - yTopPadding - epsilon) break;

      canvas.drawLine(
        Offset(isLeft ? outlineRect.left : outlineRect.right, y),
        Offset(isLeft ? outlineRect.left - 4 : outlineRect.right + 4, y),
        tickPaint,
      );
      if (drawGuides) {
        canvas.drawLine(
          Offset(outlineRect.left, y),
          Offset(outlineRect.right, y),
          gridPaint,
        );
      }

      num val = dynamics.firstVal + i * dynamics.valInc;
      final span = TextSpan(
        text: val.toDouble().toMinimalString(),
        style: tickLabelStyle,
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      painter.layout(maxWidth: verticalPadding - 4);
      painter.paint(
        canvas,
        Offset(
          (isLeft ? outlineRect.left - 6 : outlineRect.right + 6) +
              (isLeft ? -1 : 0) * painter.width,
          y - painter.height / 2,
        ),
      );
    }
  }

  void _drawGraphContents(Canvas canvas, _GraphLayout layout) {
    final discreteConfigs = discreteSupplier();
    final leftConfigs = continuousLeftSupplier();
    final rightConfigs = continuousRightSupplier();

    canvas.clipRect(layout.insideRect);

    //draw discrete data
    var realI = 0;
    for (var i = 0; i < discreteConfigs.length; i++) {
      DiscreteConfig cfg = discreteConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawDiscreteConfig(canvas, layout, cfg, realI);
      realI++;
    }

    for (var i = 0; i < leftConfigs.length; i++) {
      ContinuousConfig cfg = leftConfigs.elementAt(i);
      if (!cfg.visible) continue;

      _drawContinousConfig(canvas, layout, cfg, true);
    }

    for (var i = 0; i < rightConfigs.length; i++) {
      ContinuousConfig cfg = rightConfigs.elementAt(i);
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
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
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
    final pixelsPerSec = layout.insideRect.width / layout.xRange.span;

    return layout.insideRect.left +
        (millis / 1000 - layout.xRange.min) * pixelsPerSec;
  }

  double toCanvasY(_GraphLayout layout, num value, bool isLeft) {
    if (isLeft && (!layout.hasLeftAxis || layout.leftRange!.span == 0) ||
        !isLeft && (!layout.hasRightAxis || layout.rightRange!.span == 0)) {
      return layout.insideRect.center.dy;
    }

    final pixelsPerUnit =
        (layout.insideRect.height - layout.yOffset - yTopPadding) /
        (isLeft ? layout.leftRange!.span : layout.rightRange!.span);

    return layout.insideRect.bottom -
        layout.yOffset -
        (value - (isLeft ? layout.leftRange!.min : layout.rightRange!.min)) *
            pixelsPerUnit;
  }

  double toSeconds(_GraphLayout layout, double x) {
    final secsPerPixel = layout.xRange.span / layout.insideRect.width;

    return layout.xRange.min + (x - layout.insideRect.left) * secsPerPixel;
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
