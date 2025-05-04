import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/features/poi/models/poi_model.dart';

class ReviewScreenWrapper extends StatelessWidget {
  const ReviewScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
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
    
    final review = Review(
      lugarNombre: widget.lugarNombre,
      rating: _rating,
      comentario: comentario,
    );
    
    Navigator.pop(context, review.toMap());
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