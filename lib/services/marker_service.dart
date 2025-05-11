import 'dart:convert';
import 'package:flutter_application_proyecto/services/config_service.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'auth_service.dart';

class MarkerService {

  final AuthService _authService;

  MarkerService(this._authService);

  Future<List<Map<String, dynamic>>> getMarkers() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/markers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load markers');
    }
  }

  Future<Map<String, dynamic>> addMarker({
    required String title,
    required String description,
    required LatLng position,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/markers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'lat': position.latitude,
        'lng': position.longitude,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add marker');
    }
  }

  Future<void> deleteMarker(String markerId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/api/markers/$markerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete marker');
    }
  }
}