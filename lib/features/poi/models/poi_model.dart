class POI {
  final String nombre;
  final String descripcion;
  final String imagen;
  final double? latitud;
  final double? longitud;

  POI({
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    this.latitud,
    this.longitud,
  });

  factory POI.fromMap(Map<String, dynamic> map) {
    return POI(
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      imagen: map['imagen'] ?? '',
      latitud: map['latitud'],
      longitud: map['longitud'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}

class Review {
  final String lugarNombre;
  final double rating;
  final String comentario;

  Review({
    required this.lugarNombre,
    required this.rating,
    required this.comentario,
  });

  toMap() {}
}