import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final bool showActions;

  const ServiceCard({
    Key? key,
    required this.service,
    this.onEdit,
    this.onToggleActive,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono fijo de tijeras
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.content_cut,
              color: AppColors.primary,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${service.precioBase.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          if (showActions) ...[
            // Editar
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Activar/Desactivar
            InkWell(
              onTap: onToggleActive,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  service.activo
                      ? Icons.toggle_on
                      : Icons.toggle_off_outlined,
                  size: 20,
                  color: service.activo
                      ? AppColors.activeGreen
                      : Colors.grey[400],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}