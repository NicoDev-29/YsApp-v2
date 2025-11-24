import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/providers/auth_provider.dart';

class RoleBasedVisibility extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleBasedVisibility({
    Key? key,
    required this.allowedRoles,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentUser?.idRol.toLowerCase() ?? '';

    // Normalizar roles permitidos a minúsculas
    final normalizedAllowedRoles = allowedRoles
        .map((role) => role.toLowerCase())
        .toList();

    if (normalizedAllowedRoles.contains(userRole)) {
      return child;
    } else {
      return const SizedBox.shrink();
    }
  }
}