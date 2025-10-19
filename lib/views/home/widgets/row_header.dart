import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';

class RowHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;
  final double scale;
  const RowHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
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
              color: AppColors.primarayColor,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
