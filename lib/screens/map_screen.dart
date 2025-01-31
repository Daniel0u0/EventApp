import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  LatLng? _coordinates;
  String? _errorMessage;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962), // Default position
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _getLatLngFromLocation(widget.location);
  }

  Future<void> _getLatLngFromLocation(String location) async {
    try {
      print('Geocoding location: $location'); // Log the location being geocoded
      List<Location> locations = await locationFromAddress(location);
      print('Geocoded locations: $locations'); // Log the results of geocoding
      if (locations.isNotEmpty) {
        setState(() {
          _coordinates = LatLng(locations[0].latitude, locations[0].longitude);
        });
      } else {
        setState(() {
          _errorMessage = 'Location not found';
        });
      }
    } catch (e) {
      print('Error during geocoding: $e'); // Log the error
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _coordinates == null
          ? Center(
        child: _errorMessage != null
            ? Text(_errorMessage!)
            : CircularProgressIndicator(),
      )
          : GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _coordinates != null
            ? CameraPosition(
          target: _coordinates!,
          zoom: 14.0,
        )
            : _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          if (_coordinates != null) {
            _goToCoordinates();
          }
        },
        markers: _coordinates != null
            ? {
          Marker(
            markerId: MarkerId('eventLocation'),
            position: _coordinates!,
          ),
        }
            : {},
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCoordinates,
        label: const Text('Go to Location'),
        icon: const Icon(Icons.location_on),
      ),
    );
  }

  Future<void> _goToCoordinates() async {
    final GoogleMapController controller = await _controller.future;
    if (_coordinates != null) {
      await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _coordinates!,
          zoom: 14.0,
        ),
      ));
    }
  }
}
