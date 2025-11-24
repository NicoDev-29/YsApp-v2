import 'package:flutter/material.dart';
import 'package:ysa_app/themes/theme.dart';

class SuccessDialog extends StatelessWidget {
  final String message;

  const SuccessDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  static void show(BuildContext context, String message) {
    final navigator = Navigator.of(context, rootNavigator: true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SuccessDialog(message: message),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de éxito
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 50,
                color: AppColors.activeGreen,
              ),
            ),
            const SizedBox(height: 24),
            // Mensaje
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.activeGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}