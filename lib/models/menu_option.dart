import 'package:flutter/material.dart';

class MenuOption {
  final int index;
  final String label;
  final IconData icon;
  final String routeName;
  final List<String> allowedRoles; 

  MenuOption({
    required this.index, 
    required this.label, 
    required this.icon, 
    required this.routeName,
    this.allowedRoles = const ['admin', 'personal'], 
  });
}

final List<MenuOption> menuOptions = [
  MenuOption(
    index: 0, 
    label: 'Vender', 
    icon: Icons.point_of_sale, 
    routeName: '/sales',
    
  ),
  MenuOption(
    index: 1, 
    label: 'Transacciones', 
    icon: Icons.compare_arrows, 
    routeName: '/transactions',
  ),
  MenuOption(
    index: 2, 
    label: 'Inventario', 
    icon: Icons.inventory, 
    routeName: '/inventory',
  ),
  MenuOption(
    index: 3, 
    label: 'Usuarios', 
    icon: Icons.people_alt_outlined, 
    routeName: '/users',
    allowedRoles: const ['admin'],
  ),
  MenuOption(
    index: 4, 
    label: 'Reportes', 
    icon: Icons.bar_chart, 
    routeName: '/reports', 
    allowedRoles: const ['admin'],
  ),
];