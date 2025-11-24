import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String _cloudName = 'drjhk54ge';
  static const String _uploadPreset = 'ysa_productos';
  
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      _cloudName,
      _uploadPreset,
      cache: false,
    );
  }
  
  // Sube imagen a Cloudinary y retorna URL pública
  Future<String?> uploadImage(File imageFile) async {
    try {
      if (kDebugMode) {
        print('Subiendo imagen a Cloudinary...');
      }
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'productos',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      final imageUrl = response.secureUrl;
      
      if (kDebugMode) {
        print('Imagen subida: $imageUrl');
      }
      
      return imageUrl;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir imagen: $e');
      }
      return null;
    }
  }
}