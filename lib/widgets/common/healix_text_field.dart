import 'package:flutter/material.dart';

// Widget خاص بحقل إدخال مع دعم القيمة الابتدائية - تعمل فقط عند الإنشاء
class HealixTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String? errorText;
  final TextInputType? keyboardType;
  final String? initialValue; // خاصية اختيارية

  const HealixTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.errorText,
    this.keyboardType,
    this.initialValue, // Optional
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
    // الإضافة: ضبط قيمة controller فقط إذا فيه initialValue ولم يتم تعيين النص مسبقًا
    if (widget.initialValue != null &&
        widget.initialValue!.isNotEmpty &&
        widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          style: TextStyle(color: colorScheme.onSurface),
          cursorColor: colorScheme.onSurface,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: theme.brightness == Brightness.dark ? const Color(0xFF16313B).withValues(alpha: 0.69) : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : (theme.brightness == Brightness.dark ? Colors.white12 : colorScheme.outlineVariant),
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : colorScheme.primary,
                width: 1.5,
              ),
            ),
            suffixIcon: widget.isPassword
                ? Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      splashRadius: 20,
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 24,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
