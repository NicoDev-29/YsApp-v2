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