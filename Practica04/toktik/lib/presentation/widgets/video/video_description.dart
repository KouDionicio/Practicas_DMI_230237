import 'package:flutter/material.dart';

class VideoDescription extends StatelessWidget {
  const VideoDescription({
    super.key,
    required this.caption,
    required this.description,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  final String caption;
  final String description;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final isLong = description.length > 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 6),
          if (!isExpanded)
            Text(description, maxLines: 3, overflow: TextOverflow.ellipsis)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(child: Text(description)),
            ),
          if (isLong)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => onExpansionChanged(!isExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(isExpanded ? 'menos' : '... más'),
              ),
            ),
        ],
      ],
    );
  }
}
