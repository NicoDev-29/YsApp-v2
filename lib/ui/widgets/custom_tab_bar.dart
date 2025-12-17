import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

/// Widget reutilizable para TabBar con diseño consistente
class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final Function(int)? onTap;

  const CustomTabBar({
    Key? key,
    required this.controller,
    required this.tabs,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[700],
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          onTap: onTap,
          tabs: tabs
              .map((tab) => Tab(
                    height: 36,
                    text: tab,
                  ))
              .toList(),
        ),
      ),
    );
  }
}