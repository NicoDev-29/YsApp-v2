import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/movement_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<ProductModel>> getProducts({String? idSalon}) {
    return _inventoryService.getProducts(idSalon: idSalon);
  }

  Stream<List<ServiceModel>> getServices() {
    return _inventoryService.getServices();
  }

  Stream<List<MovementModel>> getMovements() {
    return _inventoryService.getMovements();
  }

  // Agregar producto
  Future<bool> addProduct(
    ProductModel product,
    String userId,
    String userName,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.addProduct(product, userId, userName);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.updateProduct(id, data);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar producto con imagen
  Future<bool> updateProductWithImage(
    String id,
    Map<String, dynamic> data,
    File? newImage,
    String? oldImageUrl,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.updateProductWithImage(
        id,
        data,
        newImage,
        oldImageUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ajustar stock (Entrada/Salida Manual)
  Future<bool> adjustStock({
    required String productId,
    required String productName,
    required int cantidadAnterior,
    required int cantidadNueva,
    required String salonId,
    required String userId,
    required String userName,
  }) async {
    try {
      await _inventoryService.adjustStock(
        productId: productId,
        productName: productName,
        cantidadAnterior: cantidadAnterior,
        cantidadNueva: cantidadNueva,
        salonId: salonId,
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Error al ajustar stock: $e';
      return false;
    }
  }

  // Agregar servicio
  Future<bool> addService(ServiceModel service) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.addService(service);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al agregar servicio: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar servicio
  Future<bool> updateService(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.updateService(id, data);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar servicio: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Transferir producto
  Future<bool> transferProduct({
    required String productId,
    required String productName,
    required int cantidad,
    required String desde,
    required String hacia,
    required String userId,
    required String userName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _inventoryService.transferProduct(
        productId: productId,
        productName: productName,
        cantidad: cantidad,
        desde: desde,
        hacia: hacia,
        userId: userId,
        userName: userName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al transferir producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registrar venta (para cuando implementes ventas)
  Future<bool> registerSale({
    required String ventaId,
    required List<Map<String, dynamic>> productos,
    required String userId,
    required String userName,
  }) async {
    try {
      await _inventoryService.registerSale(
        ventaId: ventaId,
        productos: productos,
        userId: userId,
        userName: userName,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar venta: $e';
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}