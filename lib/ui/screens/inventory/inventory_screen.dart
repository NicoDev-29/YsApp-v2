import 'package:flutter/material.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '../screens_exports.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                // Header
                const CustomHeader(
                  title: 'INVENTARIO',
                  imagePath: 'assets/item4.png',
                ),
                SizedBox(height: screenHeight * 0.01),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: InventorySectionTitle(label: 'Productos'),
                ),

                InventoryMenuButton(
                  label: 'Agregar nueva categoría',
                  onTap: () async {
                    final newCategoryName = await showDialog<String>(
                      context: context,
                      builder: (context) => const NewCategoryDialog(),
                    );

                    // Haz algo con el nombre de la nueva categoría (si se agregó)
                    if (newCategoryName != null && newCategoryName.isNotEmpty) {
                      // Agrega la categoría a tu lista o base de datos
                      print('Nueva categoría agregada: $newCategoryName');
                    }
                  },
                ),

                InventoryMenuButton(
                  label: 'Agregar nuevo producto',
                  onTap: () {},
                ),
                InventoryMenuButton(
                  label: 'Visualizar productos',
                  onTap: () {},
                ),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: InventorySectionTitle(label: 'Servicios'),
                ),

                InventoryMenuButton(
                  label: 'Agregar nuevo servicio',
                  onTap: () {},
                ),
                InventoryMenuButton(
                  label: 'Visualizar servicios',
                  onTap: () {},
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }
}
