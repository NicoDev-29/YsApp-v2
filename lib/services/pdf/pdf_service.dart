import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:ysa_app/models/models_exports.dart';

// ============================================================
// CLASES DE DATOS PARA REPORTES DE VENTAS
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

// ============================================================
// SERVICIO PDF UNIFICADO
// ============================================================
class PdfService {
  static final dateFormat = DateFormat('dd/MM/yyyy');
  static final timeFormat = DateFormat('hh:mm a', 'es');
  static final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

  // ============================================================
  // REPORTE 1: INVENTARIO - PRODUCTOS POR AGOTARSE
  // ============================================================
  static Future<void> generateLowStockReport(
    List<ProductModel> products,
    String salonFilter,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    final criticalCount = products.where((p) => 
      p.stock / p.stockMinimo < 0.5
    ).length;
    final lowCount = products.length - criticalCount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('REPORTE DE INVENTARIO', salonTitle),
              pw.SizedBox(height: 20),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.pink900,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PRODUCTOS POR AGOTARSE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Stock actual por debajo del mínimo requerido',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.white.shade(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border.all(color: PdfColors.amber200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildSummaryItem('Total', '${products.length}', PdfColors.grey800),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.amber200),
                    pw.Expanded(
                      child: _buildSummaryItem('Estado Bajo', '$lowCount', PdfColors.orange),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.amber200),
                    pw.Expanded(
                      child: _buildSummaryItem('Críticos', '$criticalCount', PdfColors.red),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.3),
                  3: const pw.FlexColumnWidth(1.3),
                  4: const pw.FlexColumnWidth(1.2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey800),
                    children: [
                      _buildTableCell('Producto', isHeader: true, isWhite: true),
                      if (salonFilter == 'todos')
                        _buildTableCell('Salón', isHeader: true, isWhite: true),
                      _buildTableCell('Categoría', isHeader: true, isWhite: true),
                      _buildTableCell('Stock Actual', isHeader: true, isWhite: true),
                      _buildTableCell('Stock Mínimo', isHeader: true, isWhite: true),
                      _buildTableCell('Estado', isHeader: true, isWhite: true),
                    ],
                  ),
                  ...products.map((product) {
                    final stockRatio = product.stock / product.stockMinimo;
                    final isCritical = stockRatio < 0.5;
                    final index = products.indexOf(product);
                    final isEven = index % 2 == 0;
                    
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell(product.nombre),
                        if (salonFilter == 'todos')
                          _buildTableCell(product.salonName, isBold: true),
                        _buildTableCell(product.categoria),
                        _buildTableCell(
                          '${product.stock}',
                          color: isCritical ? PdfColors.red : PdfColors.orange,
                          isBold: true,
                        ),
                        _buildTableCell('${product.stockMinimo}'),
                        _buildTableCell(
                          isCritical ? 'CRÍTICO' : 'BAJO',
                          color: isCritical ? PdfColors.red : PdfColors.orange,
                          isBold: true,
                          isCenter: true,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              _buildFooter(products.length, criticalCount, lowCount),
            ],
          );
        },
      ),
    );

    await _savePdf(pdf, 'reporte_stock_bajo_${now.millisecondsSinceEpoch}.pdf');
  }

  // ============================================================
  // REPORTE 2: VENTAS - RESUMEN GENERAL
  // ============================================================
  static Future<void> generateSalesSummaryReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

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

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('RESUMEN DE VENTAS', salonTitle),
              pw.SizedBox(height: 12),

              // Período
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(pw.IconData(0xe878), size: 16, color: PdfColors.grey700),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Resumen
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.pink50,
                  border: pw.Border.all(color: PdfColors.pink200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Total Ventas',
                        currencyFormat.format(totalSales),
                        PdfColors.pink900,
                      ),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.pink200),
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Transacciones',
                        '$totalTransactions',
                        PdfColors.grey800,
                      ),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.pink200),
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Ticket Promedio',
                        currencyFormat.format(averageTicket),
                        PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Título de desglose
              pw.Text(
                'DESGLOSE POR TRABAJADORA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),

              pw.SizedBox(height: 10),

              // Tabla de trabajadoras
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey800),
                    children: [
                      _buildTableCell('#', isHeader: true, isWhite: true, isCenter: true),
                      _buildTableCell('Trabajadora', isHeader: true, isWhite: true),
                      _buildTableCell('Total Ventas', isHeader: true, isWhite: true),
                      _buildTableCell('Cantidad', isHeader: true, isWhite: true, isCenter: true),
                      _buildTableCell('Porcentaje', isHeader: true, isWhite: true, isCenter: true),
                    ],
                  ),
                  ...workerSalesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final worker = entry.value;
                    final percentage = (worker.totalSales / totalSales * 100).toStringAsFixed(1);
                    final isEven = index % 2 == 0;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell('${index + 1}', isCenter: true, isBold: true),
                        _buildTableCell(worker.userName),
                        _buildTableCell(
                          currencyFormat.format(worker.totalSales),
                          color: PdfColors.pink900,
                          isBold: true,
                        ),
                        _buildTableCell('${worker.saleCount}', isCenter: true),
                        _buildTableCell('$percentage%', isCenter: true, color: PdfColors.grey600),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              _buildFooterSimple(totalTransactions),
            ],
          );
        },
      ),
    );

    await _savePdf(pdf, 'resumen_ventas_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // ============================================================
  // REPORTE 3: VENTAS - TOP PRODUCTOS MÁS VENDIDOS
  // ============================================================
  static Future<void> generateTopProductsReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

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

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('PRODUCTOS MÁS VENDIDOS', salonTitle),
              pw.SizedBox(height: 12),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(pw.IconData(0xe878), size: 16, color: PdfColors.grey700),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Text(
                'TOP 20 PRODUCTOS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(50),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey800),
                    children: [
                      _buildTableCell('Rank', isHeader: true, isWhite: true, isCenter: true),
                      _buildTableCell('Producto', isHeader: true, isWhite: true),
                      _buildTableCell('Cantidad', isHeader: true, isWhite: true, isCenter: true),
                      _buildTableCell('Total Generado', isHeader: true, isWhite: true),
                    ],
                  ),
                  ...top20.asMap().entries.map((entry) {
                    final index = entry.key;
                    final product = entry.value;
                    final isEven = index % 2 == 0;
                    final rankColor = index == 0 
                        ? PdfColors.amber 
                        : index == 1 
                            ? PdfColors.grey400 
                            : index == 2 
                                ? PdfColors.brown 
                                : PdfColors.grey800;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell(
                          '${index + 1}',
                          isCenter: true,
                          isBold: true,
                          color: rankColor,
                        ),
                        _buildTableCell(product.nombre),
                        _buildTableCell(
                          '${product.cantidadVendida}',
                          isCenter: true,
                          isBold: true,
                          color: PdfColors.pink900,
                        ),
                        _buildTableCell(
                          currencyFormat.format(product.totalGenerado),
                          color: PdfColors.grey800,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              _buildFooterSimple(top20.length),
            ],
          );
        },
      ),
    );

    await _savePdf(pdf, 'top_productos_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // ============================================================
  // REPORTE 4: VENTAS - VENTAS DIARIAS POR SALÓN
  // ============================================================
  static Future<void> generateDailySalesReport(
    List<SaleModel> sales,
    String salonFilter,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

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

    String salonTitle;
    if (salonFilter == 'todos') {
      salonTitle = 'Todos los salones';
    } else if (salonFilter == 'salon_principal') {
      salonTitle = 'Salón Principal';
    } else {
      salonTitle = 'Salón Secundario';
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('VENTAS DIARIAS', salonTitle),
              pw.SizedBox(height: 12),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(pw.IconData(0xe878), size: 16, color: PdfColors.grey700),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Período: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Total Período',
                        currencyFormat.format(totalPeriodo),
                        PdfColors.blue900,
                      ),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.blue200),
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Total Ventas',
                        '$totalVentas',
                        PdfColors.grey800,
                      ),
                    ),
                    pw.Container(width: 1, height: 30, color: PdfColors.blue200),
                    pw.Expanded(
                      child: _buildSummaryItem(
                        'Promedio Diario',
                        currencyFormat.format(promedioDiario),
                        PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'DESGLOSE DIARIO',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey800),
                    children: [
                      _buildTableCell('Fecha', isHeader: true, isWhite: true),
                      _buildTableCell('Día', isHeader: true, isWhite: true),
                      _buildTableCell('Ventas', isHeader: true, isWhite: true, isCenter: true),
                      _buildTableCell('Total', isHeader: true, isWhite: true),
                    ],
                  ),
                  ...dailySalesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isEven = index % 2 == 0;
                    final dayName = DateFormat('EEEE', 'es').format(day.fecha);

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell(dateFormat.format(day.fecha)),
                        _buildTableCell(dayName, isBold: true),
                        _buildTableCell('${day.cantidadVentas}', isCenter: true),
                        _buildTableCell(
                          currencyFormat.format(day.total),
                          color: PdfColors.blue900,
                          isBold: true,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              _buildFooterSimple(dailySalesList.length),
            ],
          );
        },
      ),
    );

    await _savePdf(pdf, 'ventas_diarias_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  // ============================================================
  // FUNCIONES AUXILIARES
  // ============================================================
  static pw.Widget _buildHeader(String title, String salon) {
    final now = DateTime.now();
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'YSABELLA',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.pink900,
                ),
              ),
              pw.Text(
                'Salón & Spa',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.pink700,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Trujillo, La Libertad - Perú',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                dateFormat.format(now),
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                timeFormat.format(now),
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.pink50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  salon,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isWhite = false,
    bool isBold = false,
    bool isCenter = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isWhite ? PdfColors.white : (color ?? PdfColors.grey800),
        ),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildFooter(int total, int critical, int low) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resumen del Reporte',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '• Total de productos: $total',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.Text(
                '• Estado bajo: $low',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.orange),
              ),
              if (critical > 0)
                pw.Text(
                  '• Estado crítico: $critical',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generado por',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                'YsApp',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.pink900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterSimple(int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total de registros: $count',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generado por',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                'YsApp',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.pink900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
}