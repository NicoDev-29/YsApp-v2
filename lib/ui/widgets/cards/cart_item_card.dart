import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart'; 

class CartItemCard extends StatefulWidget {
  final CartItemModel item;
  final String? selectedSalon; 

  const CartItemCard({
    Key? key,
    required this.item,
    this.selectedSalon, 
  }) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController _priceController;
  late FocusNode _priceFocusNode;
  bool _isEditingPrice = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.precioFinal.toStringAsFixed(2),
    );
    _priceFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _toggleEditPrice() {
    setState(() {
      if (_isEditingPrice) {
        // Guardar precio
        final newPrice = double.tryParse(_priceController.text);
        if (newPrice != null && newPrice > 0) {
          final salesProvider = Provider.of<SalesProvider>(context, listen: false);
          salesProvider.updateServicePrice(widget.item.id, newPrice);
        } else {
          // Restaurar precio anterior si es inválido
          _priceController.text = widget.item.precioFinal.toStringAsFixed(2);
        }
        _priceFocusNode.unfocus();
      } else {
        // Activar edición y dar focus
        Future.delayed(const Duration(milliseconds: 100), () {
          _priceFocusNode.requestFocus();
        });
      }
      _isEditingPrice = !_isEditingPrice;
    });
  }

  // MÉTODO: Abrir modal de productos
  void _openAddProductsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductsToServiceModal(
        serviceItemId: widget.item.id,
        selectedSalon: widget.selectedSalon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.tipo == 'servicio'
                          ? 'Precio base: S/ ${widget.item.precio.toStringAsFixed(2)}'
                          : 'S/ ${widget.item.precio.toStringAsFixed(2)} unidad',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.item.tipo == 'producto'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.tipo == 'producto' ? 'Producto' : 'Servicio',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.item.tipo == 'producto'
                              ? Colors.blue[700]
                              : Colors.purple[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botón eliminar
              IconButton(
                onPressed: () => salesProvider.removeFromCart(widget.item.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Editor de precio para servicios CON TOGGLE
          if (widget.item.tipo == 'servicio') ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Precio final:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _isEditingPrice ? null : _toggleEditPrice,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:  AppColors.inputFill,
                        border: Border.all(
                          color: _isEditingPrice ? AppColors.primary : AppColors.borderGrey,
                          width: _isEditingPrice ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'S/ ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              focusNode: _priceFocusNode,
                              enabled: _isEditingPrice,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                hintText: '0.00',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón toggle editar/guardar
                Container(
                  decoration: BoxDecoration(
                    color: _isEditingPrice 
                        ? AppColors.activeGreen.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _toggleEditPrice,
                    icon: Icon(
                      _isEditingPrice ? Icons.check_circle : Icons.edit,
                      color: _isEditingPrice ? AppColors.activeGreen : AppColors.primary,
                      size: 22,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Controles de cantidad (solo para productos)
              if (widget.item.tipo == 'producto')
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => salesProvider.decrementQuantity(widget.item.id),
                        icon: const Icon(Icons.remove, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.item.cantidad.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => salesProvider.incrementQuantity(widget.item.id),
                        icon: const Icon(Icons.add, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Botón agregar productos (solo para servicios) - ACTUALIZADO
              if (widget.item.tipo == 'servicio')
                TextButton.icon(
                  onPressed: _openAddProductsModal, // ← USA EL MÉTODO NUEVO
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Agregar productos'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              
              const Spacer(),
              
              // Subtotal
              Text(
                'S/ ${widget.item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          // Productos usados en servicio CON VALIDACIÓN DE STOCK
          if (widget.item.tipo == 'servicio' && widget.item.productosUsados.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos usados:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${widget.item.productosUsados.length} producto(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // ← LISTA DE PRODUCTOS CON VALIDACIÓN DE STOCK
            ...widget.item.productosUsados.map((product) {
              // ← OBTENER STOCK DISPONIBLE DEL PRODUCTO
              return StreamBuilder<List<ProductModel>>(
                stream: Provider.of<InventoryProvider>(context, listen: false)
                    .getProducts(idSalon: widget.selectedSalon),
                builder: (context, snapshot) {
                  // Stock por defecto 999 si no se puede obtener
                  int stockDisponible = 999;
                  
                  if (snapshot.hasData) {
                    final productData = snapshot.data!.firstWhere(
                      (p) => p.id == product.productoId,
                      orElse: () => ProductModel(
                        id: '',
                        nombre: '',
                        precio: 0,
                        stock: 0,
                        categoria: '',
                        idSalon: '',
                      ),
                    );
                    if (productData.id.isNotEmpty) {
                      stockDisponible = productData.stock;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        // Icono de producto
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Nombre del producto con stock
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nombre,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // ← Mostrar stock disponible
                              Text(
                                'Stock: $stockDisponible',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: stockDisponible < 5 ? Colors.orange : Colors.grey[600],
                                  fontWeight: stockDisponible < 5 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Controles de cantidad
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón decrementar
                              InkWell(
                                onTap: () {
                                  if (product.cantidad > 1) {
                                    salesProvider.decrementProductInService(
                                      widget.item.id,
                                      product.productoId,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.remove, size: 14),
                                ),
                              ),
                              
                              // Cantidad
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  product.cantidad.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              
                              // ← BOTÓN INCREMENTAR CORREGIDO CON VALIDACIÓN
                              InkWell(
                                onTap: () {
                                  final success = salesProvider.incrementProductInService(
                                    widget.item.id,
                                    product.productoId,
                                    stockDisponible, // ← VALIDAR STOCK
                                  );
                                  
                                  // ← Mostrar error si no hay stock
                                  if (!success && salesProvider.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(salesProvider.errorMessage!),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    salesProvider.clearError();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.add, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Botón eliminar
                        InkWell(
                          onTap: () => salesProvider.removeProductFromService(
                            widget.item.id,
                            product.productoId,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}