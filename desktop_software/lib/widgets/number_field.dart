import 'package:desktop_software/util/double_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  @override
  State<DoubleField> createState() => _DoubleFieldState();
}

class _DoubleFieldState extends State<DoubleField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  double _currentVal = 0;

  @override
  void initState() {
    super.initState();

    _currentVal = widget.defaultVal;
    _controller.text = _currentVal.toMinimizedString(
      maxPrecision: widget.precision,
    );

    _focusNode.addListener(() {
      if (!_focusNode.hasPrimaryFocus) {
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
    var val = double.tryParse(text) ?? widget.defaultVal;

    if (widget.min != null && val < widget.min!) val = widget.min!;
    if (widget.max != null && val > widget.max!) val = widget.max!;

    if (widget.precision != null) {
      val = val.roundToPrecision(widget.precision!);
    }

    setState(() {
      _currentVal = val;
      _controller.text = val.toMinimizedString(maxPrecision: widget.precision);
      widget.onChangeEnd(val);
    });
  }
}

class ConsumerDoubleField extends StatefulWidget {
  final double defaultVal;
  final double? min, max;
  final int? precision;
  final InputDecoration? decoration;
  final double Function(BuildContext) watchVal;
  final void Function(BuildContext, double) writeVal;
  final void Function(double)? onConfirmed;

  const ConsumerDoubleField({
    required this.defaultVal,
    this.min,
    this.max,
    this.precision,
    this.decoration,
    required this.watchVal,
    required this.writeVal,
    this.onConfirmed,
    super.key,
  });

  @override
  State<ConsumerDoubleField> createState() => _ConsumerDoubleFieldState();
}

class _ConsumerDoubleFieldState extends State<ConsumerDoubleField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasPrimaryFocus) {
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
    _controller.text = widget
        .watchVal(context)
        .toMinimizedString(maxPrecision: widget.precision);

    return TextField(
      decoration:
          widget.decoration ??
          const InputDecoration(border: OutlineInputBorder()),
      controller: _controller,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.eE-]")),
      ],
      onSubmitted: _onTextSubmitted,
      focusNode: _focusNode,
    );
  }

  void _onTextSubmitted(String text) {
    var val = double.tryParse(text) ?? widget.defaultVal;

    if (widget.min != null && val < widget.min!) val = widget.min!;
    if (widget.max != null && val > widget.max!) val = widget.max!;

    if (widget.precision != null) {
      val = val.roundToPrecision(widget.precision!);
    }

    widget.writeVal(context, val);
    widget.onConfirmed?.call(val);
  }
}
