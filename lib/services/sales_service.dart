import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/cart_item_model.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar venta completa
  Future<String> registerSale({
    required String userId,
    required String userName,
    required String salonId,
    required String metodoPago,
    required double total,
    required List<CartItemModel> items,
  }) async {
    final batch = _firestore.batch();

    // 1. Crear documento de venta
    final saleRef = _firestore.collection('ventas').doc();
    final sale = SaleModel(
      id: saleRef.id,
      fecha: DateTime.now(),
      idUsuario: userId,
      nombreUsuario: userName,
      idSalon: salonId,
      metodoPago: metodoPago,
      total: total,
      items: items,
    );
    batch.set(saleRef, sale.toFirestore());

    // 2. Procesar cada item
    for (var item in items) {
      if (item.tipo == 'producto') {
        // Reducir stock del producto
        await _updateProductStock(
          batch,
          item.productoId!,
          item.cantidad,
          salonId,
        );

        // Registrar movimiento de venta
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
        // Reducir stock de productos usados en el servicio
        for (var productUsed in item.productosUsados) {
          await _updateProductStock(
            batch,
            productUsed.productoId,
            productUsed.cantidad,
            salonId,
          );

          // Registrar movimiento
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

  // Actualizar stock de producto
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

  // Registrar movimiento de inventario
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

  // Stream de ventas (para historial futuro)
  Stream<List<SaleModel>> getSales({String? salonId}) {
    Query query = _firestore
        .collection('ventas')
        .orderBy('fecha', descending: true);

    if (salonId != null && salonId.isNotEmpty) {
      query = query.where('idSalon', isEqualTo: salonId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SaleModel.fromFirestore(doc))
          .toList();
    });
  }
}