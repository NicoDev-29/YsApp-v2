import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/providers_exports.dart';
import 'package:ysa_app/services/navigation_service.dart';
import 'package:ysa_app/themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';
import 'package:ysa_app/ui/widgets/widgets_exports.dart';
import '../screens_exports.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.hoy;
  DateTime? _selectedDate; // ← Ahora es nullable
  String? _selectedSalonFilter;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAdmin) {
        _selectedSalonFilter = authProvider.currentUser?.idSalon;
      } else {
        _selectedSalonFilter = 'salon_principal';
      }
      setState(() {});
    });
  }

  //  Calcular fechas según el período
  DateTime get _startDate {
    final now = DateTime.now();
    
    // Si hay fecha personalizada, usarla
    if (_selectedDate != null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 0, 0, 0);
    }
    
    // Caso contrario, usar período predefinido
    switch (_selectedPeriod) {
      case PeriodFilter.hoy:
        return DateTime(now.year, now.month, now.day, 0, 0, 0);
      case PeriodFilter.semana:
        return now.subtract(const Duration(days: 7));
      case PeriodFilter.mes:
        return DateTime(now.year, now.month, 1, 0, 0, 0);
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    
    // Si hay fecha personalizada, usarla
    if (_selectedDate != null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
    }
    
    // Caso contrario, usar período predefinido
    switch (_selectedPeriod) {
      case PeriodFilter.hoy:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PeriodFilter.semana:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PeriodFilter.mes:
        // Último día del mes actual
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return nextMonth.subtract(const Duration(days: 1, hours: 0, minutes: 0, seconds: 1))
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);
    final isAdmin = authProvider.isAdmin;

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
              const CustomAppBar(title: 'TRANSACCIONES'),

              // Selector de salón (solo admin)
              if (isAdmin)
                SalonSelector(
                  selectedSalon: _selectedSalonFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedSalonFilter = value;
                    });
                  },
                ),

              // TABS: Al seleccionar, resetea la fecha personalizada
              PeriodFilterTabs(
                selectedPeriod: _selectedPeriod,
                onChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                    _selectedDate = null; // ← Resetear fecha personalizada
                  });
                },
              ),

              // ✅ CALENDARIO: Al seleccionar fecha, cambia a modo personalizado
              DateSelector(
                selectedDate: _selectedDate ?? DateTime.now(),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date; // ← Guardar fecha personalizada
                  });
                },
              ),

              // Lista de transacciones
              Expanded(
                child: StreamBuilder<List<SaleModel>>(
                  stream: salesProvider.getSales(
                    salonId: isAdmin ? _selectedSalonFilter : authProvider.currentUser?.idSalon,
                    userId: isAdmin ? null : authProvider.currentUser?.id,
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar transacciones',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay transacciones',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    final sales = snapshot.data!;
                    final totalIngresos = sales.fold(0.0, (sum, sale) => sum + sale.total);

                    return Column(
                      children: [
                        // Tarjeta de resumen
                        SummaryCard(
                          totalIngresos: totalIngresos,
                          cantidadTransacciones: sales.length,
                        ),

                        // Lista de ventas
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              final sale = sales[index];
                              return TransactionCard(
                                sale: sale,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetailScreen(sale: sale),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}