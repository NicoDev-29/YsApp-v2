import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/inventory_provider.dart';
import 'package:ysa_app/models/service_model.dart';
import 'package:ysa_app/themes/theme.dart';
import '../../widgets/widgets_exports.dart';

class EditServiceDialog extends StatefulWidget {
  final ServiceModel service;

  const EditServiceDialog({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _precioController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.service.nombre);
    _precioController = TextEditingController(text: widget.service.precioBase.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _actualizarServicio() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

    final success = await inventoryProvider.updateService(
      widget.service.id,
      {
        'nombre': _nombreController.text.trim(),
        'precioBase': double.parse(_precioController.text),
      },
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      SuccessDialog.show(context, 'Servicio actualizado correctamente');
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
                  title: 'Editar Servicio',
                  onClose: () => Navigator.pop(context),
                ),

                const SizedBox(height: 20),

                // Campo Nombre
                CustomTextField(
                  label: 'Nombre',
                  controller: _nombreController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del servicio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Precio Base
                CustomTextField(
                  label: 'Precio Base (S/.)',
                  controller: _precioController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el precio base';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Precio inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Botón Actualizar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _actualizarServicio,
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
                            'ACTUALIZAR SERVICIO',
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