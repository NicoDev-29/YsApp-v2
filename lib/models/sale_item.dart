class SaleItem {
  final String name;
  int quantity;
  final double price;

  SaleItem({
    required this.name,
    this.quantity = 1,
    required this.price,
  });

  double get subtotal => quantity * price;
}
