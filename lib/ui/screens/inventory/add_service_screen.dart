import 'package:flutter/material.dart';
import 'package:ysa_app/ui/widgets/image_selector.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import 'dart:io';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  String? _selectedSalon;
  String? _selectedCategoria;
  final TextEditingController _servicioController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  File? _selectedImage;

  final List<String> _salones = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _categorias = ['Corte', 'Peinado', 'Tinte'];

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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomHeader(
                        title: 'SERVICIO',
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

                      // Input Servicio
                      CustomInputField(
                        label: 'Servicio',
                        controller: _servicioController,
                      ),
                      SizedBox(height: inputVerticalSpacing),

                      // Precio
                      CustomInputField(
                        label: 'Precio',
                        controller: _precioController,
                        inputType: TextInputType.number,
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
                            // Acción para agregar servicio
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
