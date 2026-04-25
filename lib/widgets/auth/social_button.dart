import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialElevatedButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final double size;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const SocialElevatedButton({
    super.key,
    required this.text,
    required this.imagePath,
    required this.size,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 55 * size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15 * size),
            side: BorderSide(color: theme.brightness == Brightness.dark ? Colors.white24 : colorScheme.outlineVariant),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 26 * size,
              height: 26 * size,
              color: (backgroundColor == Colors.black || theme.brightness == Brightness.dark) ? Colors.white : null,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
            SizedBox(width: 12 * size),
            Text(
              text,
              style: GoogleFonts.inriaSans(
                color: (backgroundColor == Colors.black || theme.brightness == Brightness.dark) ? Colors.white : colorScheme.onSurface,
                fontSize: 17 * size,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
