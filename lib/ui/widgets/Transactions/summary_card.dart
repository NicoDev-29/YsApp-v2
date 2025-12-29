import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

class SummaryCard extends StatelessWidget {
  final double totalIngresos;
  final int cantidadTransacciones;

  const SummaryCard({
    Key? key,
    required this.totalIngresos,
    required this.cantidadTransacciones,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0,2,0,2),
            decoration: BoxDecoration(
              color: AppColors.background2,
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.primary,
              size: 35,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresos Totales',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadTransacciones transaccion${cantidadTransacciones != 1 ? 'es' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'S/ ${totalIngresos.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}