import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/models/product_model.dart';
import 'package:ysa_app/themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import 'dart:io';

class AddProductDialog extends StatefulWidget {
  final String userSalon;

  const AddProductDialog({
    Key? key,
    required this.userSalon,
  }) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _stockMinimoController = TextEditingController(text: '5');

  String? _selectedSalon;
  String? _selectedCategoria;
  File? _selectedImage;

  final List<Map<String, String>> _salones = [
    {'id': 'salon_principal', 'nombre': 'Salón Principal'},
    {'id': 'salon_secundario', 'nombre': 'Salón Secundario'},
  ];

  final List<Map<String, String>> _categorias = [
    {'id': 'tintes', 'nombre': 'Tintes'},
    {'id': 'champus', 'nombre': 'Champús y Acondicionadores'},
    {'id': 'tratamientos', 'nombre': 'Tratamientos'},
    {'id': 'cremas', 'nombre': 'Cremas'},
    {'id': 'unas', 'nombre': 'Productos de Uñas'},
    {'id': 'spray', 'nombre': 'Sprays y Lacas'},
    {'id': 'accesorios', 'nombre': 'Accesorios'},
    {'id': 'otros', 'nombre': 'Otros'},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection() async {
    await ImageSourceHelper.showImageSourceOptions(
      context: context,
      onSourceSelected: (source) async {
        final image = await ImageSourceHelper.pickImage(source: source);
        if (image != null) {
          setState(() => _selectedImage = image);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se seleccionó ninguna imagen'),
                backgroundColor: AppColors.inactiveRed,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _agregarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    final product = ProductModel(
      id: '',
      nombre: _nombreController.text.trim(),
      precio: double.parse(_precioController.text),
      stock: int.parse(_stockController.text),
      stockMinimo: int.parse(_stockMinimoController.text),
      categoria: _selectedCategoria!,
      idSalon: _selectedSalon!,
      imagen: _selectedImage?.path,
      activo: true,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await inventoryProvider.addProduct(
      product,
      authProvider.currentUser!.id,
      authProvider.currentUser!.nombreUsuario,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      SuccessDialog.show(context, 'Producto agregado correctamente');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              inventoryProvider.errorMessage ?? 'Error al agregar producto'),
          backgroundColor: AppColors.inactiveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                DialogHeader(
                  title: 'Añadir Producto',
                  onClose: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Nombre',
                  controller: _nombreController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del producto';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomDropdown(
                  label: 'Salon',
                  value: _selectedSalon,
                  items: _salones,
                  onChanged: (value) => setState(() => _selectedSalon = value),
                  hintText: 'Selecciona un salón',
                ),

                const SizedBox(height: 16),

                CustomDropdown(
                  label: 'Categoria',
                  value: _selectedCategoria,
                  items: _categorias,
                  onChanged: (value) =>
                      setState(() => _selectedCategoria = value),
                  hintText: 'Selecciona una categoría',
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Precio (S/.)',
                        controller: _precioController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el precio';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Stock',
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el stock';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Stock inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Stock Mínimo',
                  controller: _stockMinimoController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el stock mínimo';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Stock inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                ImagePickerWidget(
                  selectedImage: _selectedImage,
                  onTap: _handleImageSelection,
                  label: 'Imagen (Opcional)',
                  placeholderText: 'Toca para seleccionar',
                  height: 120,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _agregarProducto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'AÑADIR PRODUCTO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}