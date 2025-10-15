import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar usuario
  Future<User?> registerWithEmail(
      String nombre, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user == null) {
        return null; // 🔹 En caso de fallo, devuelve null
      }

      // Guardar nombre en Firestore
      await _db.collection('usuarios').doc(user.uid).set({
        'nombre': nombre,
        'email': email,
        'fechaRegistro': DateTime.now(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null; // 🔹 Devuelve null si hay error de Firebase
    } catch (e) {
      print('Error desconocido: $e');
      return null; // 🔹 Devuelve null para cualquier otro error
    }
  }

  // Iniciar sesión con correo
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error desconocido: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}
