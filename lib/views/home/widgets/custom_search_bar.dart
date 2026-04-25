import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final double scale;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  const CustomSearchBar({
    super.key,
    required this.scale,
    this.onChanged,
    this.onFilterPressed,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scale = widget.scale;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: theme.brightness == Brightness.dark ? 0.69 : 0.8),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 2 * scale,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 24 * scale),
          SizedBox(width: 8 * scale),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: GoogleFonts.inriaSans(
                color: colorScheme.onSurface,
                fontSize: 16 * scale,
              ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant, size: 20 * scale),
              onPressed: () {
                _controller.clear();
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
                setState(() {});
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (widget.onFilterPressed != null) ...[
            if (_controller.text.isNotEmpty) SizedBox(width: 8 * scale),
            Container(
              height: 20 * scale,
              width: 1,
              color: Colors.white24,
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
            ),
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: AppColors.primarayColor,
                size: 22 * scale,
              ),
              onPressed: widget.onFilterPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
