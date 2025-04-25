import 'package:flutter/material.dart';
import '/../themes/theme.dart';

class NewCategoryDialog extends StatefulWidget {
  const NewCategoryDialog({Key? key}) : super(key: key);

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Proporciones y tamaños
    final dialogWidth = screenWidth * 0.7;
    final borderRadius = screenWidth * 0.08;
    final textFieldHeight = screenHeight * 0.055;
    final fontSize = screenHeight * 0.018;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nueva Categoría',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize * 1.3,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: textFieldHeight,
              child: TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  hintText: 'Nombre de la categoría',
                  hintStyle: TextStyle(fontSize: fontSize),
                  contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius / 2),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            SizedBox(height: screenHeight * 0.01), 
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(_categoryNameController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, 
                    vertical: screenHeight * 0.01, 
                  ),
                  textStyle: TextStyle(fontSize: fontSize * 0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius / 2),
                  ),
                ),
                child: const Text('Agregar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
