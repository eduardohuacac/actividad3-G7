import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../utils/image_urls.dart';
import '../../handlers/main_handler.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrUserController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    clientId: '',
  );

  Future<void> _login() async {
    final input = _emailOrUserController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showSnack('Por favor completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {
      QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .where('nombre', isEqualTo: input)
          .get();

      if (result.docs.isEmpty) {
        result = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('email', isEqualTo: input)
            .get();
      }

      if (result.docs.isEmpty) {
        _showSnack('Usuario no encontrado');
        return;
      }

      final userData = result.docs.first.data();
      final storedPassword = userData['password'];

      if (password == storedPassword) {
        _showSnack('Bienvenido, ${userData['nombre']}');
        _navigateToMain();
      } else {
        _showSnack('Contraseña incorrecta');
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Login con Google limpio
  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _loading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _showSnack('Inicio de sesión cancelado');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _handleFirestoreUser(userCredential.user!);
        _showSnack('¡Bienvenido, ${userCredential.user!.displayName}!');
        _navigateToMain();
      } else {
        _showSnack('Error: No se pudo obtener información del usuario');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } on PlatformException catch (e) {
      _showSnack('Error del dispositivo: ${e.message}');
    } catch (e) {
      _showSnack('Algo salió mal. Intenta de nuevo.');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Manejo de usuarios en Firestore limpio
  Future<void> _handleFirestoreUser(User user) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('usuarios');
      final userQuery =
          await usersRef.where('uid', isEqualTo: user.uid).limit(1).get();

      if (userQuery.docs.isEmpty) {
        final newUser = {
          'uid': user.uid,
          'email': user.email,
          'nombre': user.displayName ?? 'Usuario Google',
          'foto': user.photoURL ?? '',
          'provider': 'google',
          'fecha_creacion': FieldValue.serverTimestamp(),
          'ultimo_login': FieldValue.serverTimestamp(),
        };

        await usersRef.add(newUser);
      } else {
        await usersRef.doc(userQuery.docs.first.id).update({
          'ultimo_login': FieldValue.serverTimestamp(),
          'foto': user.photoURL ?? userQuery.docs.first.data()['foto'],
        });
      }
    } catch (e) {
      // Error silencioso para no interrumpir el login
    }
  }

  // Manejo de errores limpio
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        _showSnack('Ya existe una cuenta con este email. Usa otro método.');
        break;
      case 'invalid-credential':
        _showSnack('Credenciales inválidas o expiradas.');
        break;
      case 'operation-not-allowed':
        _showSnack('Login con Google no habilitado. Contacta soporte.');
        break;
      case 'network-request-failed':
        _showSnack('Error de conexión. Verifica tu internet.');
        break;
      case 'internal-error':
        _showSnack('Error interno del servidor. Intenta más tarde.');
        break;
      case 'user-disabled':
        _showSnack('Esta cuenta ha sido deshabilitada.');
        break;
      case 'user-not-found':
        _showSnack('No se encontró la cuenta.');
        break;
      default:
        _showSnack('Error: ${e.message ?? 'Desconocido'}');
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // 🔥 CORREGIDO: Logo local con ruta consistente
              Image.asset(
                'lib/assets/images/logo.png', // Ruta de tu logo local
                height: 123,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 123,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant_menu,
                        size: 60, color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Text(
                "INICIAR SESIÓN",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailOrUserController,
                decoration: const InputDecoration(
                  labelText: "Usuario o correo electrónico",
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 19),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  filled: true,
                  fillColor: Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A71A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Ingresar",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                "O ingresa con",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _loading ? null : _loginWithGoogle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: // 🔥 CORREGIDO: Imagen local de Google con ruta consistente
                        Image.asset(
                      'lib/assets/images/google_icon.png', // Ruta de tu icono de Google
                      width: 33,
                      height: 33,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 33,
                          height: 33,
                          color: Colors.grey[300],
                          child: const Icon(Icons.login, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: _loading
                    ? null
                    : () => Navigator.pushNamed(context, '/register'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("¿Aún no tienes una cuenta? "),
                    Text(
                      "Regístrate",
                      style: TextStyle(
                        color: Color(0xFFF2A71A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
