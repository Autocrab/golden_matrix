import 'package:flutter/material.dart';

enum AvatarSize { small, medium, large }

class UserAvatar extends StatelessWidget {
  final String name;
  final bool isOnline;
  final AvatarSize size;

  const UserAvatar({
    super.key,
    required this.name,
    this.isOnline = false,
    this.size = AvatarSize.medium,
  });

  double get _radius => switch (size) {
        AvatarSize.small => 16,
        AvatarSize.medium => 24,
        AvatarSize.large => 36,
      };

  String get _initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '?';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: _radius,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            _initials.toUpperCase(),
            style: TextStyle(
              fontSize: _radius * 0.7,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: _radius * 0.5,
              height: _radius * 0.5,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
