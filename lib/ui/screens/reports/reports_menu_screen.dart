import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/navigation_service.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int currentIndex = 5;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        drawer: CustomSideMenu(
          userName: authProvider.userName,
          selectedIndex: currentIndex,
          onMenuItemSelected: (index) {
            setState(() {
              currentIndex = index;
            });
            navigateByIndex(context, index);
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(title: 'REPORTES'),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildReportCard(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.black87,
                      iconBackgroundColor: const Color(0xFFFFD54F),
                      borderColor: const Color(0xFFFFD54F),
                      title: 'Productos por Agotarse',
                      description: 'Monitorea el inventario con stock bajo para reabastecer a tiempo',
                      onTap: () {
                        Navigator.pushNamed(context, '/reports/low-stock');
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildReportCard(
                      context: context,
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: Colors.black87,
                      iconBackgroundColor:const Color(0xFF9B87C1),
                      borderColor: const Color(0xFF9B87C1),
                      title: 'Productos Más Vendidos',
                      description: 'Identifica los productos estrella con mayor demanda',
                      onTap: () {
                        Navigator.pushNamed(context, '/reports/top-products');
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildReportCard(
                      context: context,
                      icon: Icons.analytics_outlined,
                      iconColor: Colors.black87,
                      iconBackgroundColor: const Color(0xFFF48FB1),
                      borderColor: const Color(0xFFF48FB1),
                      title: 'Resumen de Ventas',
                      description: 'Ventas totales por periodo de tiempo',
                      onTap: () {
                        Navigator.pushNamed(context, '/reports/sales-summary');
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    _buildReportCard(
                      context: context,
                      icon: Icons.calendar_today_rounded,
                      iconColor: Colors.black87,
                      iconBackgroundColor: const Color(0xFF80B2CB),
                      borderColor: const Color(0xFF80B2CB),
                      title: 'Ventas Diarias Por Salón',
                      description: 'Analiza el rendimiento diario de cada ubicación',
                      onTap: () {
                        Navigator.pushNamed(context, '/reports/daily-sales');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required Color borderColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            // Sombra para efecto elevado
            BoxShadow(
              color: borderColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
    
            Container(
              padding: const EdgeInsets.all(10), 
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10), 
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24, 
              ),
            ),
            const SizedBox(width: 16),
            
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            
            // Flecha
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}