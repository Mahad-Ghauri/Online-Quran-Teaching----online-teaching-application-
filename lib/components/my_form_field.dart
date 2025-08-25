// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFormField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextStyle? hintStyle;

  const MyFormField({
    super.key,
    this.hintStyle,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
    this.focusNode,
    this.onChanged,
  });

  @override
  State<MyFormField> createState() => _MyFormFieldState();
}

class _MyFormFieldState extends State<MyFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _animation,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
          if (hasFocus) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText && _isObscured,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            cursorWidth: 2,
            cursorRadius: const Radius.circular(4),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              hintText: widget.hintText,
              errorStyle: TextStyle(
                color: _isFocused ? Colors.red : Colors.red,
                fontFamily: GoogleFonts.urbanist().fontFamily,
              ),
              hintStyle:
                  widget.hintStyle ?? const TextStyle(color: Colors.black),
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: _isFocused
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.6),
                fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: _isFocused
                            ? colorScheme.primary.withOpacity(0.7)
                            : colorScheme.tertiary.withOpacity(0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              filled: true,
              fillColor: _isFocused
                  ? colorScheme.surface
                  : colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}