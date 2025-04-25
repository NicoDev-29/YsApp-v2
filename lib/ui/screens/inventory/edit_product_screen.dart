import 'package:flutter/material.dart';
import 'package:ysa_app/ui/widgets/image_selector.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import 'dart:io';
import '/../models/models_exports.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String? _selectedSalon;
  String? _selectedCategoria;
  late TextEditingController _productoController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  File? _selectedImage;

  final List<String> _salones = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _categorias = [
    'Categoria 1',
    'Categoria 2',
    'Categoria 3'
  ];

  @override
  void initState() {
    super.initState();

    // Inicializa los controladores con valores del producto o cadena vacía si nulos
    _productoController = TextEditingController(text: widget.product.name ?? '');
    _precioController = TextEditingController(text: widget.product.price?.toString() ?? '');
    _stockController = TextEditingController(text: widget.product.stock?.toString() ?? '');

    // Inicializa dropdowns con null o valores si tienes en modelo
    _selectedSalon = null;
    _selectedCategoria = null;
  }

  @override
  void dispose() {
    _productoController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = (screenWidth * 0.07).clamp(20.0, 40.0);
    final inputVerticalSpacing = screenHeight * 0.025;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text(
          'Atrás',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                      title: 'EDITAR PRODUCTO',
                      imagePath: 'assets/item4.png',
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Dropdown Salón
                    CustomDropdownField<String>(
                      label: 'Salon',
                      value: _selectedSalon,
                      items: _salones
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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

                    // Botón Guardar cambios
                    Center(
                      child: CustomButton(
                        label: 'GUARDAR CAMBIOS',
                        onPressed: () {
                          // Por ahora solo cierra la pantalla
                          Navigator.pop(context);
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
