class Employee {
  final String name;
  final String username;
  final String location;
  bool isActive;

  Employee({
    required this.name,
    required this.username,
    required this.location,
    this.isActive = true,
  });
}
