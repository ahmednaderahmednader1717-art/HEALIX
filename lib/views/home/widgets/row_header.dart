import 'package:flutter/material.dart';

class RowHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;
  final double scale;
  const RowHeader({super.key, 
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
