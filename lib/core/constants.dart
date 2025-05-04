import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Guía Turística';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const primaryColor = Colors.teal;
  static const secondaryColor = Colors.amber;
  
  // Assets
  static const String profilePlaceholder = 'assets/images/profile_placeholder.png';
  
  // API Keys (in a real app, these would be in .env)
  static const String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  
  // Coordinates
  static const quitoLatitude = -0.2196;
  static const quitoLongitude = -78.5127;
}