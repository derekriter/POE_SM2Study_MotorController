import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:flutter/material.dart';

class SlotSelector extends StatefulWidget {
  final void Function(int) onChangeEnd;

  const SlotSelector({
    required this.onChangeEnd,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  State<SlotSelector> createState() => _SlotSelectorState();
}

class _SlotSelectorState extends State<SlotSelector> {
  int _selectedSlot = 0;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: OverflowText("0")),
        ButtonSegment(value: 1, label: OverflowText("1")),
        ButtonSegment(value: 2, label: OverflowText("2")),
        ButtonSegment(value: 3, label: OverflowText("3")),
        ButtonSegment(value: 4, label: OverflowText("4")),
        ButtonSegment(value: 5, label: OverflowText("5")),
      ],
      selected: {_selectedSlot},
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      onSelectionChanged: (Set<int> newSlot) {
        assert(newSlot.length == 1);

        setState(() {
          _selectedSlot = newSlot.elementAt(0);
          assert(_selectedSlot >= 0 && _selectedSlot <= 5);
        });
        widget.onChangeEnd(_selectedSlot);
      },
    );
  }
}
