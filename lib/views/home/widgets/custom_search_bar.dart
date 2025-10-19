import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final double scale;
  const CustomSearchBar({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
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
              
              style: GoogleFonts.inriaSans(
                color: Colors.white,
                fontSize: 16 * scale,
              ),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Search meals, plans, tips...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
