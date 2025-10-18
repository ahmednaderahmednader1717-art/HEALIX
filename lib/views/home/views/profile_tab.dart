import 'dart:math';

import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
 Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    // ignore: unused_local_variable
    final scale = min(w, h);
    final double toolbarHeight = 80 * h;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16 * w,
            right: 16 * w,
            top: toolbarHeight + 10 * h,
            bottom: 120 * h,
          ),
          child: Center(
            child: Column(
              children: [
                Text("Profile Page", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
