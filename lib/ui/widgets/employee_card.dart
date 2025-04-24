import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import 'widgets_exports.dart';
import '../screens/screens_exports.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final String location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    Key? key,
    required this.name,
    required this.location,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: "¿Eliminar trabajadora?",
      content: "Esta persona se quitará de la lista.",
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text("Eliminar"),
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = (screenWidth * 0.1).clamp(30.0, 50.0);
    final horizontalSpacing = (screenWidth * 0.04).clamp(10.0, 20.0);
    final verticalMargin = (screenHeight * 0.005).clamp(8.0, 16.0);
    final paddingAll = (screenWidth * 0.04).clamp(12.0, 20.0);

    final nameFontSize = (screenHeight * 0.020).clamp(14.0, 20.0);
    final locationFontSize = (screenHeight * 0.018).clamp(12.0, 16.0);
    final iconButtonSize = (screenWidth * 0.07).clamp(24.0, 32.0);

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(paddingAll),
        child: Row(
          children: [
            Icon(Icons.person, size: iconSize, color: Colors.grey),
            SizedBox(width: horizontalSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: locationFontSize,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: iconButtonSize,
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: (){Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditEmployeeScreen() ),
                    );},
            ),
            IconButton(
              iconSize: iconButtonSize,
              icon: Icon(Icons.delete, color: AppColors.primary),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
}
