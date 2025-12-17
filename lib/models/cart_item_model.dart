class CartItemModel {
  final String id;
  final String nombre;
  final double precio;
  final String tipo; // 'producto' o 'servicio'
  int cantidad;
  double precioFinal; // Para servicios editables
  List<ProductUsed> productosUsados; // Solo para servicios
  
  // Para productos: referencia al producto original
  final String? productoId;
  final String? imagen;
  final int? stockDisponible;
  
  // Para servicios: referencia al servicio original
  final String? servicioId;

  CartItemModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.tipo,
    this.cantidad = 1,
    double? precioFinal,
    List<ProductUsed>? productosUsados,
    this.productoId,
    this.imagen,
    this.stockDisponible,
    this.servicioId,
  }) : 
    precioFinal = precioFinal ?? precio,
    productosUsados = productosUsados ?? [];

  // Subtotal del item
  double get subtotal {
    if (tipo == 'servicio') {
      return precioFinal; // Servicios no se multiplican por cantidad
    }
    return precio * cantidad;
  }

  // Crear desde producto
  factory CartItemModel.fromProduct(
    String productoId,
    String nombre,
    double precio,
    String? imagen,
    int stockDisponible,
  ) {
    return CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      precio: precio,
      tipo: 'producto',
      cantidad: 1,
      productoId: productoId,
      imagen: imagen,
      stockDisponible: stockDisponible,
    );
  }

  // Crear desde servicio
  factory CartItemModel.fromService(
    String servicioId,
    String nombre,
    double precioBase,
  ) {
    return CartItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      precio: precioBase,
      tipo: 'servicio',
      cantidad: 1,
      precioFinal: precioBase,
      servicioId: servicioId,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'tipo': tipo,
      'cantidad': cantidad,
      'precioFinal': precioFinal,
      'productoId': productoId,
      'imagen': imagen,
      'servicioId': servicioId,
      'productosUsados': productosUsados.map((p) => p.toMap()).toList(),
    };
  }
}

// Producto usado en un servicio
class ProductUsed {
  final String productoId;
  final String nombre;
  int cantidad;

  ProductUsed({
    required this.productoId,
    required this.nombre,
    this.cantidad = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }

  factory ProductUsed.fromMap(Map<String, dynamic> map) {
    return ProductUsed(
      productoId: map['productoId'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }
}