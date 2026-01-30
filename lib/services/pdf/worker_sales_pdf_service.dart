import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'pdf_base_service.dart';

/// Servicio para generar PDF de ventas por trabajadora con filtros
class WorkerSalesPdfService {
  static Future<void> generateWorkerSalesReport(
    List<SaleModel> filteredSales,
    List<SaleModel> allSales,
    String workerName,
    DateTime startDate,
    DateTime endDate,
    String filterType,
  ) async {
    final pdf = pw.Document();

    // Calcular totales de ventas filtradas
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

    // Calcular totales por tipo (de todas las ventas)
    final conProductos = _filterByType(allSales, 'con_productos');
    final sinProductos = _filterByType(allSales, 'sin_productos');
    final soloProductos = _filterByType(allSales, 'solo_productos');

    final totalConProductos = conProductos.fold(0.0, (sum, sale) => sum + sale.total);
    final totalSinProductos = sinProductos.fold(0.0, (sum, sale) => sum + sale.total);
    final totalSoloProductos = soloProductos.fold(0.0, (sum, sale) => sum + sale.total);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          PdfBaseService.buildHeader(
            title: 'Reporte de Ventas - Trabajadora',
            subtitle: workerName,
            salonTag: _getFilterLabel(filterType),
          ),

          pw.SizedBox(height: 12),

          // Período
          PdfBaseService.buildInfoBox(
            'Período: ${PdfBaseService.dateFormat.format(startDate)} - ${PdfBaseService.dateFormat.format(endDate)}',
          ),

          pw.SizedBox(height: 16),

          // Total con desglose de métodos de pago
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [PdfColors.pink900, PdfColors.pink700],
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  PdfBaseService.currencyFormat.format(totalSales),
                  style: pw.TextStyle(
                    fontSize: 28,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '$totalTransactions transacciones',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white.shade(0.8),
                  ),
                ),
                
                // Separador
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  color: PdfColors.white.shade(0.3),
                ),

                // Desglose por método de pago
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPaymentBreakdown('Yape', totalYape, countYape),
                    pw.Container(
                      width: 1,
                      height: 30,
                      color: PdfColors.white.shade(0.3),
                    ),
                    _buildPaymentBreakdown('Efectivo', totalEfectivo, countEfectivo),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Desglose por tipo (solo si filterType es 'todas')
          if (filterType == 'todas') ...[
            pw.Text(
              'DESGLOSE POR TIPO DE VENTA',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                children: [
                  _buildBreakdownRow(
                    'Servicios con productos',
                    conProductos.length,
                    totalConProductos,
                    PdfColors.orange,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 12),
                  _buildBreakdownRow(
                    'Servicios puros',
                    sinProductos.length,
                    totalSinProductos,
                    PdfColors.green,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 12),
                  _buildBreakdownRow(
                    'Solo productos',
                    soloProductos.length,
                    totalSoloProductos,
                    PdfColors.blue,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],

          // Título de tabla
          pw.Text(
            'DETALLE DE TRANSACCIONES',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),

          pw.SizedBox(height: 10),

          // Tabla de ventas
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey400,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.pink900),
                children: [
                  _buildWhiteTableCell('#', isHeader: true, isCenter: true),
                  _buildWhiteTableCell('FECHA', isHeader: true),
                  _buildWhiteTableCell('HORA', isHeader: true),
                  _buildWhiteTableCell('TIPO', isHeader: true),
                  _buildWhiteTableCell('TOTAL', isHeader: true),
                ],
              ),

              // Filas de ventas
              ...filteredSales.asMap().entries.map((entry) {
                final index = entry.key;
                final sale = entry.value;
                final isEven = index % 2 == 0;

                // Determinar tipo
                final hasProducts = sale.items.any((item) => item.tipo == 'producto');
                final hasServices = sale.items.any((item) => item.tipo == 'servicio');
                final hasServicesWithProducts = sale.items.any(
                  (item) => item.tipo == 'servicio' && item.productosUsados.isNotEmpty,
                );

                String tipoVenta;
                if (hasServicesWithProducts) {
                  tipoVenta = 'Serv. + Prod.';
                } else if (hasServices && !hasProducts) {
                  tipoVenta = 'Servicio puro';
                } else if (hasProducts && !hasServices) {
                  tipoVenta = 'Solo productos';
                } else {
                  tipoVenta = 'Mixto';
                }

                // Número de venta
                final dia = DateFormat('dd').format(sale.fecha);
                final numeroVenta = sale.numeroVentaDia.toString().padLeft(3, '0');
                final numeroDisplay = '$dia-$numeroVenta';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : PdfColors.grey50,
                  ),
                  children: [
                    PdfBaseService.buildTableCell(
                      numeroDisplay,
                      isCenter: true,
                      isBold: true,
                    ),
                    PdfBaseService.buildTableCell(
                      DateFormat('dd/MM/yy').format(sale.fecha),
                    ),
                    PdfBaseService.buildTableCell(
                      DateFormat('HH:mm').format(sale.fecha),
                    ),
                    PdfBaseService.buildTableCell(tipoVenta),
                    PdfBaseService.buildTableCell(
                      PdfBaseService.currencyFormat.format(sale.total),
                      isBold: true,
                    ),
                  ],
                );
              }).toList(),

              // Fila de total
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.pink900),
                children: [
                  _buildWhiteTableCell('', isCenter: true),
                  _buildWhiteTableCell(''),
                  _buildWhiteTableCell(''),
                  _buildWhiteTableCell('TOTAL', isBold: true),
                  _buildWhiteTableCell(
                    PdfBaseService.currencyFormat.format(totalSales),
                    isBold: true,
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Footer
          PdfBaseService.buildFooter(
            summary: 'Período: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
          ),
        ],
      ),
    );

    await PdfBaseService.savePdf(
      pdf,
      'ventas_${workerName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static List<SaleModel> _filterByType(List<SaleModel> sales, String type) {
    return sales.where((sale) {
      final hasProducts = sale.items.any((item) => item.tipo == 'producto');
      final hasServices = sale.items.any((item) => item.tipo == 'servicio');
      final hasServicesWithProducts = sale.items.any(
        (item) => item.tipo == 'servicio' && item.productosUsados.isNotEmpty,
      );

      switch (type) {
        case 'con_productos':
          return hasServicesWithProducts;
        case 'sin_productos':
          return hasServices && !hasProducts && !hasServicesWithProducts;
        case 'solo_productos':
          return hasProducts && !hasServices;
        default:
          return false;
      }
    }).toList();
  }

  static String _getFilterLabel(String filter) {
    switch (filter) {
      case 'con_productos':
        return 'Servicios con Productos';
      case 'sin_productos':
        return 'Servicios Puros';
      case 'solo_productos':
        return 'Solo Productos';
      default:
        return 'Todas las Ventas';
    }
  }

  static pw.Widget _buildBreakdownRow(
    String label,
    int count,
    double total,
    PdfColor color,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 30,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '$count ventas',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Text(
          PdfBaseService.currencyFormat.format(total),
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildWhiteTableCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    bool isCenter = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 8.5 : 8,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.white,
        ),
        textAlign: isCenter ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildPaymentBreakdown(
    String label,
    double amount,
    int count,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.white.shade(0.8),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          PdfBaseService.currencyFormat.format(amount),
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '$count ventas',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.white.shade(0.7),
          ),
        ),
      ],
    );
  }
}