import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/inventory_provider.dart';
import 'package:ysa_app/models/product_model.dart';
import 'package:ysa_app/themes/theme.dart';
import '../../widgets/widgets_exports.dart';

class EditProductDialog extends StatefulWidget {
  final ProductModel product;

  const EditProductDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenController;

  String? _selectedSalon;
  String? _selectedCategoria;

  final List<Map<String, String>> _salones = [
    {'id': 'salon_principal', 'nombre': 'Salón Principal'},
    {'id': 'salon_secundario', 'nombre': 'Salón Secundario'},
  ];

  final List<Map<String, String>> _categorias = [
    {'id': 'tintes', 'nombre': 'Tintes'},
    {'id': 'champus', 'nombre': 'Champús'},
    {'id': 'cremas', 'nombre': 'Cremas'},
    {'id': 'tratamientos', 'nombre': 'Tratamientos'},
    {'id': 'accesorios', 'nombre': 'Accesorios'},
    {'id': 'otros', 'nombre': 'Otros'},
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.product.nombre);
    _precioController = TextEditingController(text: widget.product.precio.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _imagenController = TextEditingController(text: widget.product.imagen ?? '');
    _selectedSalon = widget.product.idSalon;
    _selectedCategoria = widget.product.categoria;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  Future<void> _actualizarProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    final success = await inventoryProvider.updateProduct(
      widget.product.id,
      {
        'nombre': _nombreController.text.trim(),
        'precio': double.parse(_precioController.text),
        'stock': int.parse(_stockController.text),
        'categoria': _selectedCategoria,
        'idSalon': _selectedSalon,
        'imagen': _imagenController.text.trim().isEmpty 
            ? null 
            : _imagenController.text.trim(),
      },
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto actualizado correctamente'),
          backgroundColor: AppColors.activeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar Producto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.primary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Campo Nombre
                _buildTextField(
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

                // Salón y Categoría en fila
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Salon',
                        value: _selectedSalon,
                        items: _salones,
                        onChanged: (value) => setState(() => _selectedSalon = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Categoria',
                        value: _selectedCategoria,
                        items: _categorias,
                        onChanged: (value) => setState(() => _selectedCategoria = value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Precio y Stock en fila
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Precio (S/.)',
                        controller: _precioController,
                        keyboardType: TextInputType.number,
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
                      child: _buildTextField(
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

                // Campo Imagen (Opcional)
                _buildTextField(
                  label: 'Imagen (Opcional)',
                  controller: _imagenController,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 24),

                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _actualizarProducto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Actualizar Producto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  // Widget para campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Widget para dropdowns
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item['id'],
                    child: Text(
                      item['nombre']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una opción';
            }
            return null;
          },
        ),
      ],
    );
  }
}