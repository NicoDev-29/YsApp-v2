import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

/// Widget reutilizable para el header de las pantallas principales
class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final bool showAddButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onAddPressed,
    this.showAddButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón de menú drawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          
          // Título centrado
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          
          // Botón de agregar (opcional)
          if (showAddButton && onAddPressed != null)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: onAddPressed,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}