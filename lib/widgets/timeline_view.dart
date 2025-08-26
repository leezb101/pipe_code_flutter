import 'package:flutter/material.dart';

typedef TimelineMarkerBuilder =
    Widget Function(BuildContext context, int index, bool isFirst, bool isLast);

typedef TimelineContentBuilder<T> =
    Widget Function(BuildContext context, int index, T item);

class GenericTimelineView<T> extends StatelessWidget {
  final List<T> data;
  final TimelineMarkerBuilder markerBuilder;
  final TimelineContentBuilder<T> contentBuilder;
  final Color lineColor;
  final double lineWidth;
  final double gutterSpacing;
  const GenericTimelineView({
    super.key,
    required this.data,
    required this.markerBuilder,
    required this.contentBuilder,
    this.lineColor = const Color(0xFFE0E0E0),
    this.lineWidth = 2.0,
    this.gutterSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final isFirst = index == 0;
        final isLast = index == data.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimelineAxis(context, index, isFirst, isLast),
              SizedBox(width: gutterSpacing),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isFirst ? 12 : 24,
                    bottom: isLast ? 12 : 24,
                  ),
                  child: contentBuilder(context, index, item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineAxis(
    BuildContext context,
    int index,
    bool isFirst,
    bool isLast,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: lineWidth,
          height: isFirst ? 12 : 24,
          color: isFirst ? Colors.transparent : lineColor,
        ),
        markerBuilder(context, index, isFirst, isLast),
        Expanded(
          child: Container(
            width: lineWidth,
            color: isLast ? Colors.transparent : lineColor,
          ),
        ),
      ],
    );
  }
}
