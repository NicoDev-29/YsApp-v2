import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import '/../models/models_exports.dart';

class SaleItemRow extends StatefulWidget {
  final SaleItem item;
  final Function(SaleItem) onQuantityChanged;
  final VoidCallback onRemove;

  const SaleItemRow({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<SaleItemRow> createState() => _SaleItemRowState();
}

class _SaleItemRowState extends State<SaleItemRow> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre
          Text(
            widget.item.name,
            style: TextStyle(fontSize: screenWidth * 0.038),
          ),
          // Controles cantidad
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: screenWidth * 0.05),
                onPressed: () {
                  if (widget.item.quantity > 1) {
                    widget.item.quantity--;
                    widget.onQuantityChanged(widget.item);
                    setState(() {});
                  }
                },
              ),
              Text(
                '${widget.item.quantity}',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              IconButton(
                icon: Icon(Icons.add, size: screenWidth * 0.05),
                onPressed: () {
                  widget.item.quantity++;
                  widget.onQuantityChanged(widget.item);
                  setState(() {});
                },
              ),
            ],
          ),
          // Subtotal
          Text(
            'S/. ${widget.item.subtotal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
