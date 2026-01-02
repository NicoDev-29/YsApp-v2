import 'package:flutter/material.dart';
import 'package:ysa_app/models/movement_model.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:intl/intl.dart';

class MovementItem extends StatelessWidget {
  final MovementModel movement;

  const MovementItem({
    Key? key,
    required this.movement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTipoColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTipoIcono(),
              size: 24,
              color: _getTipoColor(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        movement.productoNombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeChip(),
                  ],
                ),

                const SizedBox(height: 8),

                if (movement.tipo == 'transferencia')
                  _buildTransferenciaRow()
                else
                  _buildSalonRow(),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cantidad: ${_formatCantidad()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getTipoColor(),
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(movement.fecha),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getTipoColor(),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getTipoLabel(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getTipoColor(),
        ),
      ),
    );
  }

  Widget _buildTransferenciaRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            movement.desdeNombre,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.arrow_forward,
            size: 15,
            color: _getTipoColor(),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            movement.haciaNombre,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalonRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            movement.salonNombre,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCantidad() {
    switch (movement.tipo) {
      case 'entrada_manual':
        return '+${movement.cantidad}';
      case 'salida_manual':
        return '-${movement.cantidad}';
      case 'venta':
        return '-${movement.cantidad}';
      case 'ingreso':
        return '+${movement.cantidad}';
      case 'transferencia':
        return '${movement.cantidad}';
      default:
        return '${movement.cantidad}';
    }
  }

  String _getTipoLabel() {
    switch (movement.tipo) {
      case 'transferencia':
        return 'Transferencia';
      case 'entrada_manual':
        return 'Entrada Manual';
      case 'salida_manual':
        return 'Salida Manual';
      case 'ingreso':
        return 'Ingreso';
      case 'venta':
        return 'Venta';
      default:
        return 'Movimiento';
    }
  }

  Color _getTipoColor() {
    switch (movement.tipo) {
      case 'transferencia':
        return AppColors.primary;
      case 'entrada_manual':
        return AppColors.activeGreen;
      case 'salida_manual':
        return Colors.orange;
      case 'ingreso':
        return AppColors.activeGreen;
      case 'venta':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcono() {
    switch (movement.tipo) {
      case 'transferencia':
        return Icons.swap_horiz_rounded;
      case 'entrada_manual':
        return Icons.arrow_upward_rounded;
      case 'salida_manual':
        return Icons.arrow_downward_rounded;
      case 'ingreso':
        return Icons.add_circle_outline_rounded;
      case 'venta':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }
}