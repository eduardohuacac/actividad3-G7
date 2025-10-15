// lib/screens/publicar_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../session_user.dart'; // ✅ Usuario en sesión

class PublicarScreen extends StatefulWidget {
  const PublicarScreen({super.key});
  @override
  PublicarScreenState createState() => PublicarScreenState();
}

class PublicarScreenState extends State<PublicarScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _ingredientesController = TextEditingController();
  final TextEditingController _procedimientoController =
      TextEditingController();
  final TextEditingController _presupuestoController = TextEditingController();

  bool _isLoading = false;

  String _numPlatos = '1 a 2';
  final List<String> _numPlatosOptions = [
    '1 a 2',
    '2 a 4',
    '4 a 6',
    '6 a 8',
    'Más de 8'
  ];

  Future<void> _publicarReceta() async {
    final usuario =
        SessionUser.nombre.isNotEmpty ? SessionUser.nombre : "Anónimo";

    if (_nombreController.text.isEmpty ||
        _ingredientesController.text.isEmpty ||
        _procedimientoController.text.isEmpty ||
        _presupuestoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('recetas').add({
        'nombre': _nombreController.text,
        'ingredientes': _ingredientesController.text,
        'procedimiento': _procedimientoController.text,
        'presupuesto': double.tryParse(_presupuestoController.text) ?? 0.0,
        'numeroPlatos': _numPlatos,
        'usuario': usuario,
        'puntuacion': 0.0,
        'votos': 0,
        'fecha': Timestamp.now(),
        // ✅ Usamos ícono por defecto en lugar de imagen subida
        'imagenUrl': 'https://cdn-icons-png.flaticon.com/512/857/857681.png',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta publicada con éxito!')),
      );

      _nombreController.clear();
      _ingredientesController.clear();
      _procedimientoController.clear();
      _presupuestoController.clear();
      setState(() {
        _numPlatos = '1 a 2';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Comparte tu receta",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Nombre del plato", "Ej. Lomo Saltado",
                controller: _nombreController),
            const SizedBox(height: 16),
            const Text("Imagen del plato", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/857/857681.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField("Ingredientes", "¿Qué necesita?",
                controller: _ingredientesController, maxLines: 5),
            const SizedBox(height: 16),
            _buildTextField("Procedimiento", "¿Cómo se prepara?",
                controller: _procedimientoController, maxLines: 8),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField("Presupuesto", "S/.",
                      controller: _presupuestoController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Número de platos",
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _numPlatos,
                        items: _numPlatosOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _numPlatos = val!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _publicarReceta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A71A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Publicar",
                        style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      {int maxLines = 1, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
