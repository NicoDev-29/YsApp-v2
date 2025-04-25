import 'package:flutter/material.dart';
import '/../themes/theme.dart';
import 'package:ysa_app/models/models_exports.dart';

class SaleCard extends StatelessWidget {
  final int index;
  final Sale sale;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const SaleCard({
    Key? key,
    required this.index,
    required this.sale,
    required this.onView,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconSize = screenWidth * 0.07; 
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.010;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.07,
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'S/. ${sale.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.045,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    sale.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),
                  Text(
                    '${sale.dateTime.day.toString().padLeft(2, '0')}/${sale.dateTime.month.toString().padLeft(2, '0')}/${sale.dateTime.year} ${sale.dateTime.hour.toString().padLeft(2, '0')}:${sale.dateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: AppColors.primary, size: iconSize),
                  tooltip: 'Ver detalle',
                  onPressed: onView,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: iconSize + 8,
                    height: iconSize + 8,
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary, size: iconSize),
                  tooltip: 'Editar',
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: iconSize + 8,
                    height: iconSize + 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
