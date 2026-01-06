import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/pdf/sales_pdf_service.dart';
import 'package:ysa_app/themes/theme.dart';

class TopServicesScreen extends StatefulWidget {
  const TopServicesScreen({Key? key}) : super(key: key);

  @override
  State<TopServicesScreen> createState() => _TopServicesScreenState();
}

class _TopServicesScreenState extends State<TopServicesScreen> {
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
            'Servicios Más Vendidos',
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
              // ✅ FILTROS
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Selector de salón (solo admin)
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
                  ],
                ),
              ),

              // ✅ LISTA DE SERVICIOS
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
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final sales = snapshot.data ?? [];

                    if (sales.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.spa_outlined,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay servicios vendidos',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ✅ FILTRAR SOLO SERVICIOS (tipo = 'servicio')
                    final serviceSalesMap = <String, ServiceSalesData>{};
                    for (var sale in sales) {
                      for (var item in sale.items) {
                        if (item.tipo == 'servicio') { // ← CAMBIO CLAVE
                          final key = item.nombre;
                          if (serviceSalesMap.containsKey(key)) {
                            final current = serviceSalesMap[key]!;
                            serviceSalesMap[key] = ServiceSalesData(
                              nombre: item.nombre,
                              cantidadVendida: current.cantidadVendida + 1, // Servicios = 1 por venta
                              totalGenerado: current.totalGenerado + item.precioFinal,
                            );
                          } else {
                            serviceSalesMap[key] = ServiceSalesData(
                              nombre: item.nombre,
                              cantidadVendida: 1,
                              totalGenerado: item.precioFinal,
                            );
                          }
                        }
                      }
                    }

                    final topServices = serviceSalesMap.values.toList()
                      ..sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
                    final top20 = topServices.take(20).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: top20.length,
                      itemBuilder: (context, index) {
                        final service = top20[index];
                        final rank = index + 1;

                        // Colores para ranking
                        Color rankColor;
                        IconData? medal;
                        if (rank == 1) {
                          rankColor = const Color(0xFFFFD700);
                          medal = Icons.emoji_events;
                        } else if (rank == 2) {
                          rankColor = const Color(0xFFC0C0C0);
                          medal = Icons.emoji_events;
                        } else if (rank == 3) {
                          rankColor = const Color(0xFFCD7F32);
                          medal = Icons.emoji_events;
                        } else {
                          rankColor = Colors.grey[300]!;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: rank <= 3
                                ? Border.all(color: rankColor, width: 2)
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
                              // Badge de ranking
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: rankColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: medal != null
                                      ? Icon(medal, color: rankColor, size: 28)
                                      : Text(
                                          '$rank',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                            fontSize: 18,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info del servicio
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Realizados: ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${service.cantidadVendida}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Total generado
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'S/ ${service.totalGenerado.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                backgroundColor:  const Color(0xFF81C784),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exportar PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: endDate,
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
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

      await SalesPdfService.generateTopServicesReport(
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

// ✅ MODELO PARA DATOS DE SERVICIOS
class ServiceSalesData {
  final String nombre;
  final int cantidadVendida;
  final double totalGenerado;

  ServiceSalesData({
    required this.nombre,
    required this.cantidadVendida,
    required this.totalGenerado,
  });
}