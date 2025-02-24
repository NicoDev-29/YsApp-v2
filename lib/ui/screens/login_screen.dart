import 'package:flutter/material.dart';
import 'menu_screen.dart';

class LoginScreen extends StatelessWidget {
   
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 222, 43, 115),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 55),
                child: 
                Image.asset(
                  "assets/logo.png",
                  width: 230,
                  height: 230,
                ),
                ),
            ),
            
            //logo
            /*const Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.black,
            ),*/

            /*Image.asset(
              "assets/logo.png",
              width: 230,
              height: 230,
            ),*/

            const SizedBox(height: 10),


            //Correo
            _buildInputField(label: "CORREO"),

            const SizedBox(height: 20),

            //Contraseña
            _buildInputField(label: "CONTRASEÑA", obscureText: true),

            const SizedBox(height: 10),

            //Olvidaste tu contraseña
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //Botón Iniciar Sesión
            ElevatedButton(
              onPressed: () {
                //Navegar al menú 
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MenuScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50, 
                  vertical: 15),
                ),
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),),
    );
  }
}

//Widget para crear los campos de texto
Widget _buildInputField({required String label, bool obscureText =false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      const SizedBox(height: 5),
      TextField(
        obscureText: obscureText,
        //style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],

  );
}