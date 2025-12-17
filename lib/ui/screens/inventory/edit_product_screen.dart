import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/models/product_model.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';


class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;

  String? _selectedSalon;
  String? _selectedCategoria;
  File? _newImage;
  bool _isLoading = false;

  late int _currentStock;

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

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.product.nombre);
    _precioController =
        TextEditingController(text: widget.product.precio.toString());
    _currentStock = widget.product.stock;
    _selectedSalon = widget.product.idSalon;
    _selectedCategoria = widget.product.categoria;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection() async {
    await ImageSourceHelper.showImageSourceOptions(
      context: context,
      onSourceSelected: (source) async {
        final image = await ImageSourceHelper.pickImage(source: source);
        if (image != null) {
          setState(() => _newImage = image);
        }
      },
    );
  }

  Future<void> _showStockAdjustment({required bool isAdding}) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => QuantityAdjustmentDialog(
        title: isAdding ? 'Agregar productos' : 'Restar productos',
        currentStock: _currentStock,
        isAdding: isAdding,
      ),
    );

    if (quantity != null) {
      setState(() {
        if (isAdding) {
          _currentStock += quantity;
        } else {
          _currentStock -= quantity;
        }
      });
    }
  }

  Future<void> _actualizarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await inventoryProvider.editProduct(
      productId: widget.product.id,
      oldProduct: widget.product,
      newData: {
        'nombre': _nombreController.text.trim(),
        'precio': double.parse(_precioController.text),
        'stock': _currentStock,
        'categoria': _selectedCategoria,
        'idSalon': _selectedSalon,
      },
      newImage: _newImage,
      oldImageUrl: widget.product.imagen,
      userId: authProvider.currentUser!.id,
      userName: authProvider.currentUser!.nombreUsuario,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      SuccessDialog.show(context, 'Producto actualizado correctamente');
      
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inventoryProvider.errorMessage ?? 'Error al actualizar'),
          backgroundColor: AppColors.inactiveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Producto',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _handleImageSelection,
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _buildImagePreview(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _handleImageSelection,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Cambiar imagen'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Nombre del producto',
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
                      label: 'Salón',
                      value: _selectedSalon,
                      items: _salones,
                      onChanged: (value) =>
                          setState(() => _selectedSalon = value),
                      hintText: 'Selecciona un salón',
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown(
                      label: 'Categoría',
                      value: _selectedCategoria,
                      items: _categorias,
                      onChanged: (value) =>
                          setState(() => _selectedCategoria = value),
                      hintText: 'Selecciona categoría',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Precio (S/.)',
                      controller: _precioController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _currentStock.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _showStockAdjustment(isAdding: false),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.orange, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.orange,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _showStockAdjustment(isAdding: true),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.activeGreen,
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.activeGreen,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'GUARDAR CAMBIOS',
                onPressed: _actualizarProducto,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_newImage != null) {
      return Image.file(_newImage!, fit: BoxFit.cover);
    }

    if (widget.product.imagen != null && widget.product.imagen!.isNotEmpty) {
      if (widget.product.imagen!.startsWith('http')) {
        return Image.network(
          widget.product.imagen!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
              ),
            );
          },
        );
      } else {
        return Image.file(
          File(widget.product.imagen!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Toca para agregar imagen',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}