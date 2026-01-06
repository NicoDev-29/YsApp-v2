import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ContactHelper {
  // CONFIGURAR NÚMERO AQUÍ (formato internacional sin +)
  // Ejemplo: Si el número es 987-654-321 en Perú, escribir: 51987654321
  static const String supportWhatsApp = '51955438739';

  /// Abre WhatsApp con mensaje predefinido de soporte
  static Future<void> openWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$supportWhatsApp?text=${Uri.encodeComponent(
        '¡Hola! Necesito ayuda con YsApp 👋'
      )}'
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'No se pudo abrir WhatsApp',
            'Asegúrate de tener WhatsApp instalado o contacta directamente al $supportWhatsApp',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error',
          'No se pudo abrir WhatsApp. Intenta nuevamente.',
        );
      }
    }
  }

  /// Muestra un diálogo de error
  static void _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}