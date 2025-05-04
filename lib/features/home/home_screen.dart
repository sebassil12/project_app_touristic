import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía Turística Quito')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Ver Mapa'),
              onPressed: () => Navigator.pushNamed(context, '/map'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Lista de Puntos'),
              onPressed: () => Navigator.pushNamed(context, '/poi-list'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Perfil'),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}