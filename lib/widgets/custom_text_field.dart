import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? helperText;
  final TextInputType? keyboardType;

  const CustomTextField({super.key, 
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.helperText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        helperText: helperText,
        border: OutlineInputBorder(),
      ),
    );
  }
}