import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_splash/core/app_colors.dart';

class CustomSearchBar extends StatefulWidget {
  final double scale;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, required this.scale, this.onChanged});

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
    final scale = widget.scale;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ContainerColor,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70, size: 24 * scale),
          SizedBox(width: 8 * scale),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: GoogleFonts.inriaSans(
                color: Colors.white,
                fontSize: 16 * scale,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white54,
                          size: 20 * scale,
                        ),
                        onPressed: () {
                          _controller.clear();
                          if (widget.onChanged != null) {
                            widget.onChanged!('');
                          }
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
