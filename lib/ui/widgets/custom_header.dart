import 'package:flutter/material.dart';
import '/../themes/theme.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String imagePath;

  const CustomHeader({
    Key? key,
    required this.title,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Tamaño adaptable de la imagen
    double imageHeight = screenHeight * 0.18;
    if (imageHeight > screenWidth * 0.3) {
      imageHeight = screenWidth * 0.35;
    }

    // Padding horizontal adaptable
    double horizontalPadding = screenWidth * 0.05;
    if (screenWidth < 350) {
      horizontalPadding = screenWidth * 0.02;
    }

    // Espaciados y paddings verticales
    final verticalPaddingTop = screenHeight * 0.05;
    final verticalPaddingBottom = screenHeight * 0.005;
    final spacingBetween = screenWidth * 0.04;

    // Padding dentro del cuadro del título
    final buttonHorizontalPadding = screenWidth * 0.03;
    final buttonVerticalPadding = screenHeight * 0.010;

    // Tamaño de fuente adaptable
    double buttonFontSize = imageHeight * 0.13;
    if (screenWidth < 350) {
      buttonFontSize = imageHeight * 0.12;
    }

    return Container(
      padding: EdgeInsets.only(
        top: verticalPaddingTop,
        bottom: verticalPaddingBottom,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imageHeight,
          ),
          SizedBox(width: spacingBetween),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.5, 
              ),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: buttonHorizontalPadding,
                  vertical: buttonVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
