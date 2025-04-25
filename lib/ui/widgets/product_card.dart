import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import '/../models/models_exports.dart';
import 'widgets_exports.dart'; 

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final IconData deleteIcon;
  final String deleteTooltip;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onToggleActive,
    required this.onEdit,
    required this.deleteIcon,
    required this.deleteTooltip,
  }) : super(key: key);

  void _showDeactivateConfirmation(BuildContext context) {
    final action = product.isActive ? 'desactivar' : 'activar';
    final contentMessage = product.isActive
        ? 'Este producto será desactivado y no aparecerá como disponible.'
        : 'Este producto será activado y estará disponible para la venta.';

    CustomDialog.show(
      context: context,
      title: "¿Quieres $action este producto?",
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
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: screenWidth * 0.2,
                height: screenHeight * 0.12,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error), 
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: product.isActive ? AppColors.tertiary: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Botones de editar y activar/desactivar
            Column(
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
