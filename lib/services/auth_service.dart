import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  // LOGIN: Autentica con email y contraseña
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // REGISTRO: 
  Future<String> createUserWithEmailPasswordSecondary(
    String email,
    String password,
  ) async {
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp-${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final FirebaseAuth secondaryAuth =
          FirebaseAuth.instanceFor(app: secondaryApp);

      final UserCredential userCredential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final String uid = userCredential.user!.uid;

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      return uid;
    } catch (e) {
      await secondaryApp.delete();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).set(data);
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).update(data);
  }


  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos
      String message = 'Ocurrió un error inesperado';
      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con este correo electrónico.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo no es válido.';
      }
      throw message;
    } catch (e) {
      throw "Error de conexión. Verifica tu internet e intenta de nuevo.";
    }
  }
}
