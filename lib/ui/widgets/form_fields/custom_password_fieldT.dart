import 'package:flutter/material.dart';
import '../../../themes/theme.dart';

class CustomPasswordFieldT extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomPasswordFieldT({
    Key? key,
    required this.label,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomPasswordFieldT> createState() => _CustomPasswordFieldTState();
}

class _CustomPasswordFieldTState extends State<CustomPasswordFieldT> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor:  AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),
      ),
    );
  }
}