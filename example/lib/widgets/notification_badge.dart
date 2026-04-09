import 'package:flutter/material.dart';

enum BadgeSeverity { info, warning, error }

class NotificationBadge extends StatelessWidget {
  final int count;
  final String label;
  final BadgeSeverity severity;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.label,
    this.severity = BadgeSeverity.info,
  });

  Color _backgroundColor(ThemeData theme) => switch (severity) {
    BadgeSeverity.info => theme.colorScheme.primaryContainer,
    BadgeSeverity.warning => Colors.orange.shade100,
    BadgeSeverity.error => theme.colorScheme.errorContainer,
  };

  Color _foregroundColor(ThemeData theme) => switch (severity) {
    BadgeSeverity.info => theme.colorScheme.onPrimaryContainer,
    BadgeSeverity.warning => Colors.orange.shade900,
    BadgeSeverity.error => theme.colorScheme.onErrorContainer,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundColor(theme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _foregroundColor(theme),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: _backgroundColor(theme),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: _foregroundColor(theme))),
        ],
      ),
    );
  }
}
