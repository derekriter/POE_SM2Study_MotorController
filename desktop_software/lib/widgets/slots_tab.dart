import 'package:flutter/material.dart';

class SlotsTab extends StatelessWidget {
  const SlotsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, i) {
        return _SlotConfigurator(id: i);
      },
    );
  }
}

class _SlotConfigurator extends StatefulWidget {
  final int id;

  // ignore: unused_element_parameter
  const _SlotConfigurator({required this.id, super.key});

  @override
  State<StatefulWidget> createState() => _SlotConfiguratorState();
}

class _SlotConfiguratorState extends State<_SlotConfigurator> {
  _SlotConfiguratorState();

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
