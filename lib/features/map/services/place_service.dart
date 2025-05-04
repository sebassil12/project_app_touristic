import 'dart:convert';
import 'package:http/http.dart' as http;

//PlaceService class to handle place search functionality
// This class uses the Nominatim API to search for places based on a query string.
class PlaceService {
  //nominatim is a geocoding service that provides a way to search for places using OpenStreetMap data.
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  // This method takes a query string and returns a list of places that match the query.
  Future<List<dynamic>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final url = '$_baseUrl?q=$query&format=json&addressdetails=1&limit=5';

    // Making a GET request to the Nominatim API with the provided query string.
    // The response is expected to be in JSON format.
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }
}