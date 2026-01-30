import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/pdf/sales_pdf_service.dart';
import 'package:ysa_app/themes/theme.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String? selectedSalon;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool isGeneratingPdf = false;

  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin) {
        selectedSalon = authProvider.currentUser?.idSalon;
      } else {
        selectedSalon = 'salon_principal';
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
            'Resumen de Ventas',
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
                  children: [
                    if (isAdmin)
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store, color: AppColors.primary, size: 20),
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
                                      value: selectedSalon,
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
                                        if (value != null) {
                                          setState(() => selectedSalon = value);
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
                      ),
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
                  ],
                ),
              ),

              // CONTENIDO
              Expanded(
                child: StreamBuilder<List<SaleModel>>(
                  stream: salesProvider.getSales(
                    salonId: selectedSalon == 'todos' ? null : selectedSalon,
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

                    final sales = snapshot.data ?? [];

                    if (sales.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay ventas en este período',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Calcular totales
                    final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.total);
                    final totalTransactions = sales.length;

                    // Calcular por método de pago
                    final totalYape = sales
                        .where((sale) => sale.metodoPago.toLowerCase() == 'yape')
                        .fold(0.0, (sum, sale) => sum + sale.total);
                    final totalEfectivo = sales
                        .where((sale) => sale.metodoPago.toLowerCase() == 'efectivo')
                        .fold(0.0, (sum, sale) => sum + sale.total);
                    final countYape = sales.where((sale) => sale.metodoPago.toLowerCase() == 'yape').length;
                    final countEfectivo = sales.where((sale) => sale.metodoPago.toLowerCase() == 'efectivo').length;

                    // Agrupar por día
                    final dailySalesMap = <String, DailySales>{};
                    for (var sale in sales) {
                      final dateKey = DateFormat('yyyy-MM-dd').format(sale.fecha);
                      if (dailySalesMap.containsKey(dateKey)) {
                        final current = dailySalesMap[dateKey]!;
                        dailySalesMap[dateKey] = DailySales(
                          fecha: sale.fecha,
                          cantidadVentas: current.cantidadVentas + 1,
                          total: current.total + sale.total,
                        );
                      } else {
                        dailySalesMap[dateKey] = DailySales(
                          fecha: sale.fecha,
                          cantidadVentas: 1,
                          total: sale.total,
                        );
                      }
                    }
                    final dailySalesList = dailySalesMap.values.toList()
                      ..sort((a, b) => b.fecha.compareTo(a.fecha));

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // CARD DE TOTALES CON DESGLOSE DE MÉTODOS DE PAGO
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFFE8298F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Total principal
                              Column(
                                children: [
                                  const Text(
                                    'TOTAL DEL PERÍODO',
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

                        const SizedBox(height: 24),

                        // DESGLOSE POR DÍA
                        const Text(
                          'Ventas Diarias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...dailySalesList.map((day) {
                          final dayName = DateFormat('EEEE', 'es').format(day.fecha);
                          final isToday = DateFormat('yyyy-MM-dd').format(day.fecha) ==
                              DateFormat('yyyy-MM-dd').format(DateTime.now());

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? AppColors.primary
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('dd').format(day.fecha),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isToday ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM', 'es')
                                            .format(day.fecha)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isToday ? Colors.white : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            dayName.substring(0, 1).toUpperCase() +
                                                dayName.substring(1),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (isToday) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'HOY',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${day.cantidadVentas} ventas',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'S/ ${day.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: isGeneratingPdf
            ? null
            : FloatingActionButton.extended(
                onPressed: _generatePdf,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
      ),
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

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: endDate,
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> _generatePdf() async {
    setState(() => isGeneratingPdf = true);

    try {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      final salesSnapshot = await salesProvider
          .getSales(
            salonId: selectedSalon == 'todos' ? null : selectedSalon,
            startDate: startDate,
            endDate: endDate,
          )
          .first;

      await SalesPdfService.generateUnifiedSalesReport(
        salesSnapshot,
        selectedSalon ?? 'todos',
        startDate,
        endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado exitosamente'),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: AppColors.inactiveRed,
          ),
        );
      }
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }
}