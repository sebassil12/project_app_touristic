import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/features/poi/models/poi_model.dart';
import 'package:flutter_application_proyecto/features/poi/poi_detail_screen.dart';

class POIListScreen extends StatelessWidget {
  final List<POI> lugares = [
    POI(
      nombre: 'Plaza Grande',
      descripcion: 'Corazón del Centro Histórico de Quito.',
      imagen: 'assets/images/plaza_grande.jpg',
    ),
    POI(
      nombre: 'La Ronda',
      descripcion: 'Calle tradicional llena de cultura y arte.',
      imagen: 'assets/images/la_ronda.jpeg',
    ),
    POI(
      nombre: 'Catedral Metropolitana',
      descripcion: 'Uno de los templos más importantes de Quito.',
      imagen: 'assets/images/catedral.jpeg',
    ),
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
              lugar.imagen,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            title: Text(lugar.nombre),
            subtitle: Text(lugar.descripcion),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => POIDetailScreen(poi: lugar),
                ),
              );
            },
          );
        },
      ),
    );
  }
}