import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';


class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = AppColors.primary;

    final List<IconData> icons = [
      Icons.people,       
      Icons.inventory,
      Icons.home,          
      Icons.point_of_sale, 
      Icons.bar_chart, 
    ];

    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isSelected = index == currentIndex;
          return IconButton(
            icon: Icon(
              icons[index],
              color: isSelected ? AppColors.tertiary : AppColors.secondary,
              size: 32,
            ),
            onPressed: () => onTap(index),
          );
        }),
      ),
    );
  }
}
