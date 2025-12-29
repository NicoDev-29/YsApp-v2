import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/cart_item_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== REGISTRAR VENTA ====================
  Future<String> registerSale({
    required String userId,
    required String userName,
    required String salonId,
    required String metodoPago,
    required double total,
    required List<CartItemModel> items,
  }) async {
    final batch = _firestore.batch();

    // Calcular número de venta del día
    final hoy = DateTime.now();
    final inicioDia = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = inicioDia.add(const Duration(days: 1));
    
    // Esta query necesita el Índice 3: idSalon + fecha
    final ventasHoy = await _firestore
        .collection('ventas')
        .where('idSalon', isEqualTo: salonId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('fecha', isLessThan: Timestamp.fromDate(finDia))
        .get();
    
    final numeroVentaDia = ventasHoy.docs.length + 1;

    // Crear documento de venta
    final saleRef = _firestore.collection('ventas').doc();
    final sale = SaleModel(
      id: saleRef.id,
      numeroVentaDia: numeroVentaDia,
      fecha: DateTime.now(),
      idUsuario: userId,
      nombreUsuario: userName,
      idSalon: salonId,
      metodoPago: metodoPago,
      total: total,
      items: items,
    );
    batch.set(saleRef, sale.toFirestore());

    // Procesar cada item
    for (var item in items) {
      if (item.tipo == 'producto') {
        await _updateProductStock(
          batch,
          item.productoId!,
          item.cantidad,
          salonId,
        );

        await _registerMovement(
          batch,
          tipo: 'venta',
          productoId: item.productoId!,
          productoNombre: item.nombre,
          cantidad: item.cantidad,
          salonId: salonId,
          userId: userId,
          userName: userName,
          ventaId: saleRef.id,
        );
      } else if (item.tipo == 'servicio') {
        for (var productUsed in item.productosUsados) {
          await _updateProductStock(
            batch,
            productUsed.productoId,
            productUsed.cantidad,
            salonId,
          );

          await _registerMovement(
            batch,
            tipo: 'venta',
            productoId: productUsed.productoId,
            productoNombre: productUsed.nombre,
            cantidad: productUsed.cantidad,
            salonId: salonId,
            userId: userId,
            userName: userName,
            ventaId: saleRef.id,
            motivo: 'Usado en servicio: ${item.nombre}',
          );
        }
      }
    }

    await batch.commit();
    return saleRef.id;
  }

  Future<void> _updateProductStock(
    WriteBatch batch,
    String productId,
    int cantidad,
    String salonId,
  ) async {
    final productRef = _firestore.collection('productos').doc(productId);
    final productDoc = await productRef.get();

    if (productDoc.exists) {
      final currentStock = productDoc.data()!['stock'] as int;
      batch.update(productRef, {
        'stock': currentStock - cantidad,
      });
    }
  }

  Future<void> _registerMovement(
    WriteBatch batch, {
    required String tipo,
    required String productoId,
    required String productoNombre,
    required int cantidad,
    required String salonId,
    required String userId,
    required String userName,
    required String ventaId,
    String? motivo,
  }) async {
    final movementRef = _firestore.collection('movimientos').doc();
    batch.set(movementRef, {
      'tipo': tipo,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'cantidad': cantidad,
      'salonId': salonId,
      'fecha': FieldValue.serverTimestamp(),
      'realizadoPor': userId,
      'realizadoPorNombre': userName,
      'motivo': motivo ?? 'Venta #$ventaId',
    });
  }

  // ==================== CONSULTAR VENTAS ====================
  Stream<List<SaleModel>> getSales({
    String? salonId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('ventas');

    // Decidir qué índice usar según los filtros
    if (salonId != null && salonId.isNotEmpty) {
      // Usa Índice 1: idSalon + fecha
      query = query.where('idSalon', isEqualTo: salonId);
    } else if (userId != null && userId.isNotEmpty) {
      // Usa Índice 2: idUsuario + fecha
      query = query.where('idUsuario', isEqualTo: userId);
    }

    // Agregar filtros de fecha
    if (startDate != null) {
      query = query.where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    // Ordenar por fecha descendente
    query = query.orderBy('fecha', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    });
  }
}