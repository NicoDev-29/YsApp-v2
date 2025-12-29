import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/sale_model.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onTap;

  const TransactionCard({
    Key? key,
    required this.sale,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cantProductos = sale.items.where((i) => i.tipo == 'producto').length;
    final cantServicios = sale.items.where((i) => i.tipo == 'servicio').length;

    // ✅ ÚNICO CAMBIO: Formatear número con día
    // Formato: #DIA-NUM → Ejemplo: #23-001
    final dia = DateFormat('dd').format(sale.fecha);
    final numeroVenta = sale.numeroVentaDia.toString().padLeft(3, '0');
    final numeroDisplay = '#$dia-$numeroVenta';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.attach_money,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Venta $numeroDisplay', // ✅ Cambiado de sale.numeroDisplay a numeroDisplay
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(sale.fecha), // ✅ Solo hora
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (cantProductos > 0)
                        _buildTag(
                          '$cantProductos producto${cantProductos > 1 ? 's' : ''}',
                          Colors.blue,
                        ),
                      if (cantServicios > 0)
                        _buildTag(
                          '$cantServicios servicio${cantServicios > 1 ? 's' : ''}',
                          Colors.purple,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${sale.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentColor(sale.metodoPago),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getPaymentLabel(sale.metodoPago),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  Color _getPaymentColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'yape':
        return const Color(0xFF6C2A8B);
      case 'efectivo':
        return Colors.green;
      case 'tarjeta':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentLabel(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'yape':
        return 'Yape';
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      default:
        return metodo;
    }
  }
}