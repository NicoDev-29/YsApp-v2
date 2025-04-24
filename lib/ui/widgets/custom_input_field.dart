import 'package:flutter/material.dart';
import '../../themes/theme.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextInputType inputType;
  final TextEditingController? controller;

  const CustomInputField({
    Key? key,
    required this.label,
    this.inputType = TextInputType.text,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
