import 'package:flutter/material.dart';
import '/../../themes/theme.dart';
import '../../widgets/widgets_exports.dart';
import '/../models/models_exports.dart';
import '../screens_exports.dart';
import 'package:ysa_app/ui/widgets/filter_selector.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({Key? key}) : super(key: key);

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  List<Service> services = [
    Service(
      name: 'Manicure',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 25.00,
    ),
    Service(
      name: 'Pedicure',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 22.50,
    ),
    Service(
      name: 'Corte de Cabello hgjkhjkjj',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 30.00,
    ),
    Service(
      name: 'Limpieza Facial',
      imageUrl:
          'https://steamuserimages-a.akamaihd.net/ugc/2513644999170433438/1698ACC197CA3E8E997BD1FD50AEF7CD01CEADC9/?imw=5000&imh=5000&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=false',
      price: 40.00,
    ),
  ];

  String? _selectedSalon;
  String? _selectedFilter;

  final List<String> _salones = ['Salon 1', 'Salon 2', 'Salon 3'];
  final List<String> _filters = ['Activos', 'Desactivados'];

  void toggleActive(int index) {
    setState(() {
      services[index].isActive = !services[index].isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseVerticalSpacing = screenHeight * 0.015;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary),
        title: const Text(
          'Atrás',
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CustomHeader(
                  title: 'SERVICIOS',
                  imagePath: 'assets/item4.png',
                ),
                SizedBox(height: baseVerticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar servicio',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: baseVerticalSpacing * 1.5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterSelector(
                          label: 'Seleccionar Salón',
                          options: _salones,
                          value: _selectedSalon,
                          onChanged: (value) {
                            setState(() {
                              _selectedSalon = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseVerticalSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterSelector(
                          label: 'Filtrar',
                          options: _filters,
                          value: _selectedFilter,
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      AddButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
                          );
                        },
                        label: 'Agregar',
                        icon: Icons.add,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseVerticalSpacing),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(  
                      service: service,
                      onEdit: () {
                        // Navegar a la pantalla de editar servicio
                      },
                      onToggleActive: () => toggleActive(index),
                      deleteIcon: service.isActive ? Icons.check_circle: Icons.block,
                      deleteTooltip: service.isActive ? 'Desactivar' : 'Activar',
                    );
                  },
                ),
                SizedBox(height: baseVerticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
