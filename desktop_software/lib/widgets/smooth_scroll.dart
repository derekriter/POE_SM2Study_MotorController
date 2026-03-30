import 'package:flutter/material.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class SmoothScroll extends DynMouseScroll {
  const SmoothScroll({super.key, required super.builder})
    : super(
        durationMS: 150,
        scrollSpeed: 1,
        animationCurve: Curves.easeOutCubic,
      );
}
