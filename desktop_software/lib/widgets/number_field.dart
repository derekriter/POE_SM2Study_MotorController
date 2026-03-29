import 'package:desktop_software/double_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/web.dart';

final _logger = Logger();

class DoubleField extends StatefulWidget {
  final double defaultVal;
  final double? min, max;
  final int? precision;
  final InputDecoration? decoration;

  final Function(double) onChangeEnd;

  const DoubleField({
    required this.defaultVal,
    this.min,
    this.max,
    this.precision,
    this.decoration,
    required this.onChangeEnd,
    super.key,
  }) : assert(min == null || min <= defaultVal),
       assert(max == null || max >= defaultVal);

  @override
  State<StatefulWidget> createState() => _DoubleFieldState();

  //https://stackoverflow.com/a/49825756
  void setValue(BuildContext context, double val, {bool notify = true}) {
    final state = context.findAncestorStateOfType<_DoubleFieldState>();
    if (state == null) {
      _logger.w("Failed to find child state of DoubleField");
      return;
    }

    state.setValue(val, notify: notify);
  }
}

class _DoubleFieldState extends State<DoubleField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();

    _currentVal = widget.defaultVal;
    _controller.text = _currentVal.toStringShort();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _onTextSubmitted(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration:
          widget.decoration ??
          const InputDecoration(border: OutlineInputBorder()),
      controller: _controller,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]"))],
      onSubmitted: _onTextSubmitted,
      focusNode: _focusNode,
    );
  }

  void _onTextSubmitted(String text) {
    setValue(double.tryParse(text) ?? widget.defaultVal, notify: true);
  }

  void setValue(double val, {bool notify = true}) {
    setState(() {
      if (widget.min != null && val < widget.min!) val = widget.min!;
      if (widget.max != null && val > widget.max!) val = widget.max!;

      if (widget.precision != null) {
        val = val.roundToPrecision(widget.precision!);
      }

      _currentVal = val;
      _controller.text = val.toStringShort();
      if (notify) widget.onChangeEnd(_currentVal);
    });
  }
}
