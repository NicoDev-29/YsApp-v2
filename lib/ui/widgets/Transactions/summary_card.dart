import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';

class SummaryCard extends StatelessWidget {
  final double totalIngresos;
  final int cantidadTransacciones;
  final List<SaleModel>? sales;

  const SummaryCard({
    Key? key,
    required this.totalIngresos,
    required this.cantidadTransacciones,
    this.sales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular totales por método de pago (si se proporcionan las ventas)
    double totalYape = 0.0;
    double totalEfectivo = 0.0;
    
    if (sales != null) {
      totalYape = sales!
          .where((sale) => sale.metodoPago.toLowerCase() == 'yape')
          .fold(0.0, (sum, sale) => sum + sale.total);
      
      totalEfectivo = sales!
          .where((sale) => sale.metodoPago.toLowerCase() == 'efectivo')
          .fold(0.0, (sum, sale) => sum + sale.total);
    }

    final bool showPaymentBreakdown = sales != null && sales!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE8298F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total e ingresos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Ingresos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${totalIngresos.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$cantidadTransacciones',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ventas',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Desglose por método de pago (solo si hay ventas)
          if (showPaymentBreakdown) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 14),
              height: 1,
              color: Colors.white24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentBreakdown(
                  icon: Icons.phone_android,
                  label: 'Yape',
                  amount: totalYape,
                ),
                Container(
                  width: 1,
                  height: 35,
                  color: Colors.white24,
                ),
                _buildPaymentBreakdown(
                  icon: Icons.payments,
                  label: 'Efectivo',
                  amount: totalEfectivo,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown({
    required IconData icon,
    required String label,
    required double amount,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}