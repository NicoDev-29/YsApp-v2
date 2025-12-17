import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';
import 'package:ysa_app/services/services_exports.dart';

import '../screens_exports.dart';


class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int currentIndex = 2;

  // Filtro de salón
  String? _selectedSalonFilter = 'salon_principal';
  
  // Filtro de tipo de movimiento
  String _tipoMovimientoFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_tabController.index == 0) {
      showDialog(
        context: context,
        builder: (context) => AddProductDialog(
          userSalon: authProvider.currentUser?.idSalon ?? '',
        ),
      );
    } else if (_tabController.index == 1) {
      showDialog(
        context: context,
        builder: (context) => const AddServiceDialog(),
      );
    }
  }

  Future<void> _toggleProductActive(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          product.activo ? '¿Desactivar producto?' : '¿Activar producto?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          product.activo
              ? '${product.nombre} no estará disponible para ventas.'
              : '${product.nombre} estará disponible para ventas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  product.activo ? Colors.orange : AppColors.activeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              product.activo ? 'Desactivar' : 'Activar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final inventoryProvider =
          Provider.of<InventoryProvider>(context, listen: false);
      await inventoryProvider
          .updateProduct(product.id, {'activo': !product.activo});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product.activo
                  ? '${product.nombre} desactivado'
                  : '${product.nombre} activado',
            ),
            backgroundColor:
                product.activo ? Colors.orange : AppColors.activeGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleServiceActive(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          service.activo ? '¿Desactivar servicio?' : '¿Activar servicio?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          service.activo
              ? '${service.nombre} no estará disponible para ventas.'
              : '${service.nombre} estará disponible para ventas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  service.activo ? Colors.orange : AppColors.activeGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              service.activo ? 'Desactivar' : 'Activar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final inventoryProvider =
          Provider.of<InventoryProvider>(context, listen: false);
      await inventoryProvider
          .updateService(service.id, {'activo': !service.activo});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              service.activo
                  ? '${service.nombre} desactivado'
                  : '${service.nombre} activado',
            ),
            backgroundColor:
                service.activo ? Colors.orange : AppColors.activeGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Widget de filtros para movimientos
  Widget _buildMovementFilters() {
    final filters = [
      {'value': 'todos', 'label': 'Todos', 'icon': Icons.grid_view},
      {'value': 'transferencia', 'label': 'Transferencias', 'icon': Icons.swap_horiz},
      {'value': 'entrada_manual', 'label': 'Entradas', 'icon': Icons.arrow_upward},
      {'value': 'salida_manual', 'label': 'Salidas', 'icon': Icons.arrow_downward},
      {'value': 'ingreso', 'label': 'Ingresos', 'icon': Icons.add_circle_outline},
      {'value': 'venta', 'label': 'Ventas', 'icon': Icons.shopping_cart_outlined},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _tipoMovimientoFilter == filter['value'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(filter['label'] as String),
                ],
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (selected) {
                setState(() {
                  _tipoMovimientoFilter = filter['value'] as String;
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final isAdmin = authProvider.isAdmin;

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
              // Header con widget reutilizable
              CustomAppBar(
                title: 'INVENTARIO',
                showAddButton: isAdmin && _tabController.index != 2,
                onAddPressed: _showAddDialog,
              ),

              // Selector de Salón (aparece en todas las tabs para admin)
              if (isAdmin)
                SalonSelector(
                  selectedSalon: _selectedSalonFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedSalonFilter = value;
                    });
                  },
                ),

              // Tabs con widget reutilizable
              CustomTabBar(
                controller: _tabController,
                tabs: const ['Products', 'Services', 'Movi'],
                onTap: (index) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 10),

              // Mostrar según la tab activa
              if (_tabController.index == 2)
                _buildMovementFilters()
              else
                // Buscador con widget reutilizable
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Buscar',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(inventoryProvider, isAdmin),
                    _buildServicesTab(inventoryProvider, isAdmin),
                    _buildMovementsTab(inventoryProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab(InventoryProvider provider, bool isAdmin) {
    return StreamBuilder<List<ProductModel>>(
      stream: provider.getProducts(idSalon: _selectedSalonFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            message: 'No hay productos registrados',
          );
        }

        final products = snapshot.data!.where((product) {
          if (_searchQuery.isEmpty) return true;
          return product.nombre.toLowerCase().contains(_searchQuery);
        }).toList();

        if (products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off,
            message: 'No se encontraron productos',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              showActions: isAdmin,
              onEdit: isAdmin
                  ? () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  EditProductScreen(product: product),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            final tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    }
                  : null,
              onToggleActive:
                  isAdmin ? () => _toggleProductActive(product) : null,
              onTransfer: isAdmin
                  ? () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            TransferProductDialog(product: product),
                      );
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildServicesTab(InventoryProvider provider, bool isAdmin) {
    return StreamBuilder<List<ServiceModel>>(
      stream: provider.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.content_cut,
            message: 'No hay servicios registrados',
          );
        }

        final services = snapshot.data!.where((service) {
          if (_searchQuery.isEmpty) return true;
          return service.nombre.toLowerCase().contains(_searchQuery);
        }).toList();

        if (services.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off,
            message: 'No se encontraron servicios',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              showActions: isAdmin,
              onEdit: isAdmin
                  ? () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            EditServiceDialog(service: service),
                      );
                    }
                  : null,
              onToggleActive:
                  isAdmin ? () => _toggleServiceActive(service) : null,
            );
          },
        );
      },
    );
  }

  Widget _buildMovementsTab(InventoryProvider provider) {
    return StreamBuilder<List<MovementModel>>(
      stream: provider.getMovements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.swap_horiz,
            message: 'No hay movimientos registrados',
          );
        }

        // Filtrar movimientos por salón y tipo
        final movements = snapshot.data!.where((movement) {
          // Filtro por salón
          bool matchesSalon = _selectedSalonFilter == null ||
              movement.desde == _selectedSalonFilter ||
              movement.hacia == _selectedSalonFilter ||
              movement.salonId == _selectedSalonFilter;
          
          // Filtro por tipo
          bool matchesTipo = _tipoMovimientoFilter == 'todos' ||
              movement.tipo == _tipoMovimientoFilter;
          
          return matchesSalon && matchesTipo;
        }).toList();

        if (movements.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.filter_alt_off,
            message: 'No hay movimientos con estos filtros',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            return MovementItem(movement: movements[index]);
          },
        );
      },
    );
  }
}