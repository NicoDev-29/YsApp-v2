import 'package:flutter/material.dart';
import '../../themes/theme.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int>? onChanged;

  const QuantitySelector({
    Key? key,
    this.initialValue = 0,
    this.onChanged,
  }) : super(key: key);

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _quantity++;
      widget.onChanged?.call(_quantity);
    });
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        widget.onChanged?.call(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * 0.02;
    final buttonSize = screenHeight * 0.035;
    final borderRadius = screenWidth * 0.03;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón "-"
          IconButton(
            icon: Icon(Icons.remove, size: buttonSize, color: AppColors.tertiary),
            onPressed: _decrement,
            splashRadius: buttonSize * 1.2,
          ),

          // Cantidad
          SizedBox(
            width: screenWidth * 0.12,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiary,
              ),
            ),
          ),

          // Botón "+"
          IconButton(
            icon: Icon(Icons.add, size: buttonSize, color: AppColors.tertiary),
            onPressed: _increment,
            splashRadius: buttonSize * 1.2,
          ),
        ],
      ),
    );
  }
}
