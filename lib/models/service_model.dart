import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String nombre;
  final double precioBase;
  final bool activo;
  final DateTime? createdAt;

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.precioBase,
    this.activo = true,
    this.createdAt,
  });

  // Desde Firestore
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      precioBase: (data['precioBase'] ?? 0).toDouble(),
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
      'precioBase': precioBase,
      'activo': activo,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}