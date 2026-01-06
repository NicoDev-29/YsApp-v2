import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'pdf_base_service.dart';

// ============================================================
// CLASES DE DATOS
// ============================================================
class WorkerSales {
  final String userName;
  final double totalSales;
  final int saleCount;

  WorkerSales({
    required this.userName,
    required this.totalSales,
    required this.saleCount,
  });
}

class ProductSalesData {
  final String nombre;
  final String categoria;
  final int cantidadVendida;
  final double totalGenerado;

  ProductSalesData({
    required this.nombre,
    required this.categoria,
    required this.cantidadVendida,
    required this.totalGenerado,
  });
}

// ← CLASE PARA SERVICIOS
class ServiceSalesData {
  final String nombre;
  final int cantidadRealizada;
  final double totalGenerado;

  ServiceSalesData({
    required this.nombre,
    required this.cantidadRealizada,
    required this.totalGenerado,
  });
}

class DailySales {
  final DateTime fecha;
  final int cantidadVentas;
  final double total;

  DailySales({
    required this.fecha,
    required this.cantidadVentas,
    required this.total,
  });
}

/// Servicio para generar reportes de ventas
class SalesPdfService {
  // ============================================================
  // REPORTE 1: RESUMEN GENERAL DE VENTAS
  // ============================================================
  static Future<void> generateSalesSummaryReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    // Determinar título del salón
    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    // Calcular totales
    final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.total);
    final totalTransactions = sales.length;
    final averageTicket = totalTransactions > 0 ? totalSales / totalTransactions : 0.0;

    // Agrupar ventas por trabajadora
    final workerSalesMap = <String, WorkerSales>{};
    for (var sale in sales) {
      if (workerSalesMap.containsKey(sale.nombreUsuario)) {
        final current = workerSalesMap[sale.nombreUsuario]!;
        workerSalesMap[sale.nombreUsuario] = WorkerSales(
          userName: sale.nombreUsuario,
          totalSales: current.totalSales + sale.total,
          saleCount: current.saleCount + 1,
        );
      } else {
        workerSalesMap[sale.nombreUsuario] = WorkerSales(
          userName: sale.nombreUsuario,
          totalSales: sale.total,
          saleCount: 1,
        );
      }
    }

    final workerSalesList = workerSalesMap.values.toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              PdfBaseService.buildHeader(
                title: 'Resumen de Ventas',
                salonTag: salonTitle,
              ),

              pw.SizedBox(height: 12),

              // Período
              PdfBaseService.buildInfoBox(
                'Período: ${PdfBaseService.dateFormat.format(startDate)} - ${PdfBaseService.dateFormat.format(endDate)}',
              ),

              pw.SizedBox(height: 16),

              // Cajas de resumen
              PdfBaseService.buildSummaryBoxes([
                SummaryItem(
                  label: 'Total Ventas',
                  value: PdfBaseService.currencyFormat.format(totalSales),
                ),
                SummaryItem(
                  label: 'Transacciones',
                  value: '$totalTransactions',
                ),
                SummaryItem(
                  label: 'Ticket Promedio',
                  value: PdfBaseService.currencyFormat.format(averageTicket),
                ),
              ]),

              pw.SizedBox(height: 20),

              // Título de desglose
              pw.Text(
                'DESGLOSE POR TRABAJADORA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // Tabla de trabajadoras
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      PdfBaseService.buildTableCell('#', isHeader: true, isCenter: true),
                      PdfBaseService.buildTableCell('TRABAJADORA', isHeader: true),
                      PdfBaseService.buildTableCell('TOTAL VENTAS', isHeader: true),
                      PdfBaseService.buildTableCell('CANTIDAD', isHeader: true, isCenter: true),
                      PdfBaseService.buildTableCell('PORCENTAJE', isHeader: true, isCenter: true),
                    ],
                  ),
                  
                  // Filas
                  ...workerSalesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final worker = entry.value;
                    final percentage = (worker.totalSales / totalSales * 100).toStringAsFixed(1);

                    return pw.TableRow(
                      children: [
                        PdfBaseService.buildTableCell('${index + 1}', isCenter: true, isBold: true),
                        PdfBaseService.buildTableCell(worker.userName),
                        PdfBaseService.buildTableCell(
                          PdfBaseService.currencyFormat.format(worker.totalSales),
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell('${worker.saleCount}', isCenter: true),
                        PdfBaseService.buildTableCell('$percentage%', isCenter: true),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),

              // Footer
              PdfBaseService.buildFooter(
                summary: 'Total de ventas: $totalTransactions',
              ),
            ],
          );
        },
      ),
    );

    await PdfBaseService.savePdf(
      pdf,
      'resumen_ventas_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ============================================================
  // REPORTE 2: TOP PRODUCTOS MÁS VENDIDOS
  // ============================================================
  static Future<void> generateTopProductsReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    // Procesar productos vendidos
    final productSalesMap = <String, ProductSalesData>{};
    for (var sale in sales) {
      for (var item in sale.items) {
        if (item.tipo == 'producto') {
          final key = item.nombre;
          if (productSalesMap.containsKey(key)) {
            final current = productSalesMap[key]!;
            productSalesMap[key] = ProductSalesData(
              nombre: item.nombre,
              categoria: item.productoId ?? 'N/A',
              cantidadVendida: current.cantidadVendida + item.cantidad,
              totalGenerado: current.totalGenerado + item.subtotal,
            );
          } else {
            productSalesMap[key] = ProductSalesData(
              nombre: item.nombre,
              categoria: item.productoId ?? 'N/A',
              cantidadVendida: item.cantidad,
              totalGenerado: item.subtotal,
            );
          }
        }
      }
    }

    final topProducts = productSalesMap.values.toList()
      ..sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
    final top20 = topProducts.take(20).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              PdfBaseService.buildHeader(
                title: 'Productos Más Vendidos',
                subtitle: 'Top 20 productos con mayor demanda',
                salonTag: salonTitle,
              ),

              pw.SizedBox(height: 12),

              // Período
              PdfBaseService.buildInfoBox(
                'Período: ${PdfBaseService.dateFormat.format(startDate)} - ${PdfBaseService.dateFormat.format(endDate)}',
              ),

              pw.SizedBox(height: 20),

              // Tabla
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(50),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      PdfBaseService.buildTableCell('RANK', isHeader: true, isCenter: true),
                      PdfBaseService.buildTableCell('PRODUCTO', isHeader: true),
                      PdfBaseService.buildTableCell('CANTIDAD', isHeader: true, isCenter: true),
                      PdfBaseService.buildTableCell('TOTAL GENERADO', isHeader: true),
                    ],
                  ),
                  
                  // Filas
                  ...top20.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;

                    return pw.TableRow(
                      children: [
                        PdfBaseService.buildTableCell(
                          '${index + 1}',
                          isCenter: true,
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell(product.nombre),
                        PdfBaseService.buildTableCell(
                          '${product.cantidadVendida}',
                          isCenter: true,
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell(
                          PdfBaseService.currencyFormat.format(product.totalGenerado),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),

              // Footer
              PdfBaseService.buildFooter(
                summary: 'Total de productos: ${top20.length}',
              ),
            ],
          );
        },
      ),
    );

    await PdfBaseService.savePdf(
      pdf,
      'top_productos_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ============================================================
  // REPORTE 2B: TOP SERVICIOS MÁS SOLICITADOS ← CORREGIDO
  // ============================================================
  static Future<void> generateTopServicesReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    // Procesar servicios vendidos
    final serviceSalesMap = <String, ServiceSalesData>{};
    for (var sale in sales) {
      for (var item in sale.items) {
        if (item.tipo == 'servicio') {
          final key = item.nombre;
          if (serviceSalesMap.containsKey(key)) {
            final current = serviceSalesMap[key]!;
            serviceSalesMap[key] = ServiceSalesData(
              nombre: item.nombre,
              cantidadRealizada: current.cantidadRealizada + 1,
              totalGenerado: current.totalGenerado + item.precioFinal,
            );
          } else {
            serviceSalesMap[key] = ServiceSalesData(
              nombre: item.nombre,
              cantidadRealizada: 1,
              totalGenerado: item.precioFinal,
            );
          }
        }
      }
    }

    final topServices = serviceSalesMap.values.toList()
      ..sort((a, b) => b.cantidadRealizada.compareTo(a.cantidadRealizada));
    final top20 = topServices.take(20).toList();

    final totalRealizados = top20.fold<int>(0, (sum, s) => sum + s.cantidadRealizada);
    final totalGenerado = top20.fold<double>(0, (sum, s) => sum + s.totalGenerado);
    final promedioServicio = totalRealizados > 0 ? totalGenerado / totalRealizados : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              PdfBaseService.buildHeader(
                title: 'Servicios Más Solicitados',
                subtitle: 'Ranking de los 20 servicios con mayor demanda',
                salonTag: salonTitle,
              ),

              pw.SizedBox(height: 12),

              // Período
              PdfBaseService.buildInfoBox(
                'Período: ${PdfBaseService.dateFormat.format(startDate)} - ${PdfBaseService.dateFormat.format(endDate)}',
              ),

              pw.SizedBox(height: 16),

              // Cajas de resumen (MEJORADAS - sin isWhite)
              PdfBaseService.buildSummaryBoxes([
                SummaryItem(
                  label: 'Servicios Realizados',
                  value: '$totalRealizados',
                ),
                SummaryItem(
                  label: 'Ingresos Totales',
                  value: PdfBaseService.currencyFormat.format(totalGenerado),
                ),
                SummaryItem(
                  label: 'Ticket Promedio',
                  value: PdfBaseService.currencyFormat.format(promedioServicio),
                ),
              ]),

              pw.SizedBox(height: 20),

              // Título explicativo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'RANKING DE SERVICIOS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green900,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.green700),
                    ),
                    child: pw.Text(
                      'Top ${top20.length} servicios',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Tabla (CORREGIDA - sin isWhite)
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(45),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2.5),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header con texto blanco manualmente
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.green700),
                    children: [
                      _buildWhiteTableCell('#', isHeader: true, isCenter: true),
                      _buildWhiteTableCell('SERVICIO', isHeader: true),
                      _buildWhiteTableCell('VECES REALIZADO', isHeader: true, isCenter: true),
                      _buildWhiteTableCell('TOTAL GENERADO', isHeader: true),
                      _buildWhiteTableCell('% DEL TOTAL', isHeader: true, isCenter: true),
                    ],
                  ),
                  
                  // Filas
                  ...top20.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    final porcentaje = (service.totalGenerado / totalGenerado * 100).toStringAsFixed(1);
                    final isTopThree = index < 3;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isTopThree 
                            ? PdfColors.amber50 
                            : index.isEven 
                                ? PdfColors.grey100 
                                : PdfColors.white,
                      ),
                      children: [
                        PdfBaseService.buildTableCell(
                          isTopThree ? ' ${index + 1}' : '${index + 1}',
                          isCenter: true,
                          isBold: isTopThree,
                        ),
                        PdfBaseService.buildTableCell(
                          service.nombre,
                          isBold: isTopThree,
                        ),
                        PdfBaseService.buildTableCell(
                          '${service.cantidadRealizada}',
                          isCenter: true,
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell(
                          PdfBaseService.currencyFormat.format(service.totalGenerado),
                          isBold: isTopThree,
                        ),
                        PdfBaseService.buildTableCell(
                          '$porcentaje%',
                          isCenter: true,
                        ),
                      ],
                    );
                  }).toList(),

                  // Fila de totales con texto blanco manualmente
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.green700),
                    children: [
                      _buildWhiteTableCell(''),
                      _buildWhiteTableCell('TOTAL', isBold: true),
                      _buildWhiteTableCell('$totalRealizados', isCenter: true, isBold: true),
                      _buildWhiteTableCell(
                        PdfBaseService.currencyFormat.format(totalGenerado),
                        isBold: true,
                      ),
                      _buildWhiteTableCell('100%', isCenter: true, isBold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // Nota informativa
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.blue300),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 4,
                      height: 30,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Nota importante',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Los servicios más solicitados te ayudan a identificar qué tratamientos prefieren tus clientes. '
                            'Considera mantener siempre disponibles los productos necesarios para los servicios del Top 5.',
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey800,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Reporte generado: ${PdfBaseService.dateFormat.format(DateTime.now())} ${DateFormat('HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'YsApp - Sistema de Gestión',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await PdfBaseService.savePdf(
      pdf,
      'servicios_mas_solicitados_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Helper para celdas con texto blanco (fondo verde)
  static pw.Widget _buildWhiteTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool isCenter = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.white, // ← BLANCO para fondo verde
        ),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  // ============================================================
  // REPORTE 3: VENTAS DIARIAS POR SALÓN
  // ============================================================
  static Future<void> generateDailySalesReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    // Agrupar ventas por día
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
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final totalPeriodo = dailySalesList.fold(0.0, (sum, day) => sum + day.total);
    final totalVentas = dailySalesList.fold(0, (sum, day) => sum + day.cantidadVentas);
    final promedioDiario = dailySalesList.isNotEmpty 
        ? totalPeriodo / dailySalesList.length 
        : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              PdfBaseService.buildHeader(
                title: 'Ventas Diarias',
                subtitle: 'Desglose de ventas por día',
                salonTag: salonTitle,
              ),

              pw.SizedBox(height: 12),

              // Período
              PdfBaseService.buildInfoBox(
                'Período: ${PdfBaseService.dateFormat.format(startDate)} - ${PdfBaseService.dateFormat.format(endDate)}',
              ),

              pw.SizedBox(height: 16),

              // Cajas de resumen
              PdfBaseService.buildSummaryBoxes([
                SummaryItem(
                  label: 'Total Período',
                  value: PdfBaseService.currencyFormat.format(totalPeriodo),
                ),
                SummaryItem(
                  label: 'Total Ventas',
                  value: '$totalVentas',
                ),
                SummaryItem(
                  label: 'Promedio Diario',
                  value: PdfBaseService.currencyFormat.format(promedioDiario),
                ),
              ]),

              pw.SizedBox(height: 20),

              // Título
              pw.Text(
                'DESGLOSE DIARIO',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // Tabla
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      PdfBaseService.buildTableCell('FECHA', isHeader: true),
                      PdfBaseService.buildTableCell('DÍA', isHeader: true),
                      PdfBaseService.buildTableCell('VENTAS', isHeader: true, isCenter: true),
                      PdfBaseService.buildTableCell('TOTAL', isHeader: true),
                    ],
                  ),
                  
                  // Filas
                  ...dailySalesList.map((day) {
                    final dayName = DateFormat('EEEE', 'es').format(day.fecha);

                    return pw.TableRow(
                      children: [
                        PdfBaseService.buildTableCell(
                          PdfBaseService.dateFormat.format(day.fecha),
                        ),
                        PdfBaseService.buildTableCell(
                          dayName.substring(0, 1).toUpperCase() + dayName.substring(1),
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell(
                          '${day.cantidadVentas}',
                          isCenter: true,
                        ),
                        PdfBaseService.buildTableCell(
                          PdfBaseService.currencyFormat.format(day.total),
                          isBold: true,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),

              // Footer
              PdfBaseService.buildFooter(
                summary: 'Total de días: ${dailySalesList.length}',
              ),
            ],
          );
        },
      ),
    );

    await PdfBaseService.savePdf(
      pdf,
      'ventas_diarias_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}