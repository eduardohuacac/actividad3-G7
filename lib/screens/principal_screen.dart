// lib/screens/principal_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  PrincipalScreenState createState() => PrincipalScreenState();
}

class PrincipalScreenState extends State<PrincipalScreen> {
  List<Map<String, dynamic>> topRecipes = [];
  List<Map<String, dynamic>> feedRecipes = [];

  @override
  void initState() {
    super.initState();
    loadTopRecipes();
    loadFeedRecipes();
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
                  prefixIcon: const Icon(Icons.search),
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
            Icon(icon, size: 40, color: Colors.orange),
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
                    const Icon(Icons.favorite_border),
                    const SizedBox(width: 4),
                    Text((recipe['votos'] ?? 0).toString()),
                    const SizedBox(width: 16),
                    const Icon(Icons.star_border),
                    const SizedBox(width: 4),
                    Text((recipe['puntuacion'] ?? 0).toString()),
                  ],
                ),
                const Icon(Icons.bookmark_border),
              ],
            ),
          )
        ],
      ),
    );
  }
}
