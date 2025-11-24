import 'package:cloud_firestore/cloud_firestore.dart';

class MovementModel {
  final String id;
  final String tipo;
  final String productoId;
  final String productoNombre;
  final int cantidad;
  final String? desde; // Opcional (solo para transferencias)
  final String? hacia; // Opcional (solo para transferencias)
  final String? salonId; // Opcional (para ajustes e ingresos)
  final DateTime fecha;
  final String realizadoPor;
  final String realizadoPorNombre;
  final String? motivo; // Opcional

  MovementModel({
    required this.id,
    required this.tipo,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    this.desde,
    this.hacia,
    this.salonId,
    required this.fecha,
    required this.realizadoPor,
    required this.realizadoPorNombre,
    this.motivo,
  });

  // Desde Firestore
  factory MovementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MovementModel(
      id: doc.id,
      tipo: data['tipo'] ?? 'transferencia',
      productoId: data['productoId'] ?? '',
      productoNombre: data['productoNombre'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      desde: data['desde'],
      hacia: data['hacia'],
      salonId: data['salonId'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      realizadoPor: data['realizadoPor'] ?? '',
      realizadoPorNombre: data['realizadoPorNombre'] ?? '',
      motivo: data['motivo'],
    );
  }

  // Hacia Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'productoId': productoId,
      'productoNombre': productoNombre,
      'cantidad': cantidad,
      if (desde != null) 'desde': desde,
      if (hacia != null) 'hacia': hacia,
      if (salonId != null) 'salonId': salonId,
      'fecha': Timestamp.fromDate(fecha),
      'realizadoPor': realizadoPor,
      'realizadoPorNombre': realizadoPorNombre,
      if (motivo != null) 'motivo': motivo,
    };
  }

  // Nombres de salones
  String get desdeNombre {
    if (desde == null) return '';
    return desde == 'salon_principal' ? 'Salón Principal' : 'Salón Secundario';
  }

  String get haciaNombre {
    if (hacia == null) return '';
    return hacia == 'salon_principal' ? 'Salón Principal' : 'Salón Secundario';
  }

  String get salonNombre {
    if (salonId == null) return '';
    return salonId == 'salon_principal' ? 'Salón Principal' : 'Salón Secundario';
  }
}