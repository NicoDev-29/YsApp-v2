import 'package:flutter/material.dart';
import '../models/models_exports.dart';
import '../services/services_exports.dart';
import 'auth_provider.dart';

class SalesProvider extends ChangeNotifier {
  final SalesService _salesService = SalesService();

  // ==================== CARRITO (Pantalla de Vender) ====================
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastUserId;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Total del carrito
  double get cartTotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Cantidad de items
  int get cartItemCount => _cartItems.length;

  // Detectar cambio de usuario
  void checkUserChange(AuthProvider authProvider) {
    final currentUserId = authProvider.currentUser?.id;

    if (_lastUserId != null && _lastUserId != currentUserId) {
      print('🔄 [SalesProvider] Cambio de usuario detectado');
      print('👤 [SalesProvider] Usuario anterior: $_lastUserId');
      print('👤 [SalesProvider] Usuario actual: $currentUserId');
      print('🛒 [SalesProvider] Items en carrito: ${_cartItems.length}');
      clearCart();
      print('✅ [SalesProvider] Carrito limpiado');
    }

    _lastUserId = currentUserId;
  }

  // Agregar producto al carrito
  void addProductToCart(
    String productoId,
    String nombre,
    double precio,
    String? imagen,
    int stockDisponible,
  ) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productoId == productoId && item.tipo == 'producto',
    );

    if (existingIndex >= 0) {
      if (_cartItems[existingIndex].cantidad < stockDisponible) {
        _cartItems[existingIndex].cantidad++;
      }
    } else {
      _cartItems.add(CartItemModel.fromProduct(
        productoId,
        nombre,
        precio,
        imagen,
        stockDisponible,
      ));
    }

    notifyListeners();
  }

  // Agregar servicio al carrito
  void addServiceToCart(
    String servicioId,
    String nombre,
    double precioBase,
  ) {
    _cartItems.add(CartItemModel.fromService(
      servicioId,
      nombre,
      precioBase,
    ));
    notifyListeners();
  }

  // Incrementar cantidad de producto
  void incrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0 && _cartItems[index].tipo == 'producto') {
      final item = _cartItems[index];
      if (item.cantidad < (item.stockDisponible ?? 999)) {
        item.cantidad++;
        notifyListeners();
      }
    }
  }

  // Decrementar cantidad de producto
  void decrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0 && _cartItems[index].tipo == 'producto') {
      if (_cartItems[index].cantidad > 1) {
        _cartItems[index].cantidad--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Eliminar item del carrito
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Actualizar precio de servicio
  void updateServicePrice(String itemId, double newPrice) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0 && _cartItems[index].tipo == 'servicio') {
      _cartItems[index].precioFinal = newPrice;
      notifyListeners();
    }
  }

  // ← CORREGIDO: Agregar producto usado a un servicio CON VALIDACIÓN DE STOCK
  bool addProductToService(
    String serviceItemId,
    String productoId,
    String productoNombre,
    int stockDisponible, // ← NUEVO parámetro
  ) {
    final index = _cartItems.indexWhere((item) => item.id == serviceItemId);
    if (index >= 0 && _cartItems[index].tipo == 'servicio') {
      final existing = _cartItems[index].productosUsados.indexWhere(
            (p) => p.productoId == productoId,
          );

      if (existing >= 0) {
        // Producto ya está en la lista, incrementar cantidad
        final cantidadActual = _cartItems[index].productosUsados[existing].cantidad;
        
        if (cantidadActual < stockDisponible) {
          _cartItems[index].productosUsados[existing].cantidad++;
          notifyListeners();
          return true; // ← Éxito
        } else {
          // ← Stock insuficiente
          _errorMessage = 'Stock insuficiente de $productoNombre (disponible: $stockDisponible)';
          notifyListeners();
          return false; // ← Error
        }
      } else {
        // Producto nuevo, agregar con cantidad 1
        if (stockDisponible > 0) {
          _cartItems[index].productosUsados.add(ProductUsed(
                productoId: productoId,
                nombre: productoNombre,
                cantidad: 1,
              ));
          notifyListeners();
          return true; // ← Éxito
        } else {
          _errorMessage = 'Stock agotado de $productoNombre';
          notifyListeners();
          return false; // ← Error
        }
      }
    }
    return false;
  }

  // ← CORREGIDO: Incrementar cantidad de producto en servicio CON VALIDACIÓN
  bool incrementProductInService(
    String serviceItemId,
    String productoId,
    int stockDisponible, // ← NUEVO parámetro
  ) {
    final index = _cartItems.indexWhere((item) => item.id == serviceItemId);
    if (index >= 0 && _cartItems[index].tipo == 'servicio') {
      final productIndex = _cartItems[index].productosUsados.indexWhere(
            (p) => p.productoId == productoId,
          );
      if (productIndex >= 0) {
        final cantidadActual = _cartItems[index].productosUsados[productIndex].cantidad;
        final productoNombre = _cartItems[index].productosUsados[productIndex].nombre;
        
        if (cantidadActual < stockDisponible) {
          _cartItems[index].productosUsados[productIndex].cantidad++;
          notifyListeners();
          return true; // ← Éxito
        } else {
          _errorMessage = 'Stock insuficiente de $productoNombre (disponible: $stockDisponible)';
          notifyListeners();
          return false; // ← Error
        }
      }
    }
    return false;
  }

  // Decrementar cantidad de producto en servicio
  void decrementProductInService(String serviceItemId, String productoId) {
    final index = _cartItems.indexWhere((item) => item.id == serviceItemId);
    if (index >= 0 && _cartItems[index].tipo == 'servicio') {
      final productIndex = _cartItems[index].productosUsados.indexWhere(
            (p) => p.productoId == productoId,
          );
      if (productIndex >= 0) {
        if (_cartItems[index].productosUsados[productIndex].cantidad > 1) {
          _cartItems[index].productosUsados[productIndex].cantidad--;
          notifyListeners();
        }
      }
    }
  }

  // Eliminar producto usado de un servicio
  void removeProductFromService(String serviceItemId, String productoId) {
    final index = _cartItems.indexWhere((item) => item.id == serviceItemId);
    if (index >= 0) {
      _cartItems[index].productosUsados.removeWhere(
            (p) => p.productoId == productoId,
          );
      notifyListeners();
    }
  }

  // Actualizar cantidad de producto usado en servicio
  void updateProductUsedQuantity(
      String serviceItemId, String productoId, int newQuantity) {
    if (newQuantity < 1) return;

    final index = _cartItems.indexWhere((item) => item.id == serviceItemId);
    if (index >= 0 && _cartItems[index].tipo == 'servicio') {
      final productIndex = _cartItems[index].productosUsados.indexWhere(
            (p) => p.productoId == productoId,
          );
      if (productIndex >= 0) {
        _cartItems[index].productosUsados[productIndex].cantidad = newQuantity;
        notifyListeners();
      }
    }
  }

  // Limpiar carrito
  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  // Registrar venta
  Future<bool> completeSale({
    required String userId,
    required String userName,
    required String salonId,
    required String metodoPago,
  }) async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'El carrito está vacío';
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _salesService.registerSale(
        userId: userId,
        userName: userName,
        salonId: salonId,
        metodoPago: metodoPago,
        total: cartTotal,
        items: _cartItems,
      );

      clearCart();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar venta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== REPORTES ====================

  // Stream de ventas con filtros
  Stream<List<SaleModel>> getSales({
    String? salonId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _salesService.getSales(
      salonId: salonId,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Stream de usuarios (trabajadoras) para filtros de reportes
  Stream<List<UserModel>> getUsers({String? salonId}) {
    return _salesService.getUsers(salonId: salonId);
  }
}