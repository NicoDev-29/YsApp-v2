import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';


class CheckoutScreen extends StatefulWidget {
  final String? selectedSalon; // ← AGREGADO: Recibir salón seleccionado

  const CheckoutScreen({
    Key? key,
    this.selectedSalon, // ← AGREGADO
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'efectivo';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // DETECTAR CAMBIO DE USUARIO Y LIMPIAR CARRITO AUTOMÁTICAMENTE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      salesProvider.checkUserChange(authProvider);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Venta',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom, 
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total card grande
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Monto total',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S/ ${salesProvider.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...salesProvider.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nombre,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.tipo == 'producto'
                                        ? 'S/ ${item.precio.toStringAsFixed(2)} x ${item.cantidad}'
                                        : 'Servicio',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  // Productos usados en servicio
                                  if (item.tipo == 'servicio' &&
                                      item.productosUsados.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    ...item.productosUsados.map((p) => Padding(
                                          padding: const EdgeInsets.only(left: 8, top: 2),
                                          child: Text(
                                            '• ${p.nombre} x${p.cantidad}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.plomo,
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Seleccionar método de pago
              const Text(
                'Seleccionar método de pago',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Opciones de pago (SOLO EFECTIVO Y YAPE)
              _buildPaymentOption(
                icon: Icons.money,
                label: 'Efectivo',
                value: 'efectivo',
              ),

              const SizedBox(height: 12),

              _buildPaymentOption(
                icon: Icons.smartphone,
                label: 'Yape',
                value: 'yape',
              ),

              

              const SizedBox(height: 32),

              // Botón guardar venta
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _completeSale(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar venta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              // ← AGREGADO: Espacio adicional al final
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de opción de pago
  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // Completar venta
  Future<void> _completeSale(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ← CORREGIDO: Usar selectedSalon si existe, sino el del usuario
    final salonId = widget.selectedSalon ?? authProvider.currentUser!.idSalon;

    final success = await salesProvider.completeSale(
      userId: authProvider.currentUser!.id,
      userName: authProvider.currentUser!.nombreUsuario,
      salonId: salonId, // ← CORREGIDO: Usar el salón correcto
      metodoPago: _selectedPaymentMethod,
    );

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (success) {
      // Mostrar diálogo de éxito
      SuccessDialog.show(context, 'Venta registrada exitosamente');

      // Esperar un poco y volver a la pantalla de ventas
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) return;
      
      // Volver a SalesScreen (pop 2 veces)
      Navigator.of(context)
        ..pop() // checkout
        ..pop(); // cart
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(salesProvider.errorMessage ?? 'Error al guardar venta'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}