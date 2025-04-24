import 'package:flutter/material.dart';
import '/../themes/theme.dart';

class InventoryMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const InventoryMenuButton({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final verticalMargin = screenHeight * 0.012;
    final horizontalPadding = screenWidth * 0.05; 
    final verticalPadding = screenHeight * 0.015;
    final borderRadius = screenWidth * 0.07;
    final fontSize = screenHeight * 0.022;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: verticalMargin, horizontal: verticalMargin),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Evita que el texto se salga
                  softWrap: false,
                ),
              ),
              Icon(Icons.arrow_forward, color: AppColors.primary, size: fontSize * 1.2),
            ],
          ),
        ),
      ),
    );
  }
}
