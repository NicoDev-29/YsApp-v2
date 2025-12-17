import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class SaleModel {
  final String id;
  final DateTime fecha;
  final String idUsuario;
  final String nombreUsuario;
  final String idSalon;
  final String metodoPago; // 'efectivo', 'yape', 'tarjeta'
  final double total;
  final List<CartItemModel> items;

  SaleModel({
    required this.id,
    required this.fecha,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.idSalon,
    required this.metodoPago,
    required this.total,
    required this.items,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'fecha': Timestamp.fromDate(fecha),
      'idUsuario': idUsuario,
      'nombreUsuario': nombreUsuario,
      'idSalon': idSalon,
      'metodoPago': metodoPago,
      'total': total,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  // Crear desde Firestore
  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SaleModel(
      id: doc.id,
      fecha: (data['fecha'] as Timestamp).toDate(),
      idUsuario: data['idUsuario'] ?? '',
      nombreUsuario: data['nombreUsuario'] ?? '',
      idSalon: data['idSalon'] ?? '',
      metodoPago: data['metodoPago'] ?? 'efectivo',
      total: (data['total'] ?? 0).toDouble(),
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => _cartItemFromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Helper para convertir Map a CartItemModel
  static CartItemModel _cartItemFromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      tipo: map['tipo'] ?? 'producto',
      cantidad: map['cantidad'] ?? 1,
      precioFinal: (map['precioFinal'] ?? 0).toDouble(),
      productoId: map['productoId'],
      imagen: map['imagen'],
      servicioId: map['servicioId'],
      productosUsados: (map['productosUsados'] as List<dynamic>?)
          ?.map((p) => ProductUsed.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }
}