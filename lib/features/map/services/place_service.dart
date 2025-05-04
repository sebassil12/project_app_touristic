import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final url = '$_baseUrl?q=$query&format=json&addressdetails=1&limit=5';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }
}