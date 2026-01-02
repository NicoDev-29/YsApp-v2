import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  DateTime? _selectedDate;
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

  DateTime get _startDate {
    final now = DateTime.now();

    if (_selectedDate != null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, 0, 0, 0);
    }

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

    if (_selectedDate != null) {
      return DateTime(_selectedDate!.year, _selectedDate!.month,
          _selectedDate!.day, 23, 59, 59);
    }

    switch (_selectedPeriod) {
      case PeriodFilter.hoy:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PeriodFilter.semana:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PeriodFilter.mes:
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return nextMonth
            .subtract(const Duration(days: 1, hours: 0, minutes: 0, seconds: 1))
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
    }
  }

  void _navigateToSales() {
    Navigator.pushNamed(context, '/sales');
  }

  Map<String, List<SaleModel>> _groupSalesByDay(List<SaleModel> sales) {
    final Map<String, List<SaleModel>> grouped = {};
    
    for (var sale in sales) {
      final dayKey = DateFormat('yyyy-MM-dd').format(sale.fecha);
      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(sale);
    }
    
    return grouped;
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
              CustomAppBar(
                title: 'TRANSACCIONES',
                showAddButton: true,
                onAddPressed: _navigateToSales,
              ),
              if (isAdmin)
                SalonSelector(
                  selectedSalon: _selectedSalonFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedSalonFilter = value;
                    });
                  },
                ),
              PeriodFilterTabs(
                selectedPeriod: _selectedPeriod,
                onChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                    _selectedDate = null;
                  });
                },
              ),
              DateSelector(
                selectedDate: _selectedDate ?? DateTime.now(),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              Expanded(
                child: StreamBuilder<List<SaleModel>>(
                  stream: salesProvider.getSales(
                    salonId: isAdmin
                        ? _selectedSalonFilter
                        : authProvider.currentUser?.idSalon,
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
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar transacciones',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
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
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    final sales = snapshot.data!;
                    final totalIngresos =
                        sales.fold(0.0, (sum, sale) => sum + sale.total);

                    final ventasPorDia = _groupSalesByDay(sales);
                    final diasOrdenados = ventasPorDia.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return Column(
                      children: [
                        SummaryCard(
                          totalIngresos: totalIngresos,
                          cantidadTransacciones: sales.length,
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: diasOrdenados.length,
                            itemBuilder: (context, index) {
                              final diaKey = diasOrdenados[index];
                              final ventasDelDia = ventasPorDia[diaKey]!;
                              final fecha = DateTime.parse(diaKey);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DateHeader(
                                    date: fecha,
                                    itemCount: ventasDelDia.length,
                                  ),
                                  ...ventasDelDia.map((sale) => TransactionCard(
                                    sale: sale,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailScreen(sale: sale),
                                        ),
                                      );
                                    },
                                  )),
                                ],
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