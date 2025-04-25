import 'package:flutter/material.dart';
import 'package:ysa_app/ui/widgets/image_selector.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import 'dart:io'; 

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? _selectedSalon;
  String? _selectedCategoria;
  final TextEditingController _productoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  File? _selectedImage; 

  final List<String> _salones = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _categorias = [
    'Categoria 1',
    'Categoria 2',
    'Categoria 3'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = (screenWidth * 0.07).clamp(20.0, 40.0);
    final inputVerticalSpacing = screenHeight * 0.025;
    final double imageHeight = screenHeight * 0.17;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text(
          'Atrás',
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomHeader(
                      title: 'PRODUCTO',
                      imagePath: 'assets/item4.png',
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Dropdown Salón
                    CustomDropdownField<String>(
                      label: 'Salon',
                      value: _selectedSalon,
                      items: _salones
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSalon = value;
                        });
                      },
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Input Producto
                    CustomInputField(
                      label: 'Producto',
                      controller: _productoController,
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Dropdown Categoría
                    CustomDropdownField<String>(
                      label: 'Categoria',
                      value: _selectedCategoria,
                      items: _categorias
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoria = value;
                        });
                      },
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Precio y Stock en una fila
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            label: 'Precio',
                            controller: _precioController,
                            inputType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),
                        Expanded(
                          child: CustomInputField(
                            label: 'Stock',
                            controller: _stockController,
                            inputType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: inputVerticalSpacing),

                    // Selector de Imagen
                    ImageSelector(
                      label: 'Imagen',
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Botón Agregar
                    Center(
                      child: CustomButton(
                        label: 'AGREGAR',
                        onPressed: () {
                          // Acción para agregar producto (ahora tienes _selectedImage)
                        },
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.13,
                          vertical: screenHeight * 0.018,
                        ),
                        borderRadius: 25,
                        elevation: 8,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
