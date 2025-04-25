class Service {
  String name;
  String imageUrl;
  double price;
  bool isActive;

  Service({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.isActive = true,
  });
}
