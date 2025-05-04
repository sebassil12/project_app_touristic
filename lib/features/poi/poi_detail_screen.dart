import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/features/poi/models/poi_model.dart';
import 'package:flutter_application_proyecto/features/poi/review_screen.dart';

class POIDetailScreenWrapper extends StatelessWidget {
  const POIDetailScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return POIDetailScreen(poi: POI.fromMap(args));
  }
}

class POIDetailScreen extends StatelessWidget {
  final POI poi;

  const POIDetailScreen({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(poi.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(poi.imagen),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(poi.descripcion, style: const TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              child: const Text('Escribir Reseña'),
              onPressed: () async {
                final resultado = await Navigator.pushNamed(
                  context,
                  '/review',
                  arguments: {'lugarNombre': poi.nombre},
                );
                if (resultado != null && resultado is Map) {
                  // Handle review result
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}