import 'package:desktop_software/util/data_source.dart';
import 'package:desktop_software/widgets/overflow_text.dart';
import 'package:desktop_software/widgets/smooth_scroll.dart';
import 'package:flutter/material.dart';
import 'package:resizable_splitter/resizable_splitter.dart';

class GraphRegion extends StatelessWidget {
  const GraphRegion({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResizableSplitter(
      axis: Axis.vertical,
      initialRatio: 2 / 3.0,
      dividerColor: theme.colorScheme.surfaceContainerHigh,
      dividerHoverColor: theme.colorScheme.surfaceContainerHighest,
      dividerActiveColor: theme.colorScheme.surfaceBright,
      startPanel: const Placeholder(),
      endPanel: const Row(
        children: [
          Expanded(
            child: _DataDropRegion(
              header: "Left Axis",
              type: DataType.continous,
            ),
          ),
          VerticalDivider(
            indent: 0,
            endIndent: 0,
            radius: null,
            width: 4,
            thickness: 2,
          ),
          Expanded(
            child: _DataDropRegion(header: "Discrete", type: DataType.discrete),
          ),
          VerticalDivider(
            indent: 0,
            endIndent: 0,
            radius: null,
            width: 4,
            thickness: 2,
          ),
          Expanded(
            child: _DataDropRegion(
              header: "Right Axis",
              type: DataType.continous,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataDropRegion extends StatefulWidget {
  final String header;
  final DataType type;

  // ignore: unused_element_parameter
  const _DataDropRegion({required this.header, required this.type, super.key});

  @override
  State<_DataDropRegion> createState() => _DataDropRegionState();
}

class _DataDropRegionState extends State<_DataDropRegion> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        OverflowText(widget.header, style: theme.textTheme.labelLarge),
        Expanded(
          child: SmoothScroll(
            builder: (_, controller, physics) => SingleChildScrollView(
              controller: controller,
              physics: physics,
              child: const Placeholder(),
            ),
          ),
        ),
      ],
    );
  }
}
