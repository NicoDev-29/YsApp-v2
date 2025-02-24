import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
   
  const MenuScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 239, 157, 189),
              Color.fromARGB(255, 232, 113, 163),
              Color.fromARGB(255, 222, 43, 115),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              //Fila 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _menuItem("assets/item1.png", "EMPLEADAS"),
                  const SizedBox(width: 20),
                  _menuItem("assets/item2.png", "CITAS")
                ],
              ),

              const SizedBox(height: 20),

              //Fila 2
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _menuItem("assets/item3.png", "VENTAS"),
                  const SizedBox(width: 20),
                  _menuItem("assets/item4.png", "INVENTARIO")
                ],
              ),

              const SizedBox(height: 20),

              //Fila 3
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 15),
                  _menuItem("assets/item5.png", "REPORTES"),
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

//Widget para el menu
Widget _menuItem(String imagePath, String title) {
  return Column(
    children: [
      Image.asset(imagePath, width:120, height: 120),
      const SizedBox(height: 10),
      SizedBox(
        width: 158,
        child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 222, 43, 115),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 13),
        ),
        child: Text(
          title,
          style: const TextStyle(
            //fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ),
      )
    ],
  );
}