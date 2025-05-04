import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/app/app.dart';
import 'package:flutter_application_proyecto/app/providers.dart';

void main() {
  runApp(
    const AppProviders(
      child: GuiaTuristicaApp(),
    ),
  );
}