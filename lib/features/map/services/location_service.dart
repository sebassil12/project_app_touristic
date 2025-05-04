import 'package:geolocator/geolocator.dart';

// This class is responsible for handling location services.
// It checks if location services are enabled, requests permissions if necessary,
class LocationService {

  Future<Position> determinePosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de localización están desactivados.');
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permissions
      // If the user denies the permission, we can request it again
      permission = await Geolocator.requestPermission();

      // If the user denies the permission again, we throw an exception
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Los permisos de localización están denegados.');
      }
    }
    
    // If the permission is denied forever, we throw an exception
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de localización denegados de forma permanente.');
    }

    // If we have the permission, we can get the current position
    return await Geolocator.getCurrentPosition();
  }
}