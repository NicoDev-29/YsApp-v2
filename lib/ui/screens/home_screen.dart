import 'package:flutter/material.dart';
import 'screens_exports.dart';
import '../../themes/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradient1,
              AppColors.gradient2,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem(
                      "assets/employee.png", "PERSONAL", screenWidth, context),
                  const SizedBox(width: 20),
                  _menuItem("assets/item3.png", "VENTAS", screenWidth, context),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _menuItem(
                      "assets/item4.png", "INVENTARIO", screenWidth, context),
                  const SizedBox(width: 20),
                  _menuItem(
                      "assets/item5.png", "REPORTES", screenWidth, context),
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

Widget _menuItem(
    String imagePath, String title, double screenWidth, BuildContext context) {
  double buttonWidth = screenWidth * 0.4;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(imagePath, width: 120, height: 120),
      const SizedBox(height: 10),
      SizedBox(
        width: buttonWidth,
        child: ElevatedButton(
          onPressed: () {
            if (title == "PERSONAL") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PersonalScreen()),
              );
            } else if (title == "INVENTARIO") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InventoryScreen()),
              );
            } else if (title == "VENTAS"){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  SalesScreen()),
              );
            }
          },
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
