import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../session_user.dart';

class PersonalizarPerfilScreen extends StatefulWidget {
  const PersonalizarPerfilScreen({super.key});

  @override
  State<PersonalizarPerfilScreen> createState() =>
      _PersonalizarPerfilScreenState();
}

class _PersonalizarPerfilScreenState extends State<PersonalizarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  String ciudad = '';
  String pais = '';
  String descripcion = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Cargar datos del usuario desde Firestore
  Future<void> _loadProfile() async {
    if (SessionUser.nombre.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(SessionUser.nombre)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nombre = data['nombre'] ?? '';
          ciudad = data['ciudad'] ?? '';
          pais = data['pais'] ?? '';
          descripcion = data['descripcion'] ?? '';
        });
      } else {
        // Si no hay datos, usamos SessionUser
        setState(() {
          nombre = SessionUser.nombre;
          ciudad = SessionUser.ciudad;
          pais = SessionUser.pais;
          descripcion = SessionUser.descripcion;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Guardar perfil en Firestore y actualizar SessionUser
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Guardar o actualizar Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(SessionUser.nombre)
          .set({
        'nombre': nombre,
        'ciudad': ciudad,
        'pais': pais,
        'descripcion': descripcion,
        'avatarUrl': '', // Siempre icono por ahora
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      // Actualizar SessionUser para reflejar cambios en PerfilScreen
      SessionUser.nombre = nombre;
      SessionUser.ciudad = ciudad;
      SessionUser.pais = pais;
      SessionUser.descripcion = descripcion;
      SessionUser.avatarUrl = '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color(0xFFF2A71A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.orange[300],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: nombre,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Ingresa tu nombre'
                          : null,
                      onSaved: (val) => nombre = val ?? '',
                    ),
                    TextFormField(
                      initialValue: ciudad,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      onSaved: (val) => ciudad = val ?? '',
                    ),
                    TextFormField(
                      initialValue: pais,
                      decoration: const InputDecoration(labelText: 'País'),
                      onSaved: (val) => pais = val ?? '',
                    ),
                    TextFormField(
                      initialValue: descripcion,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      maxLines: 3,
                      onSaved: (val) => descripcion = val ?? '',
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2A71A),
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
