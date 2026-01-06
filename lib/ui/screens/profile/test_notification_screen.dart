// ARCHIVO: lib/test_notification_screen.dart
// Crea este archivo temporal para diagnosticar

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TestNotificationScreen extends StatefulWidget {
  const TestNotificationScreen({Key? key}) : super(key: key);

  @override
  State<TestNotificationScreen> createState() => _TestNotificationScreenState();
}

class _TestNotificationScreenState extends State<TestNotificationScreen> {
  String _status = 'Iniciando verificación...';
  String? _token;
  bool _tokenInFirestore = false;
  int _alertsCount = 0;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() => _status = '🔍 Verificando token FCM...');
    
    // 1. Obtener token
    try {
      _token = await FirebaseMessaging.instance.getToken();
      setState(() => _status = 'Token obtenido: ${_token?.substring(0, 20)}...');
    } catch (e) {
      setState(() => _status = 'Error obteniendo token: $e');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    // 2. Verificar en Firestore
    setState(() => _status = 'Verificando Firestore...');
    
    try {
      final admins = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('idRol', isEqualTo: 'admin')
          .get();

      if (admins.docs.isEmpty) {
        setState(() => _status = 'No hay usuarios admin en Firestore');
        return;
      }

      for (var doc in admins.docs) {
        final data = doc.data();
        final fcmToken = data['fcmToken'];
        
        print('👤 Admin: ${data['nombreUsuario']}');
        print('   Token en Firestore: ${fcmToken?.toString().substring(0, 20) ?? "NO TIENE"}...');
        
        if (fcmToken == _token) {
          _tokenInFirestore = true;
        }
      }

      setState(() {
        if (_tokenInFirestore) {
          _status = ' Token encontrado en Firestore';
        } else {
          _status = ' Token NO está en Firestore';
        }
      });
    } catch (e) {
      setState(() => _status = 'Error verificando Firestore: $e');
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    // 3. Verificar alertas
    setState(() => _status = 'Verificando alertas en Firestore...');
    
    try {
      final alerts = await FirebaseFirestore.instance
          .collection('stock_alerts')
          .limit(10)
          .get();

      _alertsCount = alerts.docs.length;
      
      setState(() => _status = 'Verificación completa: $_alertsCount alertas encontradas');
    } catch (e) {
      setState(() => _status = 'Error verificando alertas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico FCM')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (_token != null) ...[
              const Text('Token FCM:', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_token!, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
            ],
            Text(
              'Token en Firestore: ${_tokenInFirestore ? "✅ SÍ" : "❌ NO"}',
              style: TextStyle(
                color: _tokenInFirestore ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Alertas registradas: $_alertsCount'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runDiagnostics,
              child: const Text('Volver a verificar'),
            ),
          ],
        ),
      ),
    );
  }
}