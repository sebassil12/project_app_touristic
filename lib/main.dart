import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const GuiaTuristicaApp());
}

class GuiaTuristicaApp extends StatelessWidget {
  const GuiaTuristicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guía Turística',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/auth',
      routes: appRoutes,
    );
  }
}

final Map<String, WidgetBuilder> appRoutes = {
  '/auth': (context) => const AuthScreen(),
  '/home': (context) => const HomeScreen(),
  '/map': (context) => const MapScreen(),
  '/poi-list': (context) => POIListScreen(),
  '/poi-detail': (context) => const POIDetailScreenWrapper(),
  '/review': (context) => const ReviewScreenWrapper(),
  '/profile': (context) => const ProfileScreen(),
};

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Ingresar'),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía Turística Quito')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('Ver Mapa'),
              onPressed: () => Navigator.pushNamed(context, '/map'),
            ),
            ElevatedButton(
              child: const Text('Lista de Puntos'),
              onPressed: () => Navigator.pushNamed(context, '/poi-list'),
            ),
          ],
        ),
      ),
    );
  }
}

class POIListScreen extends StatelessWidget {
  final List<Map<String, String>> lugares = [
    {
      'nombre': 'Plaza Grande',
      'descripcion': 'Corazón del Centro Histórico de Quito.',
      'imagen': 'assets/images/plaza_grande.jpg',
    },
    {
      'nombre': 'La Ronda',
      'descripcion': 'Calle tradicional llena de cultura y arte.',
      'imagen': 'assets/images/la_ronda.jpeg',
    },
    {
      'nombre': 'Catedral Metropolitana',
      'descripcion': 'Uno de los templos más importantes de Quito.',
      'imagen': 'assets/images/catedral.jpeg',
    },
  ];

  POIListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Puntos de Interés')),
      body: ListView.builder(
        itemCount: lugares.length,
        itemBuilder: (context, index) {
          final lugar = lugares[index];
          return ListTile(
            leading: Image.asset(
              lugar['imagen']!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(lugar['nombre'] ?? ''),
            subtitle: Text(lugar['descripcion'] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => POIDetailScreen(
                    nombre: lugar['nombre'] ?? '',
                    descripcion: lugar['descripcion'] ?? '',
                    imagen: lugar['imagen'] ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class POIDetailScreenWrapper extends StatelessWidget {
  const POIDetailScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return POIDetailScreen(
      nombre: args['nombre'] ?? '',
      descripcion: args['descripcion'] ?? '',
      imagen: args['imagen'] ?? '',
    );
  }
}

class POIDetailScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imagen;

  const POIDetailScreen({super.key, required this.nombre, required this.descripcion, required this.imagen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagen),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(descripcion, style: const TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              child: const Text('Escribir Reseña'),
              onPressed: () async {
                final resultado = await Navigator.pushNamed(
                  context,
                  '/review',
                  arguments: {'lugarNombre': nombre},
                );
                if (resultado != null && resultado is Map) {
                  final rating = resultado['rating'];
                  final comentario = resultado['comentario'];
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewScreenWrapper extends StatelessWidget {
  const ReviewScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return ReviewScreen(lugarNombre: args['lugarNombre'] ?? '');
  }
}

class ReviewScreen extends StatefulWidget {
  final String lugarNombre;
  const ReviewScreen({super.key, required this.lugarNombre});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 0;
  final _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  void _guardarResenia() {
    final comentario = _comentarioController.text;
    if (_rating == 0 || comentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, califica y escribe un comentario.')),
      );
      return;
    }
    Navigator.pop(context, {
      'rating': _rating,
      'comentario': comentario,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escribir Resenia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calificación:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating >= index + 1 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _guardarResenia,
                child: const Text('Enviar Resenia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Center(
        child: Column(
          children: const [
            CircleAvatar(radius: 50),
            Text('Nombre del Usuario'),
            Text('Correo electrónico'),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Interactivo')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-0.2196, -78.5127), // Coordenadas de Quito
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.flutter_application_proyecto',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(-0.2196, -78.5127),
                child:
                    const Icon(Icons.location_pin, color: Colors.red, size: 40), 
              ),
            ],
          ),
        ],
      ),
    );
  }
}




 