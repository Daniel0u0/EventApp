import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final String location;

  const MapScreen({Key? key, required this.location}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? _userLocation;
  LatLng? _destinationCoordinates;
  String? _errorMessage;
  Set<Marker> _markers = {};

  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962), // Default fallback position
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _determineCurrentPosition();
    _getLatLngFromLocation(widget.location);
  }

  Future<void> _getLatLngFromLocation(String location) async {
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationCoordinates = LatLng(locations[0].latitude, locations[0].longitude);
          _addMarkers();
        });
      } else {
        setState(() {
          _errorMessage = 'Destination not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching destination: $e';
      });
    }
  }

  Future<void> _determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = 'Location services are disabled. Please enable them.';
      });
      return;
    }

    // Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied.';
      });
      return;
    }

    // Get the current position.
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _addMarkers();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
      });
    }
  }

  void _addMarkers() {
    // Clear existing markers
    _markers.clear();

    // Add user location marker
    if (_userLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: _userLocation!,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add destination marker
    if (_destinationCoordinates != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: _destinationCoordinates!,
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    }

    // Re-focus map to fit both markers
    _moveToFitMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLocation == null && _destinationCoordinates == null
          ? Center(
        child: _errorMessage != null
            ? Text(_errorMessage!)
            : CircularProgressIndicator(),
      )
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _defaultPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _moveToFitMarkers();
        },
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moveToFitMarkers,
        label: const Text('Fit Markers'),
        icon: const Icon(Icons.location_on),
      ),
    );
  }

  Future<void> _moveToFitMarkers() async {
    final GoogleMapController controller = await _controller.future;

    if (_userLocation != null && _destinationCoordinates != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _userLocation!.latitude < _destinationCoordinates!.latitude
              ? _userLocation!.latitude
              : _destinationCoordinates!.latitude,
          _userLocation!.longitude < _destinationCoordinates!.longitude
              ? _userLocation!.longitude
              : _destinationCoordinates!.longitude,
        ),
        northeast: LatLng(
          _userLocation!.latitude > _destinationCoordinates!.latitude
              ? _userLocation!.latitude
              : _destinationCoordinates!.latitude,
          _userLocation!.longitude > _destinationCoordinates!.longitude
              ? _userLocation!.longitude
              : _destinationCoordinates!.longitude,
        ),
      );

      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }
}