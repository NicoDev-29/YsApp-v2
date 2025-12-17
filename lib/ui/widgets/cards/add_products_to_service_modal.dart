import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/inventory_provider.dart';
import 'package:ysa_app/providers/sales_provider.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/product_model.dart';

class AddProductsToServiceModal extends StatefulWidget {
  final String serviceItemId;
  final String? selectedSalon;

  const AddProductsToServiceModal({
    Key? key,
    required this.serviceItemId,
    this.selectedSalon,
  }) : super(key: key);

  @override
  State<AddProductsToServiceModal> createState() => _AddProductsToServiceModalState();
}

class _AddProductsToServiceModalState extends State<AddProductsToServiceModal> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedProductIds = {};
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _addSelectedProducts(List<ProductModel> allProducts) {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un producto'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2), 
          behavior: SnackBarBehavior.floating, 
        ),
      );
      return;
    }

    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    for (final productId in _selectedProductIds) {
      final product = allProducts.firstWhere((p) => p.id == productId);
      salesProvider.addProductToService(
        widget.serviceItemId,
        productId,
        product.nombre,
      );
    }

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedProductIds.length} producto(s) agregado(s)'),
        backgroundColor: AppColors.activeGreen,
        duration: const Duration(seconds: 1), 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      ),
    );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var filtered = products.where((product) => product.stock > 0).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final searchLower = _searchQuery.toLowerCase();
        return product.nombre.toLowerCase().contains(searchLower) ||
               (product.categoria?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    
    // Obtener el servicio del carrito
    final serviceItem = salesProvider.cartItems.firstWhere(
      (item) => item.id == widget.serviceItemId,
    );
    
    // Obtener IDs de productos ya agregados
    final alreadyAddedIds = serviceItem.productosUsados
        .map((p) => p.productoId)
        .toSet();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Línea superior decorativa
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Título y botón cerrar
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Productos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona los productos a usar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[700],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Buscador
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos con StreamBuilder
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: inventoryProvider.getProducts(idSalon: widget.selectedSalon),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar productos',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos disponibles',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final allProducts = snapshot.data!;
                final products = _filterProducts(allProducts);

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isSelected = _selectedProductIds.contains(product.id);
                    final alreadyAdded = alreadyAddedIds.contains(product.id);

                    return GestureDetector(
                      onTap: alreadyAdded ? null : () => _toggleSelection(product.id),
                      child: Opacity(
                        opacity: alreadyAdded ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: alreadyAdded
                                  ? Colors.grey[300]!
                                  : isSelected
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Imagen
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        color: Colors.grey[200],
                                        child: product.imagen != null && product.imagen!.isNotEmpty
                                            ? Image.network(
                                                product.imagen!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Icon(
                                                      Icons.inventory_2_outlined,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.inventory_2_outlined,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      
                                      // Indicador de ya agregado
                                      if (alreadyAdded)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.activeGreen,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      
                                      // Checkmark si está seleccionado
                                      if (isSelected && !alreadyAdded)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Información
                              SizedBox(
                                height: 58,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.nombre,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        alreadyAdded ? 'Agregado' : 'Stock: ${product.stock}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: alreadyAdded ? AppColors.activeGreen : Colors.grey[600],
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Footer con contador y botón agregar
          StreamBuilder<List<ProductModel>>(
            stream: inventoryProvider.getProducts(idSalon: widget.selectedSalon),
            builder: (context, snapshot) {
              final allProducts = snapshot.data ?? [];
              
              return Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Contador de seleccionados
                    if (_selectedProductIds.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_selectedProductIds.length} producto(s) seleccionado(s)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Botón agregar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _selectedProductIds.isEmpty || allProducts.isEmpty
                            ? null
                            : () => _addSelectedProducts(allProducts),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          _selectedProductIds.isEmpty
                              ? 'Selecciona productos'
                              : 'Agregar seleccionados',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}