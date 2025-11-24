import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

class CustomDropdownField2 extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final List<Map<String, String>> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownField2({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
            ),
            hint: Text(
              'Selecciona $label',
              style: TextStyle(color: AppColors.textGrey),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item['id'],
                      child: Text(item['nombre']!),
                    ))
                .toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }
}