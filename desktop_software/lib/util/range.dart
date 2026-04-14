class Range {
  num min, max;

  Range({required this.min, required this.max});

  num get span => max - min;

  num atPercent(double perc) {
    return min + span * perc;
  }

  double getPercent(num val) {
    return (val - min) / span;
  }
}
