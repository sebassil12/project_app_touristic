import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/app/routes.dart';

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