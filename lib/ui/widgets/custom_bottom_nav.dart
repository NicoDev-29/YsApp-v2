import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/screens/screens_exports.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.primary;

    final List<IconData> icons = [
      Icons.people,       
      Icons.inventory,
      Icons.home,          
      Icons.point_of_sale, 
      Icons.bar_chart, 
    ];

    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isSelected = index == currentIndex;
          return IconButton(
            icon: Icon(
              icons[index],
              color: isSelected ? AppColors.tertiary : AppColors.secondary,
              size: 32,
            ),
            onPressed: () => _onItemTapped(context, index), 
          );
        }),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    // Definimos las rutas según el índice
    Widget screen;
    switch (index) {
      case 0:
        screen = const EmployeesScreen();
        break;
      case 1:
        screen = const InventoryScreen();
        break;
      case 2:
        screen = const HomeScreen();
        break;
      case 3:
        screen =  SalesScreen();
        break;
      default:
        screen = const EmployeesScreen(); 
    }

    // Navega a la pantalla seleccionada
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}