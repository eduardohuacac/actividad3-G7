import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/image_urls.dart';
import '../../handlers/main_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrUserController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final input = _emailOrUserController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _showSnack('Por favor completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔍 Buscar usuario por nombre o correo
      QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .where('nombre', isEqualTo: input)
          .get();

      // Si no lo encuentra por nombre, buscar por email
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

      // 🔐 Validar contraseña
      if (password == storedPassword) {
        _showSnack('Bienvenido, ${userData['nombre']}');

        // 👇 Ir directamente al MainHandler
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHandler()),
        );
      } else {
        _showSnack('Contraseña incorrecta');
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              Image.network(AppImageUrls.logo, height: 123),
              const SizedBox(height: 30),
              const Text(
                "INICIAR SESIÓN",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Campo usuario o correo
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

              // Campo contraseña
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

              // Botón ingresar
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
                child: Image.network(AppImageUrls.googleIcon,
                    width: 33, height: 33),
              ),
              const SizedBox(height: 40),

              InkWell(
                onTap: () => Navigator.pushNamed(context, '/register'),
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
