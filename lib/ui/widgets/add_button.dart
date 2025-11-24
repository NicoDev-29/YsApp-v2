import 'package:flutter/material.dart';
import '/../themes/theme.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;

  const AddButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calcula padding proporcional (similar a CustomHeader)
    final horizontalPadding = (screenWidth * 0.05).clamp(12.0, 30.0);
    final verticalPadding = (screenHeight * 0.010).clamp(8.0, 20.0);

    // Tamaño de fuente proporcional con límites
    double fontSize = screenHeight * 0.022;
    if (screenWidth < 350) {
      fontSize = screenHeight * 0.018;
    }
    fontSize = fontSize.clamp(12.0, 20.0);

    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: AppColors.secondary, size: fontSize + 4)
            : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }
}
