import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';
import '../screens_exports.dart';
import '../../widgets/widgets_exports.dart';
import '/../models/models_exports.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> employees = [
    Employee(
        name: 'Dina Ysabella Aredo',
        username: 'dina.ysabella',
        location: 'Local 1',
        isActive: true),
    Employee(
        name: 'María López Santiago',
        username: 'maria.lopez',
        location: 'Local 2',
        isActive: true),
        Employee(
        name: 'María López Santiago',
        username: 'maria.lopez',
        location: 'Local 2',
        isActive: true),
        Employee(
        name: 'María López Santiago',
        username: 'maria.lopez',
        location: 'Local 2',
        isActive: true),
        Employee(
        name: 'María López Santiago',
        username: 'maria.lopez',
        location: 'Local 2',
        isActive: true),
        Employee(
        name: 'María López Santiago',
        username: 'maria.lopez',
        location: 'Local 2',
        isActive: true),
  ];

  // Función para activar o desactivar empleada
  void toggleActive(int index) {
    setState(() {
      employees[index].isActive = !employees[index].isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        const CustomHeader(
                          title: 'TRABAJADORAS',
                          imagePath: 'assets/employee.png',
                        ),
                        const SizedBox(height: 10),
                        AddButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const AddEmployeeScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation =
                                      animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          label: 'Agregar',
                          icon: Icons.add,
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            return EmployeeCard(
                              name: employee.name,
                              username: employee.username,
                              location: employee.location,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                         EditEmployeeScreen(employee: employee),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.ease;

                                      final tween =
                                          Tween(begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                      final offsetAnimation =
                                          animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              onDelete: () => toggleActive(index),
                              deleteIcon: employee.isActive
                                  ? Icons.check_circle
                                  : Icons.block,
                              deleteTooltip:
                                  employee.isActive ? 'Desactivar' : 'Activar',
                              isActive: employee.isActive,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
