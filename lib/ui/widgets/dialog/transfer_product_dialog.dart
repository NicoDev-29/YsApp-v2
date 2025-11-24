import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/inventory_provider.dart';
import 'package:ysa_app/providers/auth_provider.dart';
import 'package:ysa_app/models/product_model.dart';
import 'package:ysa_app/themes/theme.dart';
import '../../widgets/widgets_exports.dart';

class TransferProductDialog extends StatefulWidget {
  final ProductModel product;

  const TransferProductDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<TransferProductDialog> createState() => _TransferProductDialogState();
}

class _TransferProductDialogState extends State<TransferProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidadController = TextEditingController();

  String? _selectedDesde;
  String? _selectedHacia;

  final List<Map<String, String>> _salones = [
    {'id': 'salon_principal', 'nombre': 'Salón Principal'},
    {'id': 'salon_secundario', 'nombre': 'Salón Secundario'},
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDesde = widget.product.idSalon;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _transferir() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que los salones sean diferentes
    if (_selectedDesde == _selectedHacia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar salones diferentes'),
          backgroundColor: AppColors.inactiveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validar que haya suficiente stock
    final cantidad = int.parse(_cantidadController.text);
    if (cantidad > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock insuficiente. Disponible: ${widget.product.stock}'),
          backgroundColor: AppColors.inactiveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await inventoryProvider.transferProduct(
      productId: widget.product.id,
      productName: widget.product.nombre,
      cantidad: cantidad,
      desde: _selectedDesde!,
      hacia: _selectedHacia!,
      userId: authProvider.currentUser!.id,
      userName: authProvider.currentUser!.nombreUsuario,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      SuccessDialog.show(context, '¡Transferencia Exitosa!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inventoryProvider.errorMessage ?? 'Error al transferir'),
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
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                DialogHeader(
                  title: 'Transferir Producto',
                  onClose: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                // Info del producto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderGrey,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.nombre,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stock disponible: ${widget.product.stock}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Desde (bloqueado)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desde',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderGrey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _salones.firstWhere((s) => s['id'] == _selectedDesde)['nombre']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Para
                CustomDropdown(
                  label: 'Para',
                  value: _selectedHacia,
                  items: _salones.where((salon) => salon['id'] != _selectedDesde).toList(),
                  onChanged: (value) => setState(() => _selectedHacia = value),
                  hintText: 'Salón de destino',
                ),

                const SizedBox(height: 16),

                // Cantidad
                CustomTextField(
                  label: 'Cantidad',
                  controller: _cantidadController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la cantidad';
                    }
                    final cantidad = int.tryParse(value);
                    if (cantidad == null || cantidad <= 0) {
                      return 'Cantidad inválida';
                    }
                    if (cantidad > widget.product.stock) {
                      return 'Stock insuficiente';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.borderGrey,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'CANCELAR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _transferir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                                'TRANSFERIR',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}