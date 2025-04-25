import 'package:flutter/material.dart';
import '/../../themes/theme.dart';
import '/../models/models_exports.dart';
import 'widgets_exports.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final IconData deleteIcon;
  final String deleteTooltip;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onToggleActive,
    required this.onEdit,
    required this.deleteIcon,
    required this.deleteTooltip,
  }) : super(key: key);

  void _showDeactivateConfirmation(BuildContext context) {
    final action = service.isActive ? 'desactivar' : 'activar';
    final contentMessage = service.isActive
        ? 'Este servicio será desactivado y no aparecerá como disponible.'
        : 'Este servicio será activado y estará disponible.';

    CustomDialog.show(
      context: context,
      title: "¿Quieres $action este servicio?",
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
            onToggleActive();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del servicio
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                service.imageUrl,
                width: screenWidth * 0.2,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            // Información del servicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: service.isActive ? AppColors.tertiary : Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Botones de editar y activar/desactivar 
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: Icon(
                    deleteIcon,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _showDeactivateConfirmation(context),
                  tooltip: deleteTooltip,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
