import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/services/pdf/inventory_pdf_service.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({Key? key}) : super(key: key);

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  String? _selectedSalon;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin) {
        _selectedSalon = authProvider.currentUser?.idSalon;
      } else {
        _selectedSalon = 'salon_principal';
      }
      setState(() {});
    });
  }

  Future<void> _exportToPdf(List<ProductModel> products) async {
    setState(() => _isExporting = true);

    try {
      await InventoryPdfService.generateLowStockReport(
        products,
        _selectedSalon ?? 'todos',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: const Text(
            'Productos por Agotarse',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.grey[200],
              height: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(Icons.store, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGrey),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSalon,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'salon_principal',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Salón Principal'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'salon_secundario',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[400],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Salón Secundario'),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'todos',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[600],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Todos los salones'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSalon = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Expanded(
                    child: StreamBuilder<List<ProductModel>>(
                      stream: inventoryProvider.getProducts(
                        idSalon: _selectedSalon == 'todos' ? null : _selectedSalon,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Error al cargar productos',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final allProducts = snapshot.data!;
                        final lowStockProducts = allProducts.where((product) {
                          return product.stock < product.stockMinimo;
                        }).toList();

                        lowStockProducts.sort((a, b) {
                          final ratioA = a.stock / a.stockMinimo;
                          final ratioB = b.stock / b.stockMinimo;
                          return ratioA.compareTo(ratioB);
                        });

                        if (lowStockProducts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, 
                                    size: 80, 
                                    color: AppColors.activeGreen),
                                const SizedBox(height: 20),
                                const Text(
                                  '¡Todo en orden!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay productos por agotarse',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final criticalCount = lowStockProducts.where((p) => 
                          p.stock / p.stockMinimo < 0.5
                        ).length;

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: const Color(0xFFFFF8E1),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, 
                                      color: Color(0xFFFFA726), 
                                      size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${lowStockProducts.length}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: ' producto${lowStockProducts.length != 1 ? 's' : ''} con stock bajo',
                                          ),
                                          if (criticalCount > 0) ...[
                                            const TextSpan(text: ' • '),
                                            TextSpan(
                                              text: '$criticalCount crítico${criticalCount != 1 ? 's' : ''}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.inactiveRed,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: lowStockProducts.length,
                                itemBuilder: (context, index) {
                                  final product = lowStockProducts[index];
                                  return _buildProductCard(product);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Loading overlay
              if (_isExporting)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 16),
                            Text(
                              'Generando PDF...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: _isExporting
            ? null
            : FloatingActionButton.extended(
                onPressed: () async {
                  final allProducts = await inventoryProvider
                      .getProducts(
                        idSalon: _selectedSalon == 'todos' ? null : _selectedSalon,
                      )
                      .first;

                  final lowStockProducts = allProducts.where((product) {
                    return product.stock < product.stockMinimo;
                  }).toList();

                  if (lowStockProducts.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay productos con stock bajo para exportar'),
                        ),
                      );
                    }
                    return;
                  }

                  await _exportToPdf(lowStockProducts);
                },
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: Colors.black87,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'Exportar PDF',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final stockRatio = product.stock / product.stockMinimo;
    final isCritical = stockRatio < 0.5;
    final showSalon = _selectedSalon == 'todos';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? AppColors.inactiveRed : const Color(0xFFFFD54F),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCritical ? AppColors.inactiveRed : const Color(0xFFFFD54F))
                .withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.categoria,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (showSalon) ...[
                          Text(' • ', style: TextStyle(color: Colors.grey[400])),
                          Icon(Icons.store, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            product.salonName,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCritical 
                      ? AppColors.inactiveRed.withOpacity(0.1)
                      : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCritical ? Icons.error : Icons.warning_amber_rounded,
                      size: 16,
                      color: isCritical ? AppColors.inactiveRed : const Color(0xFFFFA726),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCritical ? 'Crítico' : 'Bajo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCritical ? AppColors.inactiveRed : const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStockInfo(
                        label: 'Stock Actual',
                        value: product.stock.toString(),
                        color: isCritical ? AppColors.inactiveRed : const Color(0xFFFFA726),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    Expanded(
                      child: _buildStockInfo(
                        label: 'Stock Mínimo',
                        value: product.stockMinimo.toString(),
                        color: Colors.grey[700]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stockRatio.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCritical ? AppColors.inactiveRed : const Color(0xFFFFA726),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}