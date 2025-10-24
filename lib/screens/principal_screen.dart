// lib/screens/principal_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // 🔥 NUEVO
import 'dart:convert'; // 🔥 NUEVO

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  PrincipalScreenState createState() => PrincipalScreenState();
}

class PrincipalScreenState extends State<PrincipalScreen> {
  List<Map<String, dynamic>> topRecipes = [];
  List<Map<String, dynamic>> feedRecipes = [];
  Map<String, dynamic>? _recipeSuggestion; // 🔥 NUEVO: Sugerencia de la API
  bool _loadingSuggestion = false; // 🔥 NUEVO

  @override
  void initState() {
    super.initState();
    loadTopRecipes();
    loadFeedRecipes();
    _loadRecipeSuggestion(); // 🔥 NUEVO: Cargar sugerencia al iniciar
  }

  // 🔥 NUEVO: Método para obtener receta sugerida
  Future<void> _loadRecipeSuggestion() async {
    setState(() => _loadingSuggestion = true);

    try {
      final response = await http
          .get(Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          setState(() {
            _recipeSuggestion = data['meals'][0];
          });
        }
      }
    } catch (e) {
      print('Error cargando sugerencia: $e');
    } finally {
      setState(() => _loadingSuggestion = false);
    }
  }

  // 🔥 NUEVO: Método para recargar sugerencia
  Future<void> _refreshSuggestion() async {
    await _loadRecipeSuggestion();
  }

  // Cargar las 5 recetas con mayor puntuación
  void loadTopRecipes() async {
    final query = await FirebaseFirestore.instance
        .collection('recetas')
        .orderBy('puntuacion', descending: true)
        .limit(5)
        .get();

    setState(() {
      topRecipes =
          query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Cargar todas las recetas para el feed
  void loadFeedRecipes() async {
    final query = await FirebaseFirestore.instance
        .collection('recetas')
        .orderBy('fecha', descending: true)
        .get();

    setState(() {
      feedRecipes =
          query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF2A71A),
        title: Row(
          children: const [
            CircleAvatar(
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: Colors.orange,
            ),
            SizedBox(width: 10),
            Text(
              "Sonia Perez",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "¿Qué cocinaremos Hoy?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Busca tu receta aquí",
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.black), // 🔥 NEGRO
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCategoryItem("Desayuno", Icons.breakfast_dining),
                  _buildCategoryItem("Snack", Icons.fastfood),
                  _buildCategoryItem("Almuerzo", Icons.lunch_dining),
                  _buildCategoryItem("Cena", Icons.dinner_dining),
                  _buildCategoryItem("Refrigerios", Icons.icecream),
                  _buildCategoryItem("Postres", Icons.cake),
                  _buildCategoryItem("Bebidas", Icons.local_cafe),
                  _buildCategoryItem("Ver más...", Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 24),

              // 🔥 NUEVO: Sección de Sugerencia del Día
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "🍳 Sugerencia del Día",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _loadingSuggestion ? null : _refreshSuggestion,
                          icon: _loadingSuggestion
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh,
                                  color: Colors.deepOrange),
                          tooltip: 'Otra sugerencia',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loadingSuggestion)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_recipeSuggestion != null)
                      _buildSuggestionCard()
                    else
                      const Text(
                        'No hay sugerencias disponibles',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "En tendencia",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: topRecipes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = topRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildTopRecipeCard(recipe),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Feed de recetas",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              feedRecipes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: feedRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = feedRecipes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildFeedCard(recipe),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 NUEVO: Widget para mostrar la sugerencia
  Widget _buildSuggestionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagen de la receta
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _recipeSuggestion!['strMealThumb'] ??
                    'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Información de la receta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recipeSuggestion!['strMeal'] ?? 'Receta sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (_recipeSuggestion!['strCategory'] != null)
                    Text(
                      'Categoría: ${_recipeSuggestion!['strCategory']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  if (_recipeSuggestion!['strArea'] != null)
                    Text(
                      'Origen: ${_recipeSuggestion!['strArea']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black), // 🔥 CAMBIADO A NEGRO
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(recipe['imagenUrl'] ??
              'https://cdn-icons-png.flaticon.com/512/1046/1046784.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Text(
          recipe['nombre'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> recipe) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe['usuario'] ?? 'Anónimo',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(recipe['nombre'] ?? 'Plato',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Text(recipe['numeroPlatos'] ?? '',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          // Image
          Image.network(
            recipe['imagenUrl'] ??
                'https://cdn-icons-png.flaticon.com/512/1046/1046784.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              recipe['procedimiento'] ?? '',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
          // Actions
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border,
                        color: Colors.black), // 🔥 NEGRO
                    const SizedBox(width: 4),
                    Text((recipe['votos'] ?? 0).toString()),
                    const SizedBox(width: 16),
                    const Icon(Icons.star_border,
                        color: Colors.black), // 🔥 NEGRO
                    const SizedBox(width: 4),
                    Text((recipe['puntuacion'] ?? 0).toString()),
                  ],
                ),
                const Icon(Icons.bookmark_border,
                    color: Colors.black), // 🔥 NEGRO
              ],
            ),
          )
        ],
      ),
    );
  }
}
