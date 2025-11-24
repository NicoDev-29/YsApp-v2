import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import 'package:ysa_app/services/services_export.dart';

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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
                onPressed: () async {
                  final categoryName = _categoryNameController.text.trim();
                  if (categoryName.isEmpty) {
                    // Mostrar mensaje de error si quieres
                    return;
                  }
                  try {
                    await CategoryService().addCategory(categoryName);
                    Navigator.of(context).pop(true); // Retorna éxito
                  } catch (e) {
                    // Manejar error, mostrar mensaje
                    print('Error al agregar categoría: $e');
                  }
                },

                // resto igual
                child: const Text('Agregar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
