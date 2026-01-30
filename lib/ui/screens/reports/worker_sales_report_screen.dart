import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/services_exports.dart';
import 'package:ysa_app/themes/theme.dart';

class WorkerSalesReportScreen extends StatefulWidget {
  const WorkerSalesReportScreen({Key? key}) : super(key: key);

  @override
  State<WorkerSalesReportScreen> createState() => _WorkerSalesReportScreenState();
}

class _WorkerSalesReportScreenState extends State<WorkerSalesReportScreen> {
  String? selectedWorkerId;
  String? selectedWorkerName;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  bool isGeneratingPdf = false;
  
  String selectedFilter = 'todas';

  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin) {
        selectedWorkerId = authProvider.currentUser?.id;
        selectedWorkerName = authProvider.currentUser?.nombreUsuario;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Ventas por Trabajadora',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
          child: Column(
            children: [
              // FILTROS
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de trabajadora (solo admin)
                    if (isAdmin)
                      StreamBuilder<List<UserModel>>(
                        stream: salesProvider.getUsers(),
                        builder: (context, snapshot) {
                          final users = snapshot.data ?? [];
                          
                          return Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedWorkerId,
                                          isExpanded: true,
                                          hint: const Text('Seleccionar trabajadora'),
                                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          items: users.map((user) {
                                            return DropdownMenuItem(
                                              value: user.id,
                                              child: Text(user.nombreUsuario),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              final user = users.firstWhere((u) => u.id == value);
                                              setState(() {
                                                selectedWorkerId = value;
                                                selectedWorkerName = user.nombreUsuario;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),

                    // Selectores de fecha
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectStartDate(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Desde',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(startDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectEndDate(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hasta',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          dateFormat.format(endDate),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Filtros de tipo de venta
                    const SizedBox(height: 12),
                    const Text(
                      'Filtrar por tipo:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('Todas', 'todas', Icons.receipt_long, Colors.grey),
                        _buildFilterChip('Con productos', 'con_productos', Icons.shopping_bag, Colors.orange),
                        _buildFilterChip('Solo Servicios', 'sin_productos', Icons.spa, Colors.green),
                        _buildFilterChip('Solo productos', 'solo_productos', Icons.inventory_2, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),

              // CONTENIDO
              Expanded(
                child: selectedWorkerId == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Selecciona una trabajadora',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<List<SaleModel>>(
                        stream: salesProvider.getSales(
                          userId: selectedWorkerId,
                          startDate: startDate,
                          endDate: endDate,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final allSales = snapshot.data ?? [];
                          final filteredSales = _filterSales(allSales);

                          if (filteredSales.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay ventas con este filtro',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          }

                          final totalSales = filteredSales.fold(0.0, (sum, sale) => sum + sale.total);
                          final totalTransactions = filteredSales.length;

                          // Calcular totales por método de pago
                          final totalYape = filteredSales
                              .where((sale) => sale.metodoPago.toLowerCase() == 'yape')
                              .fold(0.0, (sum, sale) => sum + sale.total);

                          final totalEfectivo = filteredSales
                              .where((sale) => sale.metodoPago.toLowerCase() == 'efectivo')
                              .fold(0.0, (sum, sale) => sum + sale.total);

                          final countYape = filteredSales
                              .where((sale) => sale.metodoPago.toLowerCase() == 'yape')
                              .length;

                          final countEfectivo = filteredSales
                              .where((sale) => sale.metodoPago.toLowerCase() == 'efectivo')
                              .length;

                          return ListView(
                            padding: const EdgeInsets.all(0),
                            children: [
                              // Card de totales con desglose de métodos de pago
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE87D5C), Color(0xFFE87D5C)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Total principal
                                    Column(
                                      children: [
                                        const Text(
                                          'TOTAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'S/ ${totalSales.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$totalTransactions transacciones',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Separador
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 16),
                                      height: 1,
                                      color: Colors.white24,
                                    ),

                                    // Desglose por método de pago
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildPaymentBreakdown(
                                          icon: Icons.phone_android,
                                          label: 'Yape',
                                          amount: totalYape,
                                          count: countYape,
                                        ),
                                        Container(width: 1, height: 40, color: Colors.white24),
                                        _buildPaymentBreakdown(
                                          icon: Icons.payments,
                                          label: 'Efectivo',
                                          amount: totalEfectivo,
                                          count: countEfectivo,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Desglose por tipo
                              if (selectedFilter == 'todas' && allSales.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: _buildBreakdownSection(allSales),
                                ),

                              const SizedBox(height: 16),

                              // Título
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Detalle de Ventas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('${filteredSales.length} ventas', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Lista de ventas
                              ...filteredSales.map((sale) => _buildSaleCard(sale)).toList(),
                              
                              const SizedBox(height: 80),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: (isGeneratingPdf || selectedWorkerId == null)
            ? null
            : FloatingActionButton.extended(
                onPressed: _generatePdf,
                backgroundColor: const Color(0xFFE87D5C),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
      ),
    );
  }

  List<SaleModel> _filterSales(List<SaleModel> sales) {
    if (selectedFilter == 'todas') return sales;

    return sales.where((sale) {
      final hasProducts = sale.items.any((item) => item.tipo == 'producto');
      final hasServices = sale.items.any((item) => item.tipo == 'servicio');
      final hasServicesWithProducts = sale.items.any((item) => item.tipo == 'servicio' && item.productosUsados.isNotEmpty);

      switch (selectedFilter) {
        case 'con_productos': return hasServicesWithProducts;
        case 'sin_productos': return hasServices && !hasProducts && !hasServicesWithProducts;
        case 'solo_productos': return hasProducts && !hasServices;
        default: return true;
      }
    }).toList();
  }

  Widget _buildBreakdownSection(List<SaleModel> sales) {
    final conProductos = _filterSalesByType(sales, 'con_productos');
    final sinProductos = _filterSalesByType(sales, 'sin_productos');
    final soloProductos = _filterSalesByType(sales, 'solo_productos');

    final totalConProductos = conProductos.fold(0.0, (sum, sale) => sum + sale.total);
    final totalSinProductos = sinProductos.fold(0.0, (sum, sale) => sum + sale.total);
    final totalSoloProductos = soloProductos.fold(0.0, (sum, sale) => sum + sale.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desglose por tipo de venta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildBreakdownRow('Servicios con productos', conProductos.length, totalConProductos, Colors.orange),
          const Divider(height: 24),
          _buildBreakdownRow('Servicios puros', sinProductos.length, totalSinProductos, Colors.green),
          const Divider(height: 24),
          _buildBreakdownRow('Solo productos', soloProductos.length, totalSoloProductos, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, double total, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('$count ventas', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        Text('S/ ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  List<SaleModel> _filterSalesByType(List<SaleModel> sales, String type) {
    return sales.where((sale) {
      final hasProducts = sale.items.any((item) => item.tipo == 'producto');
      final hasServices = sale.items.any((item) => item.tipo == 'servicio');
      final hasServicesWithProducts = sale.items.any((item) => item.tipo == 'servicio' && item.productosUsados.isNotEmpty);

      switch (type) {
        case 'con_productos': return hasServicesWithProducts;
        case 'sin_productos': return hasServices && !hasProducts && !hasServicesWithProducts;
        case 'solo_productos': return hasProducts && !hasServices;
        default: return false;
      }
    }).toList();
  }

  Widget _buildFilterChip(String label, String value, IconData icon, Color color) {
    final isSelected = selectedFilter == value;
    
    return InkWell(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPaymentBreakdown({
    required IconData icon,
    required String label,
    required double amount,
    required int count,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
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
        const SizedBox(height: 6),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count ventas',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(SaleModel sale) {
    final dia = DateFormat('dd').format(sale.fecha);
    final numeroVenta = sale.numeroVentaDia.toString().padLeft(3, '0');
    final numeroDisplay = '#$dia-$numeroVenta';

    final hasProducts = sale.items.any((item) => item.tipo == 'producto');
    final hasServices = sale.items.any((item) => item.tipo == 'servicio');
    final hasServicesWithProducts = sale.items.any((item) => item.tipo == 'servicio' && item.productosUsados.isNotEmpty);

    String tipoVenta;
    Color tipoColor;
    IconData tipoIcon;
    
    if (hasServicesWithProducts) {
      tipoVenta = 'Con productos';
      tipoColor = Colors.orange;
      tipoIcon = Icons.shopping_bag;
    } else if (hasServices && !hasProducts) {
      tipoVenta = 'Solo Servicio';
      tipoColor = Colors.green;
      tipoIcon = Icons.spa;
    } else if (hasProducts && !hasServices) {
      tipoVenta = 'Solo productos';
      tipoColor = Colors.blue;
      tipoIcon = Icons.inventory_2;
    } else {
      tipoVenta = 'Mixto';
      tipoColor = Colors.purple;
      tipoIcon = Icons.receipt_long;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/transaction-detail', arguments: sale);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tipoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tipoIcon, color: tipoColor, size: 24),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Venta $numeroDisplay', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd/MM · hh:mm a').format(sale.fecha), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: tipoColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(tipoVenta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tipoColor.withOpacity(0.8))),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('S/ ${sale.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getPaymentColor(sale.metodoPago), borderRadius: BorderRadius.circular(6)),
                  child: Text(_getPaymentLabel(sale.metodoPago), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentLabel(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'yape': return 'Yape';
      case 'efectivo': return 'Efectivo';
      case 'tarjeta': return 'Tarjeta';
      default: return metodo;
    }
  }

  Color _getPaymentColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'yape': return const Color(0xFF6C2A8B);
      case 'efectivo': return Colors.green;
      case 'tarjeta': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2020), lastDate: endDate);
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: endDate, firstDate: startDate, lastDate: DateTime.now());
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> _generatePdf() async {
    setState(() => isGeneratingPdf = true);

    try {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      final allSalesSnapshot = await salesProvider.getSales(userId: selectedWorkerId, startDate: startDate, endDate: endDate).first;
      final filteredSales = _filterSales(allSalesSnapshot);

      await WorkerSalesPdfService.generateWorkerSalesReport(
        filteredSales,
        allSalesSnapshot,
        selectedWorkerName ?? 'Trabajadora',
        startDate,
        endDate,
        selectedFilter,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado exitosamente'), backgroundColor: Colors.black87),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: AppColors.inactiveRed),
        );
      }
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }
}