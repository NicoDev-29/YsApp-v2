import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/screens/employees/add_employee_screen.dart';
import '../../widgets/widgets_exports.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  final List<Map<String, String>> employees = const [
    {'name': 'Dina Ysabella Aredo', 'location': 'Local 1'},
    {'name': 'María López Santiago', 'location': 'Local 2'},
    {'name': 'Ana Pérez', 'location': 'Local 3'},
    {'name': 'Lucía Gómez', 'location': 'Local 4'},
    {'name': 'Ana Pérez', 'location': 'Local 3'},
    {'name': 'Lucía Gómez', 'location': 'Local 4'},
    {'name': 'Ana Pérez', 'location': 'Local 3'},
    {'name': 'Lucía Gómez', 'location': 'Local 4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        // Fondo general con gradiente
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradient1,
              AppColors.gradient2,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const CustomHeader(
                title: 'Trabajadoras',
                imagePath: 'assets/employee.png',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: AddButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
                    );
                  },
                  label: 'Agregar',
                  icon: Icons.add,
                ),
              ),

              Expanded(
                child: Container(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return EmployeeCard(
                        name: employee['name']!,
                        location: employee['location']!,
                        onEdit: () {},
                        onDelete: () {},
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
