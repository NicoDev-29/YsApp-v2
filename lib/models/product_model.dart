import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String nombre;
  final double precio;
  final int stock;
  final String categoria;
  final String idSalon;
  final String? imagen;
  final String? codigoBarras;
  final bool activo;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.categoria,
    required this.idSalon,
    this.imagen,
    this.codigoBarras,
    this.activo = true,
    this.createdAt,
  });

  // Desde Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      categoria: data['categoria'] ?? '',
      idSalon: data['idSalon'] ?? '',
      imagen: data['imagen'],
      codigoBarras: data['codigoBarras'],
      activo: data['activo'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Hacia Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'categoria': categoria,
      'idSalon': idSalon,
      'imagen': imagen,
      'codigoBarras': codigoBarras,
      'activo': activo,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  // Nombre del salón para mostrar
  String get salonName {
    return idSalon == 'salon_principal' ? 'Salón Principal' : 'Salón Secundario';
  }
}