import 'package:flutter/material.dart';
import 'package:test_splash/core/app_colors.dart';

class HealixTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;

  const HealixTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
  });

  @override
  State<HealixTextField> createState() => _HealixTextFieldState();
}

class _HealixTextFieldState extends State<HealixTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.primarayColor, width: 1.2),
        ),
        // ايقونة العين
        suffixIcon: widget.isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.secondaryColor,
                    size: 20, // حجم أصغر لتناسب التصميم
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  splashRadius: 20, // يقلل من مساحة الـ ripple effect
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
      ),
    );
  }
}
