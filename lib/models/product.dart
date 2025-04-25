class Product {
  final String name;
  final String imageUrl;
  final double price;
  int stock;
  bool isActive;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
    this.isActive = true,
  });
}
