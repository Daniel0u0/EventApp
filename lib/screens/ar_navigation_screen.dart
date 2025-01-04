import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart'; // Required for AR functionality
import 'package:vector_math/vector_math_64.dart'; // Required for Vector3


class ARNavigationScreen extends StatefulWidget {
  final String location; // Pass the event location as a string

  const ARNavigationScreen({Key? key, required this.location}) : super(key: key);

  @override
  _ARNavigationScreenState createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  late ARSessionManager arSessionManager; // AR session manager
  late ARObjectManager arObjectManager; // AR object manager

  @override
  void dispose() {
    // Dispose AR session when leaving the screen
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AR Navigation"), // AppBar title
      ),
      body: ARView(
        onARViewCreated: _onARViewCreated, // Callback for ARView initialization
        planeDetectionConfig: PlaneDetectionMode.horizontal, // Detect horizontal planes
      ),
    );
  }

  // Called when the ARView is created
  void _onARViewCreated(
      ARSessionManager sessionManager, ARObjectManager objectManager) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    // Initialize the AR session
    arSessionManager.onInitialize(
      showFeaturePoints: false, // Hide AR feature points
      showPlanes: true, // Show detected planes
      customPlaneTexturePath: "assets/plane_texture.png", // Optional texture for planes
      showPlaneTextures: true,
    );

    // Initialize the AR object manager
    arObjectManager.onInitialize();

    // Place the 3D marker in the AR scene
    await _addMarker();
  }

  // Add a 3D marker to the AR environment
  Future<void> _addMarker() async {
    try {
      // Add the 3D marker node
      await arObjectManager.addNode(ARNode(
        type: NodeType.localGLTF2, // Specify the node type as a local GLTF2 model
        uri: "assets/models/location_marker.glb", // Path to your 3D marker model
        scale: Vector3(0.5, 0.5, 0.5), // Scale the marker (adjust as needed)
        position: Vector3(0.0, 0.0, -2.0), // Place the marker 2 meters in front of the user
      ));
    } catch (e) {
      // Handle errors gracefully
      print("Error adding marker: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load AR marker")),
      );
    }
  }
}