import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import  '../widgets/widgets_exports.dart';

class EmployeeCard extends StatelessWidget {
  final String name;
  final String username; 
  final String location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final IconData deleteIcon;
  final String deleteTooltip;
  final bool isActive;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.username,  
    required this.location,
    required this.onEdit,
    required this.onDelete,
    required this.deleteIcon,
    required this.deleteTooltip,
    required this.isActive,
  });

  void _showDeactivateConfirmation(BuildContext context) {
    final action = isActive ? 'desactivar' : 'activar';
    final contentMessage = isActive
        ? 'Esta persona será desactivada y no aparecerá como activa.'
        : 'Esta persona será activada y podrá volver a aparecer en la lista activa.';

    CustomDialog.show(
      context: context,
      title: "¿Quieres $action a esta trabajadora?",
      content: contentMessage,
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(action[0].toUpperCase() + action.substring(1)),
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
    final usernameFontSize = (screenHeight * 0.018).clamp(12.0, 18.0);
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
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: usernameFontSize,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
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
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              iconSize: iconButtonSize,
              icon: Icon(deleteIcon, color: AppColors.primary),
              onPressed: () => _showDeactivateConfirmation(context),
              tooltip: deleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
