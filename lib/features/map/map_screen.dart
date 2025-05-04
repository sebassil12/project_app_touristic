import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Interactivo')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-0.2196, -78.5127), // Quito coordinates
          zoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.guia_turistica',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(-0.2196, -78.5127),
                child: const Icon(
                  Icons.location_pin, 
                  color: Colors.red, 
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}