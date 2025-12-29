import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

enum PeriodFilter { hoy, semana, mes }

class PeriodFilterTabs extends StatelessWidget {
  final PeriodFilter selectedPeriod;
  final ValueChanged<PeriodFilter> onChanged;

  const PeriodFilterTabs({
    Key? key,
    required this.selectedPeriod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background2,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTab('Hoy', PeriodFilter.hoy),
          _buildTab('Semana', PeriodFilter.semana),
          _buildTab('Mes', PeriodFilter.mes),
        ],
      ),
    );
  }

  Widget _buildTab(String label, PeriodFilter period) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}