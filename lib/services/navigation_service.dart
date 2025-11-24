import 'package:flutter/material.dart';
import 'package:ysa_app/models/models_exports.dart';

void navigateByIndex(BuildContext context, int index) {
  final option = menuOptions.firstWhere(
    (opt) => opt.index == index,
    orElse: () => menuOptions[0],
  );

  Navigator.pushReplacementNamed(context, option.routeName);
}
