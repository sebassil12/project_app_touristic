import 'package:latlong2/latlong.dart';

class MarkerData {
  final LatLng position;
  final String title;
  final String description;

  MarkerData({
    required this.position,
    required this.title,
    required this.description,
  });

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
      position: LatLng(json['lat'], json['lng']),
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'title': title,
      'description': description,
    };
  }
}