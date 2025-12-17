import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'sales_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _userStatusListener;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isPersonal => _currentUser?.isPersonal ?? false;
  String get userName => _currentUser?.displayName ?? 'Usuario';
  String get userRole => _currentUser?.roleName ?? '';

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        // IMPORTANTE: Esperar a que _loadUserData termine completamente
        await _loadUserData(user.uid);
        
        // Solo iniciar el listener si el usuario fue cargado exitosamente
        if (_currentUser != null) {
          _startUserStatusListener(user.uid);
        }
      } else {
        _cancelUserStatusListener();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    }, onError: (error) {
      print('Error en auth listener: $error');
      _currentUser = null;
      _isLoading = false;
      _errorMessage = 'Error de autenticación';
      notifyListeners();
    });
  }

  void _startUserStatusListener(String uid) {
    _cancelUserStatusListener();

    _userStatusListener = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final isActive = snapshot.data()?['activo'] ?? true;

        // Solo cerrar sesión si el usuario estaba activo y ahora está inactivo
        if (!isActive && _currentUser != null && _currentUser!.activo) {
          _errorMessage = 'Tu cuenta ha sido desactivada por un administrador';
          signOut();
        }
      }
    });
  }

  void _cancelUserStatusListener() {
    _userStatusListener?.cancel();
    _userStatusListener = null;
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (email.trim().isEmpty || password.trim().isEmpty) {
        _errorMessage = 'Email y contraseña son requeridos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userCredential = await _authService.signInWithEmailPassword(
        email,
        password,
      );

      if (userCredential.user != null) {
        // Esperar un poco más para asegurar que _loadUserData termine
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Verificar si el usuario fue cargado exitosamente
        if (_currentUser == null) {
          _isLoading = false;
          // El error ya fue establecido en _loadUserData
          notifyListeners();
          return false;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userData = await _authService.getUserData(uid);

      if (userData != null) {
        final isActive = userData['activo'] ?? true;

        if (!isActive) {
          _errorMessage = 'Tu cuenta ha sido desactivada. Contacta al administrador';
          await _authService.signOut();
          _currentUser = null;
          _isLoading = false;
          notifyListeners();
          return;
        }

        _currentUser = UserModel(
          id: uid,
          nombreUsuario: userData['nombreUsuario'] ?? '',
          email: userData['email'] ?? '',
          idSalon: userData['idSalon'] ?? '',
          idRol: userData['idRol'] ?? 'personal',
          activo: isActive,
          createdAt: userData['createdAt'] != null
              ? (userData['createdAt'] as Timestamp).toDate()
              : null,
        );
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Usuario no encontrado en la base de datos';
        await _authService.signOut();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando usuario: $e');
      _errorMessage = 'Error cargando información del usuario';
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerUser({
    required String email,
    required String password,
    required String nombreUsuario,
    required String idSalon,
    required String idRol,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (nombreUsuario.trim().isEmpty) {
        _errorMessage = 'El nombre es requerido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (email.trim().isEmpty || !email.contains('@')) {
        _errorMessage = 'Email inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String uid = await _authService.createUserWithEmailPasswordSecondary(
        email,
        password,
      );

      await _authService.saveUserData(
        uid,
        {
          'nombreUsuario': nombreUsuario.trim(),
          'email': email.trim(),
          'idSalon': idSalon,
          'idRol': idRol,
          'activo': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al registrar usuario';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========================================
  // 🔥 MÉTODO MODIFICADO CON DEBUGGING
  // ========================================
  Future<void> signOut([BuildContext? context]) async {
    print('🔥 [AuthProvider] signOut() llamado');
    print('🔥 [AuthProvider] Context recibido: ${context != null ? "SÍ" : "NO"}');
    
    _cancelUserStatusListener();
    
    // 🔥 LIMPIAR CARRITO SI SE PASA CONTEXT
    if (context != null) {
      print('🔥 [AuthProvider] Intentando limpiar carrito...');
      try {
        final salesProvider = Provider.of<SalesProvider>(context, listen: false);
        print('🔥 [AuthProvider] SalesProvider encontrado');
        print('🔥 [AuthProvider] Items en carrito ANTES: ${salesProvider.cartItemCount}');
        
        salesProvider.clearCart();
        
        print('🔥 [AuthProvider] Items en carrito DESPUÉS: ${salesProvider.cartItemCount}');
        print('🔥 [AuthProvider] ✅ Carrito limpiado exitosamente');
      } catch (e) {
        print('🔥 [AuthProvider] ❌ ERROR al limpiar carrito: $e');
        print('🔥 [AuthProvider] Stack trace: ${StackTrace.current}');
      }
    } else {
      print('🔥 [AuthProvider] ⚠️ NO se limpiará el carrito (context = null)');
    }
    
    print('🔥 [AuthProvider] Cerrando sesión de Firebase...');
    await _authService.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
    print('🔥 [AuthProvider] ✅ Sesión cerrada completamente');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'El correo o la contraseña son incorrectos';
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'La contraseña es incorrecta';
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta de nuevo más tarde';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red';
      default:
        return 'Error al iniciar sesión. Verifica tus datos';
    }
  }

  @override
  void dispose() {
    _cancelUserStatusListener();
    super.dispose();
  }
}