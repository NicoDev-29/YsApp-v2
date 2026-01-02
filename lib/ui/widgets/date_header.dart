import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ysa_app/themes/theme.dart';

class DateHeader extends StatelessWidget {
  final DateTime date;
  final int itemCount;

  const DateHeader({
    Key? key,
    required this.date,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');
    final isToday = DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary.withOpacity(0.08) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: isToday ? AppColors.primary : Colors.grey[700],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isToday ? 'Hoy' : dateFormat.format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isToday ? AppColors.primary : Colors.grey[800],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$itemCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}