import 'package:flutter/material.dart';
import '/../../themes/theme.dart';

class FilterSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const FilterSelector({
    Key? key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const horizontalPadding = 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: AppColors.primary, 
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Padding(
          padding: const EdgeInsets.only(left: horizontalPadding),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        iconSize: screenHeight * 0.04,
        elevation: 2,
        style: const TextStyle(color: Colors.white),
        dropdownColor: AppColors.primary,
        underline: Container(),
        isExpanded: true,
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Padding(
              padding: const EdgeInsets.only(left: horizontalPadding),
              child: Text(
                option,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
