import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';
import 'package:ysa_app/services/services_exports.dart';
import '../screens_exports.dart';



class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;
  int currentIndex = 0;
  String? _selectedSalonFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listener para detectar cuando el TextField gana/pierde focus
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });
    
    // Listener para actualizar el botón X cuando cambia el texto
    _searchController.addListener(() {
      setState(() {}); // Actualiza el suffixIcon
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin) {
        _selectedSalonFilter = authProvider.currentUser?.idSalon;
      } else {
        _selectedSalonFilter = 'salon_principal';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final isAdmin = authProvider.isAdmin;

    // 🔥 DETECTAR CAMBIO DE USUARIO Y LIMPIAR CARRITO AUTOMÁTICAMENTE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      salesProvider.checkUserChange(authProvider);
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        drawer: CustomSideMenu(
          userName: authProvider.userName,
          selectedIndex: currentIndex,
          onMenuItemSelected: (index) {
            setState(() {
              currentIndex = index;
            });
            navigateByIndex(context, index);
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header con widget reutilizable (se oculta al buscar)
              if (!_isSearching)
                const CustomAppBar(
                  title: 'VENDER',
                ),

              // Selector de salón (solo admin, se oculta al buscar)
              if (isAdmin && !_isSearching)
                SalonSelector(
                  selectedSalon: _selectedSalonFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedSalonFilter = value;
                    });
                  },
                ),

              // Tabs con widget reutilizable (se ocultan al buscar)
              if (!_isSearching)
                CustomTabBar(
                  controller: _tabController,
                  tabs: const ['Productos', 'Servicios'],
                ),

              // Buscador con widget reutilizable (siempre visible)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  _isSearching ? 16 : 16,
                  16,
                  16,
                ),
                child: CustomSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  isSearching: _isSearching,
                  hintText: _tabController.index == 0
                      ? 'Buscar productos...'
                      : 'Buscar servicios...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  onClear: _clearSearch,
                ),
              ),

              // Contenido de tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(inventoryProvider, salesProvider),
                    _buildServicesTab(inventoryProvider, salesProvider),
                  ],
                ),
              ),

              // Botón flotante del carrito
              _buildCartButton(salesProvider),
            ],
          ),
        ),
      ),
    );
  }

  // Tab de productos
  Widget _buildProductsTab(
    InventoryProvider provider,
    SalesProvider salesProvider,
  ) {
    return StreamBuilder<List<ProductModel>>(
      stream: provider.getProducts(idSalon: _selectedSalonFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay productos disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!.where((product) {
          if (!product.activo || product.stock <= 0) return false;
          if (_searchQuery.isEmpty) return true;
          return product.nombre.toLowerCase().contains(_searchQuery);
        }).toList();

        if (products.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron productos',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            
            // Verificar si el producto ya está en el carrito
            final isSelected = salesProvider.cartItems.any(
              (item) => item.productoId == product.id && item.tipo == 'producto',
            );
            
            return ProductGridItem(
              product: product,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  // Si ya está seleccionado, eliminarlo del carrito
                  final cartItem = salesProvider.cartItems.firstWhere(
                    (item) => item.productoId == product.id && item.tipo == 'producto',
                  );
                  salesProvider.removeFromCart(cartItem.id);
                } else {
                  // Si no está, agregarlo al carrito
                  salesProvider.addProductToCart(
                    product.id,
                    product.nombre,
                    product.precio,
                    product.imagen,
                    product.stock,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Tab de servicios
  Widget _buildServicesTab(
    InventoryProvider provider,
    SalesProvider salesProvider,
  ) {
    return StreamBuilder<List<ServiceModel>>(
      stream: provider.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_cut, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No hay servicios disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final services = snapshot.data!.where((service) {
          if (!service.activo) return false;
          if (_searchQuery.isEmpty) return true;
          return service.nombre.toLowerCase().contains(_searchQuery);
        }).toList();

        if (services.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron servicios',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            
            // Verificar si el servicio ya está en el carrito
            final isSelected = salesProvider.cartItems.any(
              (item) => item.servicioId == service.id && item.tipo == 'servicio',
            );
            
            return ServiceListItem(
              service: service,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  // Si ya está seleccionado, eliminarlo del carrito
                  final cartItem = salesProvider.cartItems.firstWhere(
                    (item) => item.servicioId == service.id && item.tipo == 'servicio',
                  );
                  salesProvider.removeFromCart(cartItem.id);
                } else {
                  // Si no está, agregarlo al carrito
                  salesProvider.addServiceToCart(
                    service.id,
                    service.nombre,
                    service.precioBase,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Botón del carrito
  Widget _buildCartButton(SalesProvider salesProvider) {
    final hasItems = salesProvider.cartItemCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasItems
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(
                        selectedSalon: _selectedSalonFilter, // ← Pasar salón seleccionado
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasItems ? AppColors.primary : Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: hasItems ? 2 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: hasItems ? Colors.white : Colors.grey[500],
              ),
              const SizedBox(width: 12),
              Text(
                hasItems
                    ? '${salesProvider.cartItemCount} item${salesProvider.cartItemCount > 1 ? 's' : ''} = S/ ${salesProvider.cartTotal.toStringAsFixed(2)}'
                    : 'Ningún ítem',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: hasItems ? Colors.white : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}