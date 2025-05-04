import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_proyecto/services/marker_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => MarkerService()),
      ],
      child: child,
    );
  }
}