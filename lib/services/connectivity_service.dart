import 'dart:async' show TimeoutException;
import 'dart:io';

/// Servicio simple para verificar conexión a internet
class ConnectivityService {
  /// Verifica si hay conexión a internet
  /// Intenta hacer ping a Google DNS (8.8.8.8)
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      // No hay conexión
      return false;
    } on TimeoutException catch (_) {
      // Timeout = sin conexión
      return false;
    } catch (e) {
      // Cualquier otro error = sin conexión
      return false;
    }
  }
}