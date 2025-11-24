import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String nombre;
  final bool activo;
  final Timestamp fechaCreacion;

  Category({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.fechaCreacion,
  });

  // Convertir de Firestore a objeto Category
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      activo: data['activo'] ?? true,
      fechaCreacion: data['fechaCreacion'] ?? Timestamp.now(),
    );
  }

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'activo': activo,
      'fechaCreacion': fechaCreacion,
    };
  }
}
