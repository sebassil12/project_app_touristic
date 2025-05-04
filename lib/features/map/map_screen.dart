import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_proyecto/features/map/models/marker_model.dart';
import 'package:flutter_application_proyecto/features/map/services/location_service.dart';
import 'package:flutter_application_proyecto/features/map/services/place_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final PlaceService _placeService = PlaceService();
  final TextEditingController _searchController = TextEditingController();

  List<MarkerData> _markersData = [];
  List<Marker> _markers = [];
  LatLng? _currentLocation;
  LatLng? _selectedPosition;
  bool _isDragging = false;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchInput);
    _loadInitialLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLocation() async {
    try {
      final position = await _locationService.determinePosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _handleSearchInput() {
    if (_searchController.text.isNotEmpty) {
      setState(() => _isSearching = true);
      _searchPlaces(_searchController.text);
    } else {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    final results = await _placeService.searchPlaces(query);
    setState(() => _searchResults = results);
  }

  void _moveToLocation(double lat, double lng) {
    final location = LatLng(lat, lng);
    _mapController.move(location, 15.0);
    setState(() {
      _selectedPosition = location;
      _searchResults = [];
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _showCurrentLocation() async {
    try {
      final position = await _locationService.determinePosition();
      final location = LatLng(position.latitude, position.longitude);
      _mapController.move(location, 15.0);
      setState(() => _currentLocation = location);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _addMarker(LatLng position, String title, String description) {
    final newMarker = MarkerData(
      position: position,
      title: title.isNotEmpty ? title : 'Untitled Location',
      description: description.isNotEmpty ? description : 'No description',
    );

    setState(() {
      _markersData.add(newMarker);
      _markers.add(_buildMarker(newMarker));
      _isDragging = false;
    });
  }

  Marker _buildMarker(MarkerData data) {
    return Marker(
      point: data.position,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _showMarkerInfo(data),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                data.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.location_on, color: Colors.red, size: 40),
          ],
        ),
      ),
    );
  }

  void _showMarkerDialog(LatLng position) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Marker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _addMarker(
                position,
                titleController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(MarkerData markerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(markerData.title),
        content: Text(markerData.description),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 13.0,
              onTap: (_, point) {
                if (_isDragging) {
                  setState(() => _selectedPosition = point);
                  _showMarkerDialog(point);
                }
              },
              maxZoom: 18.0,
              minZoom: 2.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          _buildSearchBar(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 40,
      left: 15,
      right: 15,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search places...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
          if (_isSearching && _searchResults.isNotEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                
              )],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(result['display_name']),
                    onTap: () {
                      final lat = double.parse(result['lat']);
                      final lon = double.parse(result['lon']);
                      _moveToLocation(lat, lon);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'location',
            backgroundColor: Colors.white,
            foregroundColor: Colors.indigo,
            onPressed: _showCurrentLocation,
            child: const Icon(Icons.location_searching_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addMarker',
            backgroundColor: _isDragging ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
            onPressed: () {
              setState(() => _isDragging = !_isDragging);
            },
            child: Icon(_isDragging ? Icons.cancel : Icons.add_location),
          ),
        ],
      ),
    );
  }
}