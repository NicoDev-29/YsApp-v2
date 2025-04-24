import 'package:flutter/material.dart';
import '/../themes/theme.dart';

class InventorySectionTitle extends StatelessWidget {
  final String label;

  const InventorySectionTitle({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final verticalMargin = screenHeight * 0.018; // ~14px
    final horizontalPadding = screenWidth * 0.07; // ~22px
    final verticalPadding = screenHeight * 0.013; // ~8px
    final borderRadius = screenWidth * 0.025; // ~10px
    final fontSize = screenHeight * 0.022; // ~15px

    return Container(
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
