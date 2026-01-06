import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/auth_provider.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/ui/screens/screens_exports.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';


class CustomSideMenu extends StatelessWidget {
  final String userName;
  final Function(int) onMenuItemSelected;
  final int selectedIndex;

  const CustomSideMenu({
    Key? key,
    required this.userName,
    required this.onMenuItemSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.currentUser?.idRol ?? 'personal';
    final userEmail = authProvider.currentUser?.email ?? '';

    // Filtrar opciones según el rol del usuario
    final filteredOptions = menuOptions.where((option) {
      return option.allowedRoles.contains(userRole);
    }).toList();

    return Drawer(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header con logo y botón cerrar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 15, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/logo.png',
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    // Texto Ysabella
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ysabella',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'RESALTANDO TU BELLEZA',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón cerrar menú
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      color: Colors.grey[700],
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Opciones del menú
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    final item = filteredOptions[index];
                    final selected = item.index == selectedIndex;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Icon(
                          item.icon,
                          size: 26,
                          color: selected ? Colors.white : AppColors.primary,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                // BADGE SOLO EN NOTIFICACIONES
                                if (item.label == 'Notificaciones') ...[
                                  const SizedBox(width: 8),
                                  const NotificationBadge(),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getSubtitle(item.label),
                              style: TextStyle(
                                fontSize: 12,
                                color: selected 
                                    ? Colors.white.withOpacity(0.9) 
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onMenuItemSelected(item.index);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Footer con información del usuario
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Cerrar drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Avatar con inicial
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person_outline,
                            size: 26,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Información del usuario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Flecha ir a perfil
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Obtener subtítulo según la opción del menú
  String _getSubtitle(String label) {
    switch (label) {
      case 'Vender':
        return 'Registrar ventas';
      case 'Transacciones':
        return 'Ver historial de ventas';
      case 'Inventario':
        return 'Productos y servicios';
      case 'Usuarios':
        return 'Gestión de usuarios';
      case 'Notificaciones':
        return 'Alertas de stock bajo';
      case 'Reportes':
        return 'Análisis del negocio';
      default:
        return '';
    }
  }
}