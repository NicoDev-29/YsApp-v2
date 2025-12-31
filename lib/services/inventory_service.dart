import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/movement_model.dart';
import 'cloudinary_service.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Stream de productos
  Stream<List<ProductModel>> getProducts({String? idSalon}) {
    Query query = _firestore.collection('productos');

    if (idSalon != null && idSalon.isNotEmpty) {
      query = query.where('idSalon', isEqualTo: idSalon);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // Stream de servicios
  Stream<List<ServiceModel>> getServices() {
    return _firestore.collection('servicios').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    });
  }

  // Stream de movimientos
  Stream<List<MovementModel>> getMovements() {
    return _firestore
        .collection('movimientos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MovementModel.fromFirestore(doc))
          .toList();
    });
  }

  // Agregar producto (con Cloudinary) + Registrar movimiento de INGRESO
  Future<void> addProduct(
    ProductModel product,
    String userId,
    String userName,
  ) async {
    String? imageUrl;

    if (product.imagen != null && product.imagen!.isNotEmpty) {
      final imageFile = File(product.imagen!);

      if (await imageFile.exists()) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);

        if (imageUrl == null) {
          throw Exception('Error al subir imagen a Cloudinary');
        }
      }
    }

    final productData = product.toFirestore();
    productData['imagen'] = imageUrl;

    final productRef =
        await _firestore.collection('productos').add(productData);

    // Registrar movimiento de INGRESO
    await _firestore.collection('movimientos').add({
      'tipo': 'ingreso',
      'productoId': productRef.id,
      'productoNombre': product.nombre,
      'cantidad': product.stock,
      'salonId': product.idSalon,
      'fecha': FieldValue.serverTimestamp(),
      'realizadoPor': userId,
      'realizadoPorNombre': userName,
      'motivo': 'Producto agregado al inventario',
    });
  }

  // Actualizar producto
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestore.collection('productos').doc(id).update(data);
  }

  // Actualizar producto con nueva imagen
  Future<void> updateProductWithImage(
    String id,
    Map<String, dynamic> data,
    File? newImage,
    String? oldImageUrl,
  ) async {
    String? imageUrl = oldImageUrl;

    if (newImage != null) {
      imageUrl = await _cloudinaryService.uploadImage(newImage);

      if (imageUrl == null) {
        throw Exception('Error al subir nueva imagen');
      }
    }

    final updateData = Map<String, dynamic>.from(data);
    if (imageUrl != null) {
      updateData['imagen'] = imageUrl;
    }

    await _firestore.collection('productos').doc(id).update(updateData);
  }

  // Ajustar stock + Registrar movimiento ENTRADA/SALIDA MANUAL
  Future<void> adjustStock({
    required String productId,
    required String productName,
    required int cantidadAnterior,
    required int cantidadNueva,
    required String salonId,
    required String userId,
    required String userName,
  }) async {
    final diferencia = cantidadNueva - cantidadAnterior;

    if (diferencia == 0) return; // No hay cambio

    // Actualizar stock
    await _firestore.collection('productos').doc(productId).update({
      'stock': cantidadNueva,
    });

    // Determinar tipo según el signo
    final tipo = diferencia > 0 ? 'entrada_manual' : 'salida_manual';
    final motivo =
        diferencia > 0 ? 'Entrada manual de stock' : 'Salida manual de stock';

    // Registrar movimiento
    await _firestore.collection('movimientos').add({
      'tipo': tipo,
      'productoId': productId,
      'productoNombre': productName,
      'cantidad': diferencia.abs(), // Siempre positivo
      'salonId': salonId,
      'fecha': FieldValue.serverTimestamp(),
      'realizadoPor': userId,
      'realizadoPorNombre': userName,
      'motivo': motivo,
    });
  }

  // Agregar servicio
  Future<void> addService(ServiceModel service) async {
    await _firestore.collection('servicios').add(service.toFirestore());
  }

  // Actualizar servicio
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _firestore.collection('servicios').doc(id).update(data);
  }

  // Transferir producto entre salones
  Future<void> transferProduct({
    required String productId,
    required String productName,
    required int cantidad,
    required String desde,
    required String hacia,
    required String userId,
    required String userName,
  }) async {
    final batch = _firestore.batch();

    final fromProductDoc =
        await _firestore.collection('productos').doc(productId).get();

    if (!fromProductDoc.exists) {
      throw Exception('Producto no encontrado');
    }

    final fromProductData = fromProductDoc.data()!;
    final currentStockFrom = fromProductData['stock'] as int;

    if (currentStockFrom < cantidad) {
      throw Exception('Stock insuficiente en el salón origen');
    }

    batch.update(fromProductDoc.reference, {
      'stock': currentStockFrom - cantidad,
    });

    final toProductQuery = await _firestore
        .collection('productos')
        .where('nombre', isEqualTo: productName)
        .where('idSalon', isEqualTo: hacia)
        .limit(1)
        .get();

    if (toProductQuery.docs.isNotEmpty) {
      final toProductRef = toProductQuery.docs.first.reference;
      final currentStockTo = toProductQuery.docs.first.data()['stock'] as int;
      batch.update(toProductRef, {
        'stock': currentStockTo + cantidad,
      });
    } else {
      final newProductRef = _firestore.collection('productos').doc();
      batch.set(newProductRef, {
        'nombre': fromProductData['nombre'],
        'precio': fromProductData['precio'],
        'stock': cantidad,
        'stockMinimo': fromProductData['stockMinimo'] ?? 5,
        'categoria': fromProductData['categoria'],
        'idSalon': hacia,
        'imagen': fromProductData['imagen'],
        'codigoBarras': fromProductData['codigoBarras'],
        'activo': fromProductData['activo'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final movementRef = _firestore.collection('movimientos').doc();
    batch.set(movementRef, {
      'tipo': 'transferencia',
      'productoId': productId,
      'productoNombre': productName,
      'cantidad': cantidad,
      'desde': desde,
      'hacia': hacia,
      'fecha': FieldValue.serverTimestamp(),
      'realizadoPor': userId,
      'realizadoPorNombre': userName,
    });

    await batch.commit();
  }

  // Registrar salida por VENTA (para cuando implementes ventas)
  Future<void> registerSale({
    required String ventaId,
    required List<Map<String, dynamic>> productos,
    required String userId,
    required String userName,
  }) async {
    final batch = _firestore.batch();

    for (var item in productos) {
      // 1. Reducir stock del producto
      final productRef =
          _firestore.collection('productos').doc(item['productoId']);
      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final currentStock = productDoc.data()!['stock'] as int;
        batch.update(productRef, {
          'stock': currentStock - item['cantidad'],
        });
      }

      // 2. Registrar movimiento de VENTA
      final movementRef = _firestore.collection('movimientos').doc();
      batch.set(movementRef, {
        'tipo': 'venta',
        'productoId': item['productoId'],
        'productoNombre': item['productoNombre'],
        'cantidad': item['cantidad'],
        'salonId': item['salonId'],
        'fecha': FieldValue.serverTimestamp(),
        'realizadoPor': userId,
        'realizadoPorNombre': userName,
        'motivo': 'Venta #$ventaId',
      });
    }

    await batch.commit();
  }
}
