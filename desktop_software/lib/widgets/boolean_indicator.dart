import 'package:flutter/material.dart';

class BooleanIndicator extends StatelessWidget {
  final bool state;
  final Widget? label;

  const BooleanIndicator(this.state, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        Container(
          decoration: BoxDecoration(
            color: state ? Colors.green : Colors.red,
            border: BoxBorder.all(
              color: Colors.black,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          width: 12,
          height: 12,
        ),
        ?label,
      ],
    );
  }
}
