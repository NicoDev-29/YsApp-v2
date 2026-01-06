import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nombreUsuario;
  final String email;
  final String idSalon;
  final String idRol; // 'admin' o 'personal'
  final bool activo;
  final DateTime? createdAt;
  final String? fcmToken; // ✅ NUEVO: Token para notificaciones push

  UserModel({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    required this.idSalon,
    required this.idRol,
    this.activo = true,
    this.createdAt,
    this.fcmToken, // ✅ NUEVO
  });

  // Factory desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      email: data['email'] ?? '',
      idSalon: data['idSalon'] ?? '',
      idRol: data['idRol'] ?? 'personal',
      activo: data['activo'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      fcmToken: data['fcmToken'], // ✅ NUEVO
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreUsuario': nombreUsuario,
      'email': email,
      'idSalon': idSalon,
      'idRol': idRol,
      'activo': activo,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      if (fcmToken != null) 'fcmToken': fcmToken, // ✅ NUEVO: Solo si existe
    };
  }

  // Helpers para roles
  bool get isAdmin => idRol.toLowerCase() == 'admin';
  bool get isPersonal => idRol.toLowerCase() == 'personal';

  // Nombre completo para mostrar
  String get displayName => nombreUsuario.isNotEmpty ? nombreUsuario : email;
  
  // Nombre del rol en español
  String get roleName => isAdmin ? 'Administradora' : 'Personal';
}