import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

class PersonalCard extends StatelessWidget {
  final String name;
  final String email;
  final String salon;
  final String rol;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;

  const PersonalCard({
    Key? key,
    required this.name,
    required this.email,
    required this.salon,
    required this.rol,
    required this.isActive,
    this.onEdit,
    this.onToggleActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar si es admin
    final bool isAdmin = rol.toLowerCase() == 'administradora' || rol.toLowerCase() == 'admin';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar - Color fijo (sin cambiar según rol)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Email
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                
                // Salón (línea completa)
                Row(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        salon,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Chip de Rol (nueva línea, debajo del salón)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin 
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAdmin 
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.teal.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin ? Icons.workspace_premium : Icons.work_outline,
                        size: 12,
                        color: isAdmin ? AppColors.primary : Colors.teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rol,
                        style: TextStyle(
                          fontSize: 11,
                          color: isAdmin ? AppColors.primary : Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Columna de acciones (derecha)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge de estado (Activo/Inactivo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive 
                      ? const Color(0xFFE8F5E9) 
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFFEF5350),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botones de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
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
                  
                  if (onToggleActive != null)
                    InkWell(
                      onTap: onToggleActive,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isActive ? Icons.person_off_outlined : Icons.check_circle_outline,
                          size: 20,
                          color: isActive ? Colors.orange[700] : Colors.green[700],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}