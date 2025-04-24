import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import '../../widgets/widgets_exports.dart'; 

class EditEmployeeScreen extends StatefulWidget {
  const EditEmployeeScreen({super.key});

  @override
  State<EditEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<EditEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedSede;

  final List<String> _sedes = [
    'Local 1',
    'Local 2',
    'Local 3',
    'Local 4',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = (screenWidth * 0.07).clamp(20.0, 40.0);
    final inputVerticalSpacing = screenHeight * 0.025;
    final buttonMarginBottom = screenHeight * 0.04;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text(
          'Atrás',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      extendBodyBehindAppBar: true,
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: screenHeight * 0.04),
                            child: Image.asset(
                              'assets/employee.png',
                              height: screenHeight * 0.18,
                            ),
                          ),
                        ),
                        CustomInputField(
                          label: 'Nombre',
                          controller: _nameController,
                        ),
                        SizedBox(height: inputVerticalSpacing),
                        CustomDropdownField<String>(
                          label: 'Sede',
                          value: _selectedSede,
                          items: _sedes
                              .map((sede) => DropdownMenuItem(
                                    value: sede,
                                    child: Text(sede),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSede = value;
                            });
                          },
                        ),
                        SizedBox(height: inputVerticalSpacing),
                        CustomPasswordField(
                          label: 'Contraseña',
                          controller: _passwordController,
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Center(
                          child: CustomButton(
                            label: 'GUARDAR',
                            onPressed: () {
                              // Acción de registrar
                            },
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: AppColors.secondary,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.13,
                              vertical: screenHeight * 0.018,
                            ),
                          ),
                        ),
                        SizedBox(height: buttonMarginBottom),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
