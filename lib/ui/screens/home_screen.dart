import 'package:flutter/material.dart';
import '../../themes/theme.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradient1, 
              AppColors.gradient2,
              AppColors.gradient3,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Fila 1
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem("assets/item1.png", "EMPLEADAS", screenWidth),
                  const SizedBox(width: 20),
                  _menuItem("assets/item3.png", "VENTAS", screenWidth),
                ],
              ),
            
              const SizedBox(height: 50),

              // Fila 2
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem("assets/item4.png", "INVENTARIO", screenWidth),
                  const SizedBox(width: 20),
                  _menuItem("assets/item5.png", "REPORTES", screenWidth),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para el menu
Widget _menuItem(String imagePath, String title, double screenWidth) {
  double buttonWidth = screenWidth * 0.4; 

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(imagePath, width: 120, height: 120),
      const SizedBox(height: 10),
      SizedBox(
        width: buttonWidth, 
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13), 
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}
