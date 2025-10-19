import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';

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
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16 * w,
            right: 16 * w,
            top: toolbarHeight + 10 * h,
            bottom: 120 * h,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Profile Page", style: TextStyle(color: Colors.white)),
                Gap(640),
                HealixPrimaryButton(text: "LOG OUT", onPressed: ()
                {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                }
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
