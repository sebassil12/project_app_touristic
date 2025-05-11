import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_proyecto/services/auth_service.dart';
import 'package:flutter_application_proyecto/services/user_service.dart';
import 'package:flutter_application_proyecto/services/marker_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Initialize shared dependencies
    final storage = const FlutterSecureStorage();

    return MultiProvider(
      providers: [
        // Core services
        Provider<FlutterSecureStorage>(create: (_) => storage),
        
        // Auth service (depends on storage)
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
        
        // User service (depends on auth)
        ProxyProvider<AuthService, UserService>(
          update: (_, authService, __) => UserService(authService),
        ),
        
        // Marker service (depends on auth)
        ProxyProvider<AuthService, MarkerService>(
          update: (_, authService, __) => MarkerService(authService),
        ),
        
        // Database service (depends on auth)
      ],
      child: child,
    );
  }
}