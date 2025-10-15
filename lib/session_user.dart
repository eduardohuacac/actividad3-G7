class SessionUser {
  static String nombre = "Nuevo usuario";
  static String ciudad = "Ciudad";
  static String pais = "País";
  static String descripcion =
      "Aquí puedes agregar una breve descripción sobre ti.";
  static String avatarUrl =
      "https://i.imgur.com/BoN9kdC.png"; // Imagen por defecto

  /// ✅ Actualiza los campos del perfil (solo los que se envían)
  static void actualizar({
    String? nuevoNombre,
    String? nuevaCiudad,
    String? nuevoPais,
    String? nuevaDescripcion,
    String? nuevoAvatarUrl,
  }) {
    if (nuevoNombre != null && nuevoNombre.trim().isNotEmpty) {
      nombre = nuevoNombre.trim();
    }
    if (nuevaCiudad != null && nuevaCiudad.trim().isNotEmpty) {
      ciudad = nuevaCiudad.trim();
    }
    if (nuevoPais != null && nuevoPais.trim().isNotEmpty) {
      pais = nuevoPais.trim();
    }
    if (nuevaDescripcion != null && nuevaDescripcion.trim().isNotEmpty) {
      descripcion = nuevaDescripcion.trim();
    }
    if (nuevoAvatarUrl != null && nuevoAvatarUrl.trim().isNotEmpty) {
      avatarUrl = nuevoAvatarUrl.trim();
    }
  }

  /// ✅ Retorna el nombre del usuario actual
  static String getNombre() => nombre;

  /// ✅ Método para resetear el perfil a valores por defecto
  static void reset() {
    nombre = "Nuevo usuario";
    ciudad = "Ciudad";
    pais = "País";
    descripcion = "Aquí puedes agregar una breve descripción sobre ti.";
    avatarUrl = "https://i.imgur.com/BoN9kdC.png";
  }
}
