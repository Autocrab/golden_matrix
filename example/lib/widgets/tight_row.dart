import 'package:flutter/material.dart';

/// A widget that intentionally overflows on small devices or large text scales.
///
/// Used to demonstrate golden_matrix's overflow detection feature.
class TightRow extends StatelessWidget {
  const TightRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.warning_amber, size: 48),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This is a very long title that will overflow on small screens',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Subtitle with extra details that makes the row even wider than before',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const Spacer(),
        FilledButton(onPressed: () {}, child: const Text('Action')),
      ],
    );
  }
}
