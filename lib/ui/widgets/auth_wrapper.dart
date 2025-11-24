import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ysa_app/main.dart';
import 'package:ysa_app/themes/theme.dart';
import '../screens/screens_exports.dart';
import 'package:ysa_app/providers/providers_exports.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.errorMessage != null && 
            authProvider.errorMessage != _lastError) {
          _lastError = authProvider.errorMessage;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(authProvider.errorMessage!),
                  backgroundColor: AppColors.inactiveRed,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
              authProvider.clearError();
            }
          });
        }

        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        if (authProvider.isAdmin || authProvider.isPersonal) {
          return const InventoryScreen();
        } else {
          Future.microtask(() => authProvider.signOut());
          return const Scaffold(
            body: Center(
              child: Text('Rol no reconocido. Cerrando sesión...'),
            ),
          );
        }
      },
    );
  }
}