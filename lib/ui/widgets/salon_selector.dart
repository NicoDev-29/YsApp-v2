import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

class SalonSelector extends StatelessWidget {
  final String? selectedSalon;
  final ValueChanged<String?> onChanged;

  const SalonSelector({
    Key? key,
    required this.selectedSalon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.store_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Salón:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSalon,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'salon_principal',
                      child: Text('Salón Principal'),
                    ),
                    DropdownMenuItem(
                      value: 'salon_secundario',
                      child: Text('Salón Secundario'),
                    ),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}