import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ysa_app/models/models_exports.dart';

class ReportsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<ProductModel>> getLowStockProducts({String? salonId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('productos')
          .where('activo', isEqualTo: true);

      if (salonId != null && salonId != 'todos') {
        query = query.where('idSalon', isEqualTo: salonId);
      }

      final snapshot = await query.get();
      
      List<ProductModel> lowStockProducts = [];

      for (var doc in snapshot.docs) {
        final product = ProductModel.fromFirestore(doc);
        
        if (product.stock < product.stockMinimo) {
          lowStockProducts.add(product);
        }
      }

      lowStockProducts.sort((a, b) {
        final ratioA = a.stock / a.stockMinimo;
        final ratioB = b.stock / b.stockMinimo;
        return ratioA.compareTo(ratioB);
      });

      _isLoading = false;
      notifyListeners();
      return lowStockProducts;
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}