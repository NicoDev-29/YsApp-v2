import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ysa_app/models/models_exports.dart';
import 'pdf_base_service.dart';

/// Servicio para generar reportes de inventario
class InventoryPdfService {
  /// Genera reporte de productos por agotarse
  static Future<void> generateLowStockReport(
    List<ProductModel> products,
    String salonFilter,
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

    // Calcular métricas
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
              // Header
              PdfBaseService.buildHeader(
                title: 'Reporte de Inventario',
                subtitle: 'Stock actual por debajo del mínimo requerido',
                salonTag: salonTitle,
              ),

              pw.SizedBox(height: 16),

              // Cajas de resumen
              PdfBaseService.buildSummaryBoxes([
                SummaryItem(
                  label: 'Total Productos',
                  value: '${products.length}',
                ),
                SummaryItem(
                  label: 'Stock Bajo',
                  value: '$lowCount',
                ),
                SummaryItem(
                  label: 'Críticos',
                  value: '$criticalCount',
                ),
              ]),

              pw.SizedBox(height: 20),

              // Tabla de productos
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 1,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.3),
                  3: const pw.FlexColumnWidth(1.3),
                  4: const pw.FlexColumnWidth(1.2),
                },
                children: [
                  // Header de tabla
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      PdfBaseService.buildTableCell('PRODUCTO', isHeader: true),
                      if (salonFilter == 'todos')
                        PdfBaseService.buildTableCell('SALÓN', isHeader: true),
                      PdfBaseService.buildTableCell('CATEGORÍA', isHeader: true),
                      PdfBaseService.buildTableCell('STOCK ACTUAL', isHeader: true),
                      PdfBaseService.buildTableCell('STOCK MÍNIMO', isHeader: true),
                      PdfBaseService.buildTableCell('ESTADO', isHeader: true),
                    ],
                  ),
                  
                  // Filas de productos
                  ...products.map((product) {
                    final stockRatio = product.stock / product.stockMinimo;
                    final isCritical = stockRatio < 0.5;
                    
                    return pw.TableRow(
                      children: [
                        PdfBaseService.buildTableCell(product.nombre),
                        if (salonFilter == 'todos')
                          PdfBaseService.buildTableCell(product.salonName),
                        PdfBaseService.buildTableCell(product.categoria),
                        PdfBaseService.buildTableCell(
                          '${product.stock}',
                          isBold: true,
                        ),
                        PdfBaseService.buildTableCell('${product.stockMinimo}'),
                        PdfBaseService.buildTableCell(
                          isCritical ? 'CRÍTICO' : 'BAJO',
                          isBold: true,
                          isCenter: true,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),

              // Footer
              PdfBaseService.buildFooter(
                summary: criticalCount > 0
                    ? 'Total: ${products.length} productos | Críticos: $criticalCount'
                    : 'Total: ${products.length} productos',
              ),
            ],
          );
        },
      ),
    );

    // Guardar y abrir
    await PdfBaseService.savePdf(
      pdf,
      'reporte_stock_bajo_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}